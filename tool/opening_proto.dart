// Prototype « Améliorer son ouverture » (hors app, pour valider la stratégie).
//
// Pour chaque joueur : cadence la plus jouée (90 derniers jours, parties
// classées), puis pour chaque couleur l'ouverture la plus jouée et ses
// défaites. On en tire :
//  A. la séquence la plus jouée dans ces défaites (on suit, demi-coup après
//     demi-coup, la suite la plus fréquente tant qu'elle a au moins
//     [minGames] parties) et, sur cette séquence, le coup du joueur qui perd
//     le plus (évaluation avant - après, de son point de vue) ;
//  B. les positions atteintes au moins [minGames] fois dans ces défaites où
//     le joueur rejoue le même coup, classées par perte x fréquence.
//
// Évaluations : base « cloud » de Lichess (gratuite, sans jeton), mises en
// cache dans build/proto_eval_cache.json.
//
// Lancer : C:\src\flutter\bin\dart.bat run tool/opening_proto.dart lolobatbat tarantino_girl bobgeorges
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:chess/chess.dart';
import 'package:chess_stats_pwa/models/year_month.dart';
import 'package:chess_stats_pwa/services/chess_api_service.dart';
import 'package:chess_stats_pwa/services/game_phase_service.dart';
import 'package:http/http.dart' as http;

const int maxPlies = 24;
const int minGames = 3;
const int mateCp = 1000;
/// Perte minimale (centipions) pour parler d'un coup où le joueur flanche.
const int minLoss = 50;
final File cacheFile = File('build/proto_eval_cache.json');
final Map<String, dynamic> cache = {};
int cloudHits = 0, cloudMisses = 0;

/// `--all` : analyser toutes les parties de l'ouverture, pas seulement les
/// défaites.
bool allGames = false;

Future<void> main(List<String> args) async {
  allGames = args.contains('--all');
  final players = args.where((a) => !a.startsWith('--')).toList();
  if (cacheFile.existsSync()) cache.addAll(json.decode(cacheFile.readAsStringSync()) as Map<String, dynamic>);
  final out = StringBuffer(allGames ? 'Mode : toutes les parties de l\'ouverture\n' : 'Mode : défaites seulement\n');
  for (final player in players) {
    out.writeln(await analyzePlayer(player));
  }
  cacheFile.parent.createSync(recursive: true);
  cacheFile.writeAsStringSync(json.encode(cache));
  out.writeln('\nÉvaluations cloud : $cloudHits trouvées, $cloudMisses inconnues (cache compris).');
  File('build/proto_report.md').writeAsStringSync(out.toString());
  print(out);
}

Future<String> analyzePlayer(String player) async {
  final out = StringBuffer('\n# $player\n');
  final now = DateTime.now().toUtc();
  final months = [for (var i = 3; i >= 0; i--) YearMonth.of(DateTime.utc(now.year, now.month - i, 1))];
  final byMonth = await ChessApiService().fetchMonths(player, months);
  final since = now.subtract(const Duration(days: 90));
  final games = [
    for (final list in byMonth.values)
      for (final g in list)
        if (g.rated && g.moves != null && g.endTime != null && g.endTime!.isAfter(since)) g,
  ];
  final timeClass = mostCommon(games.map((g) => g.timeClass));
  final inClass = games.where((g) => g.timeClass == timeClass).toList();
  out.writeln('Cadence la plus jouée : **$timeClass** (${inClass.length} parties classées sur 90 j)');

  for (final color in ['white', 'black']) {
    final colored = inClass.where((g) => g.playerColor == color).toList();
    if (colored.isEmpty) continue;
    final opening = mostCommon(colored.map((g) => g.opening));
    final inOpening = colored.where((g) => g.opening == opening).toList();
    final losses = inOpening.where((g) => g.result == 'loss').toList();
    final rating = (inClass.map((g) => g.rating ?? 0).reduce((a, b) => a + b) / inClass.length).round();
    out.writeln('\n## ${color == 'white' ? 'Blancs' : 'Noirs'} : $opening');
    out.writeln('${inOpening.length} parties, ${losses.length} défaites (Elo moyen ≈ $rating)');
    if (losses.length < minGames) {
      out.writeln('Pas assez de défaites.');
      continue;
    }
    final analyzed = allGames ? inOpening : losses;
    final lines = [for (final g in analyzed) GamePhaseService.firstMoves(g.moves, plies: maxPlies) ?? const <String>[]];
    final lost = [for (final g in analyzed) g.result == 'loss'];
    out.writeln(await mainLineReport(lines, color == 'white'));
    out.writeln(await recurringReport(lines, lost, color == 'white'));
  }
  return out.toString();
}

/// A : séquence la plus jouée et perte de chaque coup du joueur.
Future<String> mainLineReport(List<List<String>> lines, bool white) async {
  final out = StringBuffer('\n### A. Séquence la plus jouée dans ${allGames ? 'les parties' : 'les défaites'}\n');
  final line = <String>[];
  final counts = <int>[];
  var following = lines;
  while (line.length < maxPlies) {
    final next = following.where((l) => l.length > line.length).map((l) => l[line.length]);
    if (next.isEmpty) break;
    final move = mostCommon(next);
    final kept = following.where((l) => l.length > line.length && l[line.length] == move).toList();
    if (kept.length < minGames) break;
    line.add(move);
    counts.add(kept.length);
    following = kept;
  }
  final board = Chess();
  final rows = <String>[];
  Map<String, Object>? worst;
  for (var ply = 0; ply < line.length; ply++) {
    final isPlayer = ply.isEven == white;
    final fenBefore = board.fen;
    board.move(line[ply]);
    final number = '${ply ~/ 2 + 1}.${ply.isEven ? '' : '..'}';
    if (!isPlayer) {
      rows.add('$number ${line[ply]} (${counts[ply]})');
      continue;
    }
    final eval = await moveLoss(fenBefore, board.fen, line[ply], white);
    rows.add('$number **${line[ply]}** (${counts[ply]}) ${eval.describe()}');
    if (eval.loss != null && eval.loss! >= minLoss && (worst == null || eval.loss! > (worst['loss'] as int))) {
      worst = {'loss': eval.loss!, 'text': '$number ${line[ply]} → ${eval.describe()}, ${counts[ply]} ${allGames ? 'parties' : 'défaites'}'};
    }
  }
  out.writeln(rows.join('  \n'));
  out.writeln('\n**Coup où il flanche :** ${worst == null ? 'aucun (perte < ${minLoss / 100} pion)' : worst['text']}');
  return out.toString();
}

/// B : positions récurrentes où le joueur rejoue le même coup.
Future<String> recurringReport(List<List<String>> lines, List<bool> lost, bool white) async {
  final out = StringBuffer('\n### B. Erreurs récurrentes (position atteinte ≥ $minGames fois, même coup)\n');
  final reached = <String, Map<String, int>>{}; // FEN -> coup -> nombre
  final lossesOf = <String, int>{}; // FEN + coup -> défaites
  final plyOf = <String, int>{};
  for (final (index, l) in lines.indexed) {
    final board = Chess();
    for (var ply = 0; ply < l.length; ply++) {
      if (ply.isEven == white) {
        final key = board.fen;
        reached.putIfAbsent(key, () => {}).update(l[ply], (n) => n + 1, ifAbsent: () => 1);
        if (lost[index]) lossesOf.update('$key|${l[ply]}', (n) => n + 1, ifAbsent: () => 1);
        plyOf[key] = ply;
      }
      if (!board.move(l[ply])) break;
    }
  }
  final found = <(int score, String text)>[];
  for (final MapEntry(key: fen, value: moves) in reached.entries) {
    for (final MapEntry(key: move, value: n) in moves.entries) {
      if (n < minGames) continue;
      final board = Chess.fromFEN(fen)..move(move);
      final eval = await moveLoss(fen, board.fen, move, white);
      if (eval.loss == null || eval.loss! < minLoss) continue;
      final ply = plyOf[fen]!;
      found.add((eval.loss! * n, '${ply ~/ 2 + 1}.${ply.isEven ? '' : '..'} $move ($n fois, ${lossesOf['$fen|$move'] ?? 0} défaites) ${eval.describe()}'));
    }
  }
  found.sort((a, b) => b.$1.compareTo(a.$1));
  out.writeln(found.isEmpty ? 'Aucune.' : found.take(3).map((f) => '- ${f.$2}').join('\n'));
  return out.toString();
}

class MoveEval {
  final int? before, after, loss;
  final String? best;
  final bool isBest;
  MoveEval(this.before, this.after, this.loss, this.best, this.isBest);

  String describe() {
    if (loss == null) return '[éval inconnue]';
    String pawns(int cp) => (cp >= 0 ? '+' : '') + (cp / 100).toStringAsFixed(1);
    return '[${pawns(before!)} → ${pawns(after!)}, perte ${(loss! / 100).toStringAsFixed(1)}'
        '${isBest ? ', meilleur coup' : best != null ? ', mieux : $best' : ''}]';
  }
}

/// Perte (centipions, point de vue du joueur) de [san] joué depuis [fenBefore].
Future<MoveEval> moveLoss(String fenBefore, String fenAfter, String san, bool white) async {
  final before = await cloudEval(fenBefore);
  final after = await cloudEval(fenAfter);
  final bestUci = before?['best'] as String?;
  final best = bestUci == null ? null : uciToSan(fenBefore, bestUci);
  if (before == null || after == null) return MoveEval(null, null, null, best, best == san);
  final pov = white ? 1 : -1;
  final b = (before['cp'] as int) * pov;
  final a = (after['cp'] as int) * pov;
  // Meilleur coup : pas de perte (les écarts viennent des profondeurs d'analyse).
  return MoveEval(b, a, best == san ? 0 : b - a, best, best == san);
}

/// Évaluation cloud Lichess (centipions, point de vue des blancs) et meilleur
/// coup (UCI) ; null si la position est inconnue.
Future<Map<String, dynamic>?> cloudEval(String fen) async {
  if (!cache.containsKey(fen)) {
    while (true) {
      final response = await http.get(
        Uri.https('lichess.org', '/api/cloud-eval', {'fen': fen}),
        headers: {'User-Agent': 'chess-stats-pwa opening prototype'},
      );
      if (response.statusCode == 429) {
        print('429 : pause d\'une minute');
        await Future<void>.delayed(const Duration(minutes: 1));
        continue;
      }
      if (response.statusCode == 200) {
        final pv = (json.decode(response.body)['pvs'] as List).first as Map<String, dynamic>;
        final mate = pv['mate'] as int?;
        cache[fen] = {
          'cp': mate != null ? (mate > 0 ? mateCp : -mateCp) : (pv['cp'] as int).clamp(-mateCp, mateCp),
          'best': (pv['moves'] as String).split(' ').first,
        };
      } else {
        cache[fen] = null;
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));
      break;
    }
  }
  final value = cache[fen] as Map<String, dynamic>?;
  value == null ? cloudMisses++ : cloudHits++;
  return value;
}

String? uciToSan(String fen, String uci) {
  var from = uci.substring(0, 2), to = uci.substring(2, 4);
  // Lichess note le roque « roi prend sa tour » (e1h1).
  const castles = {'e1h1': 'g1', 'e1a1': 'c1', 'e8h8': 'g8', 'e8a8': 'c8'};
  final board = Chess.fromFEN(fen);
  final piece = board.get(from);
  if (piece?.type == PieceType.KING && castles.containsKey(uci.substring(0, 4))) to = castles[uci.substring(0, 4)]!;
  for (final m in board.moves({'verbose': true})) {
    if (m['from'] == from && m['to'] == to) return m['san'] as String;
  }
  return null;
}

T mostCommon<T>(Iterable<T> values) {
  final counts = <T, int>{};
  for (final v in values) {
    counts.update(v, (n) => n + 1, ifAbsent: () => 1);
  }
  return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
}

