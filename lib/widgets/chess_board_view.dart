import 'package:flutter/material.dart';

/// Flèche dessinée sur l'échiquier, d'une case à une autre (ex. `e2`, `e4`).
class BoardArrow {
  final String from;
  final String to;
  final Color color;

  const BoardArrow(this.from, this.to, this.color);
}

/// Échiquier statique : position [fen], vue du côté des blancs ou des noirs
/// ([flipped]), avec des flèches. Pièces dessinées avec les symboles Unicode
/// des échecs (en attendant un jeu de pièces dessiné pour l'app).
class ChessBoardView extends StatelessWidget {
  final String fen;
  final bool flipped;
  final List<BoardArrow> arrows;

  /// Description pour les lecteurs d'écran.
  final String? semanticLabel;

  const ChessBoardView({
    super.key,
    required this.fen,
    this.flipped = false,
    this.arrows = const [],
    this.semanticLabel,
  });

  /// Couleurs des cases, celles de l'échiquier du logo (fixes :
  /// l'échiquier est lisible dans les deux thèmes).
  static const Color lightSquare = Color(0xFFEDE6D6);
  static const Color darkSquare = Color(0xFF3F6DB3);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: ExcludeSemantics(
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CustomPaint(painter: _BoardPainter(fen, flipped, arrows)),
          ),
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  final String fen;
  final bool flipped;
  final List<BoardArrow> arrows;

  _BoardPainter(this.fen, this.flipped, this.arrows);

  /// Décalage vertical des pièces vers le bas, en fraction de case.
  static const double _glyphDrop = 0.11;

  /// Symboles pleins (♚…♟) pour les deux camps, suivis du sélecteur
  /// « texte » pour éviter un rendu en émoji.
  static const Map<String, String> _glyphs = {
    'k': '♚',
    'q': '♛',
    'r': '♜',
    'b': '♝',
    'n': '♞',
    'p': '♟',
  };

  /// Colonne (0 = a) et rangée (0 = 1) → coin haut gauche de la case.
  Offset _origin(int file, int rank, double square) =>
      flipped ? Offset((7 - file) * square, rank * square) : Offset(file * square, (7 - rank) * square);

  Offset _center(String name, double square) {
    final file = name.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rank = int.parse(name[1]) - 1;
    return _origin(file, rank, square) + Offset(square / 2, square / 2);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final square = size.width / 8;
    for (var file = 0; file < 8; file++) {
      for (var rank = 0; rank < 8; rank++) {
        final light = (file + rank).isOdd;
        canvas.drawRect(
          _origin(file, rank, square) & Size(square, square),
          Paint()..color = light ? ChessBoardView.lightSquare : ChessBoardView.darkSquare,
        );
      }
    }
    _paintCoordinates(canvas, square);
    _paintPieces(canvas, square);
    for (final arrow in arrows) {
      _paintArrow(canvas, square, arrow);
    }
  }

  void _paintCoordinates(Canvas canvas, double square) {
    for (var i = 0; i < 8; i++) {
      // Lettres sur la rangée du bas, chiffres sur la colonne de gauche, de
      // la couleur des cases claires sur une case foncée et inversement.
      final file = flipped ? 7 - i : i;
      final rank = flipped ? 7 - i : i;
      _text(canvas, String.fromCharCode('a'.codeUnitAt(0) + file), square * 0.18,
          i.isEven ? ChessBoardView.lightSquare : ChessBoardView.darkSquare,
          topLeft: Offset(i * square + square * 0.78, square * 8 - square * 0.26));
      _text(canvas, '${rank + 1}', square * 0.18, i.isEven ? ChessBoardView.lightSquare : ChessBoardView.darkSquare,
          topLeft: Offset(square * 0.05, (7 - i) * square + square * 0.03));
    }
  }

  void _paintPieces(Canvas canvas, double square) {
    final rows = fen.split(' ').first.split('/');
    for (var row = 0; row < rows.length && row < 8; row++) {
      var file = 0;
      for (final char in rows[row].split('')) {
        final empty = int.tryParse(char);
        if (empty != null) {
          file += empty;
          continue;
        }
        final glyph = '${_glyphs[char.toLowerCase()] ?? ''}︎';
        final white = char.toUpperCase() == char;
        // Les symboles sont dessinés plus haut que le centre de leur ligne
        // de texte : on les descend pour les centrer dans la case (mesuré
        // avec la police de secours de Flutter web, Noto Sans Symbols 2).
        final center = _origin(file, 7 - row, square) + Offset(square / 2, square * (0.5 + _glyphDrop));
        final style = TextStyle(fontSize: square * 0.78, height: 1);
        // Contour, puis remplissage : pièces blanches claires bordées de
        // noir, pièces noires pleines.
        _centered(
          canvas,
          glyph,
          style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = square * 0.05
              ..strokeJoin = StrokeJoin.round
              ..color = const Color(0xFF1A1A1A),
          ),
          center,
        );
        _centered(
            canvas, glyph, style.copyWith(color: white ? const Color(0xFFFAFAFA) : const Color(0xFF1A1A1A)), center);
        file++;
      }
    }
  }

  void _paintArrow(Canvas canvas, double square, BoardArrow arrow) {
    final start = _center(arrow.from, square);
    final end = _center(arrow.to, square);
    final direction = end - start;
    final length = direction.distance;
    if (length == 0) return;
    final unit = direction / length;
    final head = square * 0.42;
    final width = square * 0.16;
    final shaftEnd = end - unit * head;
    final paint = Paint()
      ..color = arrow.color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start + unit * square * 0.15, shaftEnd, paint);
    final normal = Offset(-unit.dy, unit.dx);
    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(shaftEnd.dx + normal.dx * head * 0.6, shaftEnd.dy + normal.dy * head * 0.6)
      ..lineTo(shaftEnd.dx - normal.dx * head * 0.6, shaftEnd.dy - normal.dy * head * 0.6)
      ..close();
    canvas.drawPath(path, Paint()..color = arrow.color);
  }

  void _centered(Canvas canvas, String text, TextStyle style, Offset center) {
    final painter = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
  }

  void _text(Canvas canvas, String text, double size, Color color, {required Offset topLeft}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: size, color: color, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, topLeft);
  }

  @override
  bool shouldRepaint(_BoardPainter old) => old.fen != fen || old.flipped != flipped || old.arrows != arrows;
}
