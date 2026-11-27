import 'package:chess/chess.dart';

import 'opening_improvement_service.dart';

/// Pièce qui glisse d'une case à une autre pendant un coup (ex. `e2` → `e4`).
typedef PieceSlide = ({String from, String to});

/// Un coup de la suite rejouée : position avant et après, et pièces qui
/// bougent (deux pour un roque).
class ReplayStep {
  /// Demi-coup (0 = premier coup des blancs).
  final int ply;
  final String san;
  final String fenBefore;
  final String fenAfter;
  final List<PieceSlide> slides;

  const ReplayStep({
    required this.ply,
    required this.san,
    required this.fenBefore,
    required this.fenAfter,
    required this.slides,
  });

  /// Case de départ et d'arrivée du coup (celles du roi pour un roque).
  PieceSlide get move => slides.first;
}

/// Suite d'une ouverture rejouée coup par coup depuis la position de départ,
/// pour l'animer sur l'échiquier.
class OpeningReplayService {
  /// Position de départ (FEN).
  static final String startFen = Chess().fen;

  /// Les coups de [line] (SAN) joués depuis la position de départ ; s'arrête
  /// au premier coup illisible ou illégal.
  static List<ReplayStep> replay(List<String> line) {
    final board = Chess();
    final steps = <ReplayStep>[];
    for (final (ply, san) in line.indexed) {
      final move = OpeningImprovementService.findSan(board, san);
      if (move == null) break;
      final before = board.fen;
      final slides = <PieceSlide>[(from: move.fromAlgebraic, to: move.toAlgebraic)];
      final rook = _castlingRook(move);
      if (rook != null) slides.add(rook);
      board.make_move(move);
      steps.add(ReplayStep(ply: ply, san: san, fenBefore: before, fenAfter: board.fen, slides: slides));
    }
    return steps;
  }

  /// Déplacement de la tour d'un roque, null pour un autre coup.
  static PieceSlide? _castlingRook(Move move) {
    final rank = move.color == Color.WHITE ? '1' : '8';
    if (move.flags & Chess.BITS_KSIDE_CASTLE != 0) return (from: 'h$rank', to: 'f$rank');
    if (move.flags & Chess.BITS_QSIDE_CASTLE != 0) return (from: 'a$rank', to: 'd$rank');
    return null;
  }
}
