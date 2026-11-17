import 'package:chess/chess.dart';

import '../models/country_game.dart';
import '../models/game_phase_summary.dart';
import 'game_storage_policy.dart';

/// Moments clés d'une partie, trouvés en rejouant ses coups (sans moteur).
/// Les demi-coups sont comptés à partir de 1 (1 = premier coup des blancs) ;
/// null si le moment n'est jamais atteint.
class GamePhases {
  /// Nombre de demi-coups joués (lus et rejoués).
  final int plies;

  /// Fin de l'ouverture, règle du développement : pour les deux camps,
  /// cavaliers et fous ont quitté leur case de départ et le roi a bougé
  /// (ou roqué).
  final int? developedPly;

  /// Fin de l'ouverture, règle inspirée de Lichess (secours quand le
  /// développement n'est jamais complet) : au plus 10 pièces (hors rois et
  /// pions), ou moins de 4 pièces sur la première rangée d'un camp.
  final int? lichessMiddlegamePly;

  /// Entrée en finale : au plus 6 pièces (hors rois et pions).
  final int? endgamePly;

  /// Matériel à l'entrée en finale, blancs moins noirs (pion 1, cavalier et
  /// fou 3, tour 5, dame 9), mesuré une fois l'échange en cours terminé
  /// (pas juste après une prise) ; null sans finale.
  final int? endgameMaterial;

  /// Type de finale ([GamePhaseService.endgameTypeOf]) ; null sans finale.
  final String? endgameType;

  /// Pendule après chaque demi-coup, en secondes (null si absente).
  final List<double?> clocks;

  const GamePhases({
    required this.plies,
    this.developedPly,
    this.lichessMiddlegamePly,
    this.endgamePly,
    this.endgameMaterial,
    this.endgameType,
    this.clocks = const [],
  });

  /// Fin de l'ouverture retenue : développement, sinon règle Lichess.
  int? get middlegamePly => developedPly ?? lichessMiddlegamePly;

  /// Pendule du camp [white] juste après le demi-coup [ply] (sa dernière
  /// valeur connue à ce moment), null si inconnue.
  double? clockAt(int ply, {required bool white}) {
    for (var index = ply - 1; index >= 0; index--) {
      // Indice pair = coup des blancs.
      if (index.isEven == white) return clocks[index];
    }
    return null;
  }
}

class GamePhaseService {
  static final RegExp _move = RegExp(
    r'\d+\.{1,3}\s+([^\s{]+)(?:\s+\{\[%clk (\d+):(\d+):(\d+(?:\.\d+)?)\]\})?',
  );
  static final RegExp _result = RegExp(r'^(1-0|0-1|1/2-1/2|\*)$');

  static const Map<String, int> _values = {'p': 1, 'n': 3, 'b': 3, 'r': 5, 'q': 9, 'k': 0};

  // Cases de départ à quitter (indices 0x88 de chess.js : a8 = 0, a1 = 112).
  static const List<int> _whiteStart = [113, 114, 117, 118, 116]; // b1 c1 f1 g1 e1
  static const List<int> _blackStart = [1, 2, 5, 6, 4]; // b8 c8 f8 g8 e8

  /// Partie « coups » d'un PGN chess.com (sans les en-têtes), seule utile au
  /// calcul des phases ; null si [pgn] est vide.
  static String? moveText(String? pgn) {
    if (pgn == null) return null;
    final start = pgn.indexOf('\n\n');
    final text = (start < 0 ? pgn : pgn.substring(start)).trim();
    return text.isEmpty ? null : text;
  }

  /// Résumé des phases de [game] vu du joueur ; null si ses coups sont
  /// inconnus.
  static GamePhaseSummary? summarize(CountryGame game) {
    final moves = game.moves;
    if (moves == null) return null;
    final phases = analyze(moves);
    final white = game.playerColor == 'white';
    final middlegame = phases.middlegamePly;
    final endgame = phases.endgamePly;
    return GamePhaseSummary(
      endPhase: endgame != null
          ? GamePhase.endgame
          : middlegame != null
              ? GamePhase.middlegame
              : GamePhase.opening,
      playerClockAtMiddlegame: middlegame == null ? null : phases.clockAt(middlegame, white: white),
      opponentClockAtMiddlegame: middlegame == null ? null : phases.clockAt(middlegame, white: !white),
      playerClockAtEndgame: endgame == null ? null : phases.clockAt(endgame, white: white),
      opponentClockAtEndgame: endgame == null ? null : phases.clockAt(endgame, white: !white),
      endgameMaterial: phases.endgameMaterial == null ? null : (white ? 1 : -1) * phases.endgameMaterial!,
      endgameType: phases.endgameType,
    );
  }

  /// Rejoue les coups de [moveText] (PGN chess.com, en-têtes facultatifs),
  /// jusqu'au premier coup illisible.
  static GamePhases analyze(String moveText) {
    final chess = Chess();
    final touched = <int>{};
    final clocks = <double?>[];
    int? developedPly;
    int? lichessPly;
    int? endgamePly;
    int? endgameMaterial;
    String? endgameType;
    var material = 0;

    for (final match in _move.allMatches(moveText)) {
      final san = match.group(1)!;
      if (_result.hasMatch(san)) break;
      final resolved = _resolve(chess, san);
      if (resolved == null || !chess.move(resolved)) break;
      touched
        ..add(resolved.from)
        ..add(resolved.to);
      clocks.add(match.group(2) == null
          ? null
          : int.parse(match.group(2)!) * 3600 + int.parse(match.group(3)!) * 60 + double.parse(match.group(4)!));
      final ply = clocks.length;

      if (developedPly == null && _whiteStart.every(touched.contains) && _blackStart.every(touched.contains)) {
        developedPly = ply;
      }
      if (lichessPly != null && endgameMaterial != null) continue;

      var pieces = 0;
      var whiteBackRank = 0;
      var blackBackRank = 0;
      final kinds = <String>{};
      material = 0;
      for (var square = 0; square < 128; square++) {
        if (square & 0x88 != 0) continue;
        final piece = chess.board[square];
        if (piece == null) continue;
        final name = piece.type.name;
        final white = piece.color == Color.WHITE;
        material += white ? _values[name]! : -_values[name]!;
        if (name != 'p' && name != 'k') {
          pieces++;
          kinds.add(name);
        }
        if (white && square >= 112) whiteBackRank++;
        if (!white && square < 8) blackBackRank++;
      }
      if (lichessPly == null && (pieces <= 10 || whiteBackRank < 4 || blackBackRank < 4)) {
        lichessPly = ply;
      }
      if (endgamePly == null && pieces <= 6) {
        endgamePly = ply;
        endgameType = endgameTypeOf(kinds);
      }
      // Matériel compté hors échange en cours : pas juste après une prise.
      if (endgamePly != null && endgameMaterial == null && resolved.captured == null) {
        endgameMaterial = material;
      }
    }
    // Partie finie sur une prise juste après l'entrée en finale.
    if (endgamePly != null) endgameMaterial ??= material;

    return GamePhases(
      plies: clocks.length,
      developedPly: developedPly,
      lichessMiddlegamePly: lichessPly,
      endgamePly: endgamePly,
      endgameMaterial: endgameMaterial,
      endgameType: endgameType,
      clocks: clocks,
    );
  }

  /// Type de finale selon les pièces restantes (hors rois et pions, des
  /// deux camps) : 'pawn' (aucune), 'minor' (cavaliers / fous), 'rook'
  /// (tours seules), 'rookMinor' (tours et pièces mineures), 'queen' (dames
  /// seules), 'queenOther' (dames et autres pièces).
  static String endgameTypeOf(Set<String> kinds) {
    if (kinds.isEmpty) return 'pawn';
    if (kinds.contains('q')) return kinds.length == 1 ? 'queen' : 'queenOther';
    if (kinds.contains('r')) return kinds.length == 1 ? 'rook' : 'rookMinor';
    return 'minor';
  }

  /// Parties de [games] dont les phases restent à calculer : ni stockées
  /// dans la partie, ni dans [known] (identité de la partie → résumé).
  static List<CountryGame> pending(Iterable<CountryGame> games, Map<String, GamePhaseSummary?> known) => [
        for (final game in games)
          if (game.phases == null && !known.containsKey(GameStoragePolicy.identity(game))) game,
      ];

  /// [games] avec leurs phases (stockées, sinon prises dans [known]) ; les
  /// parties sans coups lisibles sont écartées. null s'il en manque encore.
  static List<CountryGame>? withPhases(List<CountryGame> games, Map<String, GamePhaseSummary?> known) {
    final result = <CountryGame>[];
    for (final game in games) {
      if (game.phases != null) {
        result.add(game);
        continue;
      }
      final key = GameStoragePolicy.identity(game);
      if (!known.containsKey(key)) return null;
      final phases = known[key];
      if (phases != null) result.add(game.withPhases(phases));
    }
    return result;
  }

  static final RegExp _san = RegExp(r'^([NBRQK])?([a-h])?([1-8])?x?([a-h][1-8])(?:=?([NBRQ]))?$');

  /// Coup légal correspondant à la notation [san], sans recalculer la
  /// notation de chaque coup possible (ce que fait Chess.move(String),
  /// six fois plus lent sur des milliers de parties).
  static Move? _resolve(Chess chess, String san) {
    final clean = san.replaceAll(RegExp(r'[+#!?]'), '');
    final moves = chess.generate_moves();
    if (clean == 'O-O' || clean == '0-0') {
      return _first(moves, (m) => m.flags & Chess.BITS_KSIDE_CASTLE != 0);
    }
    if (clean == 'O-O-O' || clean == '0-0-0') {
      return _first(moves, (m) => m.flags & Chess.BITS_QSIDE_CASTLE != 0);
    }
    final match = _san.firstMatch(clean);
    if (match == null) return null;
    final type = (match.group(1) ?? 'p').toLowerCase();
    final fromFile = match.group(2);
    final fromRank = match.group(3);
    final to = match.group(4)!;
    final promotion = match.group(5)?.toLowerCase();
    return _first(moves, (m) {
      if (m.piece.name != type || Chess.algebraic(m.to) != to) return false;
      final from = Chess.algebraic(m.from);
      if (fromFile != null && from[0] != fromFile) return false;
      if (fromRank != null && from[1] != fromRank) return false;
      return m.promotion?.name == promotion;
    });
  }

  static Move? _first(List<Move> moves, bool Function(Move) test) {
    for (final move in moves) {
      if (test(move)) return move;
    }
    return null;
  }
}
