import 'package:chess/chess.dart';

import '../models/country_game.dart';
import 'position_evaluator.dart';

/// Ouverture la plus jouée par le joueur avec une couleur, et ses parties.
class ColorOpening {
  final bool white;

  /// Famille d'ouverture (CountryGame.opening).
  final String opening;
  final List<CountryGame> games;

  const ColorOpening(this.white, this.opening, this.games);
}

/// Coup que le joueur rejoue dans une même position de son ouverture.
class OpeningCandidate {
  /// Position avant son coup (FEN complète, la première rencontrée).
  final String fen;

  /// Son coup (SAN).
  final String san;

  /// Demi-coup joué (0 = premier coup des blancs).
  final int ply;

  /// Coups menant à la position (SAN), dans la première partie où elle
  /// apparaît.
  final List<String> line;

  /// Nombre de parties où il a joué ce coup dans cette position, et
  /// défaites parmi elles.
  final int count;
  final int losses;

  const OpeningCandidate({
    required this.fen,
    required this.san,
    required this.ply,
    required this.line,
    required this.count,
    required this.losses,
  });
}

/// Coup à corriger : [candidate] perd [loss] centipions ; [bestSan] était
/// meilleur.
class OpeningMistake {
  final OpeningCandidate candidate;

  /// Évaluations avant et après son coup, de son point de vue (centipions).
  final int evalBefore;
  final int evalAfter;

  final String bestSan;

  /// Cases de départ et d'arrivée de son coup et du meilleur (ex. `e2`,
  /// `e4`), pour les flèches de l'échiquier.
  final (String, String) move;
  final (String, String) best;

  const OpeningMistake({
    required this.candidate,
    required this.evalBefore,
    required this.evalAfter,
    required this.bestSan,
    required this.move,
    required this.best,
  });

  int get loss => evalBefore - evalAfter;
}

/// « Améliorer son ouverture » : dans l'ouverture la plus jouée de chaque
/// couleur, coup que le joueur rejoue souvent et qui lui fait perdre le
/// plus (perte selon le moteur × nombre de fois).
class OpeningImprovementService {
  /// Nombre minimal de parties où le joueur rejoue le même coup dans la
  /// même position.
  static const int minRepeats = 3;

  /// Perte minimale (centipions) pour parler d'erreur.
  static const int minLossCp = 50;

  /// Cadence la plus jouée (null sans partie).
  static String? mainTimeClass(List<CountryGame> games) => _mostCommon(games.map((g) => g.timeClass));

  /// Ouverture la plus jouée avec les blancs ([white]) ou les noirs, parmi
  /// les parties dont les coups sont connus ; null sans partie.
  static ColorOpening? mainOpening(List<CountryGame> games, {required bool white}) {
    final colored = [
      for (final g in games)
        if (g.openingMoves != null && (g.playerColor == 'white') == white) g,
    ];
    final opening = _mostCommon(colored.map((g) => g.opening));
    if (opening == null) return null;
    return ColorOpening(white, opening, [
      for (final g in colored)
        if (g.opening == opening) g
    ]);
  }

  /// Coups rejoués au moins [minRepeats] fois dans une même position, les
  /// plus fréquents d'abord.
  static List<OpeningCandidate> candidates(List<CountryGame> games, {required bool white}) {
    final collector = _CandidateCollector(white);
    games.forEach(collector.add);
    return collector.result();
  }

  /// Comme [candidates], en rendant la main à l'interface toutes les
  /// [batch] parties : le web n'a qu'un fil d'exécution, un long calcul
  /// d'un seul tenant gèlerait la page.
  static Future<List<OpeningCandidate>> candidatesAsync(
    List<CountryGame> games, {
    required bool white,
    int batch = 8,
  }) async {
    final collector = _CandidateCollector(white);
    for (final (index, game) in games.indexed) {
      if (index > 0 && index % batch == 0) await Future<void>.delayed(Duration.zero);
      collector.add(game);
    }
    return collector.result();
  }

  /// Coup de [candidates] à corriger en premier : perte d'au moins
  /// [minLossCp], la plus grande perte × nombre de fois. null si aucun.
  /// [onProgress] reçoit l'avancement (0 à 1).
  static Future<OpeningMistake?> findMistake(
    List<OpeningCandidate> candidates, {
    required bool white,
    required PositionEvaluator evaluator,
    void Function(double progress)? onProgress,
  }) async {
    OpeningMistake? worst;
    final pov = white ? 1 : -1;
    for (final (index, candidate) in candidates.indexed) {
      onProgress?.call(index / candidates.length);
      final before = await evaluator.evaluate(candidate.fen);
      final bestUci = before?.bestUci;
      if (before == null || bestUci == null) continue;
      final best = moveFromUci(candidate.fen, bestUci);
      final move = moveFromSan(candidate.fen, candidate.san);
      // Coup du moteur : rien à corriger (inutile d'évaluer la suite).
      if (best == null || move == null || best.san == candidate.san) continue;
      final after = await evaluator.evaluate(move.fenAfter);
      if (after == null) continue;
      final mistake = OpeningMistake(
        candidate: candidate,
        evalBefore: before.cp * pov,
        evalAfter: after.cp * pov,
        bestSan: best.san,
        move: (move.from, move.to),
        best: (best.from, best.to),
      );
      if (mistake.loss < minLossCp) continue;
      if (worst == null || mistake.loss * candidate.count > worst.loss * worst.candidate.count) worst = mistake;
    }
    onProgress?.call(1);
    return worst;
  }

  /// Coup [san] joué depuis [fen] : cases et position obtenue ; null s'il
  /// est illégal.
  static ({String from, String to, String san, String fenAfter})? moveFromSan(String fen, String san) {
    final board = Chess.fromFEN(fen);
    final move = findSan(board, san);
    if (move == null) return null;
    board.move(move);
    return (from: move.fromAlgebraic, to: move.toAlgebraic, san: san, fenAfter: board.fen);
  }

  /// Coup UCI de Lichess (ex. `g1f3`, roque `e1h1`) joué depuis [fen] ;
  /// null s'il est illégal.
  static ({String from, String to, String san, String fenAfter})? moveFromUci(String fen, String uci) {
    if (uci.length < 4) return null;
    final from = uci.substring(0, 2);
    var to = uci.substring(2, 4);
    final board = Chess.fromFEN(fen);
    // Lichess note le roque « le roi prend sa tour ».
    const castles = {'e1h1': 'g1', 'e1a1': 'c1', 'e8h8': 'g8', 'e8a8': 'c8'};
    if (board.get(from)?.type == PieceType.KING && castles.containsKey(uci.substring(0, 4))) {
      to = castles[uci.substring(0, 4)]!;
    }
    final promotion = uci.length > 4 ? uci[4] : null;
    for (final m in board.generate_moves()) {
      if (m.fromAlgebraic == from && m.toAlgebraic == to && (promotion == null || m.promotion?.name == promotion)) {
        // Notation calculée pour ce seul coup (coûteuse avec le paquet
        // `chess`).
        final san = board.move_to_san(m);
        board.move(m);
        return (from: from, to: to, san: san, fenAfter: board.fen);
      }
    }
    return null;
  }

  /// Coup légal de [board] noté [san] (ex. `Nbd7`, `exd5`, `e8=Q+`, `O-O`) ;
  /// null s'il n'y en a pas exactement un. Lit la notation au lieu de
  /// calculer celle de chaque coup légal (ce que fait `Chess.move`, très
  /// lent : le calcul de toutes les positions d'une ouverture gelait la
  /// page plusieurs secondes).
  static Move? findSan(Chess board, String san) {
    var text = san.replaceAll(RegExp(r'[+#!?]'), '');
    final moves = board.generate_moves();
    if (text == 'O-O' || text == 'O-O-O' || text == '0-0' || text == '0-0-0') {
      final flag = text.length == 3 ? Chess.BITS_KSIDE_CASTLE : Chess.BITS_QSIDE_CASTLE;
      final castles = moves.where((m) => m.flags & flag != 0).toList();
      return castles.length == 1 ? castles.single : null;
    }
    String? promotion;
    final equals = text.indexOf('=');
    if (equals >= 0 && equals + 1 < text.length) {
      promotion = text[equals + 1].toLowerCase();
      text = text.substring(0, equals);
    }
    var piece = 'p';
    if (text.isNotEmpty && 'NBRQK'.contains(text[0])) {
      piece = text[0].toLowerCase();
      text = text.substring(1);
    }
    text = text.replaceAll('x', '');
    if (text.length < 2) return null;
    final to = text.substring(text.length - 2);
    final hint = text.substring(0, text.length - 2);
    final found = moves.where((m) {
      if (m.piece.name != piece || m.toAlgebraic != to) return false;
      if ((m.promotion?.name) != promotion) return false;
      final from = m.fromAlgebraic;
      // Désambiguïsation : colonne et/ou rangée de départ.
      return hint.split('').every(from.contains);
    }).toList();
    return found.length == 1 ? found.single : null;
  }

  /// Coup numéroté (ex. `3.d5`, `2...Nc6`) ; [letters] remplace les lettres
  /// des pièces `NBRQK` (ex. `CFTDR` en français).
  static String numbered(int ply, String san, {String letters = 'NBRQK'}) =>
      '${ply ~/ 2 + 1}.${ply.isEven ? '' : '..'}${localizeSan(san, letters)}';

  /// Suite de coups numérotée depuis le début (ex. `1.d4 d5 2.Bf4`).
  static String formatLine(List<String> moves, {String letters = 'NBRQK'}) => [
        for (final (ply, san) in moves.indexed)
          ply.isEven ? '${ply ~/ 2 + 1}.${localizeSan(san, letters)}' : localizeSan(san, letters),
      ].join(' ');

  /// [san] avec les lettres des pièces traduites ([letters] : équivalents
  /// de `NBRQK`).
  static String localizeSan(String san, String letters) {
    const english = 'NBRQK';
    if (letters.length != english.length) return san;
    return san.split('').map((c) {
      final index = english.indexOf(c);
      return index < 0 ? c : letters[index];
    }).join();
  }

  /// Position sans la prise en passant ni les compteurs de coups : deux
  /// parties arrivant à la même position par des chemins différents sont
  /// regroupées (la case « en passant » est notée après toute avance de deux
  /// cases, même sans prise possible).
  static String _positionKey(String fen) => fen.split(' ').take(3).join(' ');

  static T? _mostCommon<T>(Iterable<T> values) {
    final counts = <T, int>{};
    for (final v in values) {
      counts.update(v, (n) => n + 1, ifAbsent: () => 1);
    }
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }
}

/// Regroupe les coups du joueur par (position, coup). Les positions déjà
/// calculées pour un début de partie sont réutilisées : les parties d'une
/// même ouverture partagent leurs premiers coups, et rejouer un coup avec
/// le paquet `chess` est coûteux.
class _CandidateCollector {
  final bool white;
  final Map<String, _Group> _groups = {};

  /// Début de partie (coups séparés par des espaces) → position obtenue.
  final Map<String, String> _fenAfter = {};

  _CandidateCollector(this.white);

  static final String _startFen = Chess().fen;

  void add(CountryGame game) {
    final moves = game.openingMoves ?? const <String>[];
    final lost = game.result == 'loss';
    var fen = _startFen;
    var prefix = '';
    // Échiquier tenu à jour seulement quand une position n'est pas connue.
    Chess? board;
    for (var ply = 0; ply < moves.length; ply++) {
      final move = moves[ply];
      if (ply.isEven == white) {
        final group = _groups.putIfAbsent('${OpeningImprovementService._positionKey(fen)}|$move',
            () => _Group(fen, move, ply, moves.sublist(0, ply)));
        group.count++;
        if (lost) group.losses++;
      }
      prefix = '$prefix $move';
      final known = _fenAfter[prefix];
      if (known != null) {
        fen = known;
        board = null;
        continue;
      }
      board ??= Chess.fromFEN(fen);
      final legal = OpeningImprovementService.findSan(board, move);
      if (legal == null) break;
      board.move(legal);
      fen = board.fen;
      _fenAfter[prefix] = fen;
    }
  }

  List<OpeningCandidate> result() {
    final result = [
      for (final g in _groups.values)
        if (g.count >= OpeningImprovementService.minRepeats)
          OpeningCandidate(fen: g.fen, san: g.san, ply: g.ply, line: g.line, count: g.count, losses: g.losses),
    ];
    result.sort((a, b) => b.count != a.count ? b.count.compareTo(a.count) : a.ply.compareTo(b.ply));
    return result;
  }
}

class _Group {
  final String fen;
  final String san;
  final int ply;
  final List<String> line;
  int count = 0;
  int losses = 0;

  _Group(this.fen, this.san, this.ply, this.line);
}
