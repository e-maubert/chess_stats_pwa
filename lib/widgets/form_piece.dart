import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/scouting_service.dart';
import '../theme/app_theme.dart';

/// Pièce d'échecs illustrant la forme du moment : roi renversé (en crise),
/// pion, cavalier (stable), reine, double reine dorée (légendaire). Dessin
/// au trait du logo (`design/logo.svg`), sur un disque clair lisible dans
/// les deux thèmes.
class FormPiece extends StatelessWidget {
  final FormLevel level;
  final double size;

  const FormPiece({super.key, required this.level, this.size = 120});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.formColor(level.index);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF7F4EC),
        border: Border.all(color: color, width: size / 24),
        boxShadow: level == FormLevel.legendary
            ? [BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: size / 5, spreadRadius: size / 30)]
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.14),
        child: CustomPaint(painter: _PiecePainter(level, color)),
      ),
    );
  }
}

class _PiecePainter extends CustomPainter {
  final FormLevel level;
  final Color fill;

  _PiecePainter(this.level, this.fill);

  static const Color _outline = Color(0xFF2B2B2B);

  // Tracés dans un carré de 100 × 100, repris de design/logo.svg (roi,
  // reine, pion) ; cavalier dessiné dans le même style.
  static final List<Path> _king = [
    _path('M28 90 V84 C28 77 32 72 37 72 H63 C68 72 72 77 72 84 V90 Z'),
    _path('M31 63 H69 V72 H31 Z'),
    _path('M31 63 C17 55 17 35 30 34 C36 33 40 37 42 41 C41 33 45 28 50 28 C55 28 59 33 58 41 '
        'C60 37 64 33 70 34 C83 35 83 55 69 63 Z'),
    _path('M47 11 H53 V16 H58 V22 H53 V28 H47 V22 H42 V16 H47 Z'),
  ];
  static final List<Path> _kingLines = [
    _path('M42 41 C44 49 45 56 44 63'),
    _path('M58 41 C56 49 55 56 56 63'),
  ];

  static final List<Path> _queen = [
    _path('M28 90 V84 C28 78 32 74 37 74 H63 C68 74 72 78 72 84 V90 Z'),
    _path('M31 66 H69 V74 H31 Z'),
    _path('M31 66 L17 29 L37 49 L34 21 L46 47 L50 17 L54 47 L66 21 L63 49 L83 29 L69 66 Z'),
    for (final (x, y) in const [(17.0, 25.0), (34.0, 17.0), (50.0, 12.0), (66.0, 17.0), (83.0, 25.0)])
      Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: 4.5)),
  ];

  static final List<Path> _pawn = [
    _path('M26 90 C26 84 30 80 35 80 H65 C70 80 74 84 74 90 Z'),
    _path('M43 50 C44 63 39 74 33 80 H67 C61 74 56 63 57 50 Z'),
    Path()..addOval(Rect.fromCenter(center: const Offset(50, 47), width: 26, height: 8)),
    Path()..addOval(Rect.fromCircle(center: const Offset(50, 32), radius: 11)),
  ];

  static final List<Path> _knight = [
    _path('M26 90 C26 84 30 80 35 80 H65 C70 80 74 84 74 90 Z'),
    _path('M34 80 C33 68 38 60 47 53 C41 55 35 58 30 61 C24 64 19 59 22 53 C26 45 33 38 39 30 '
        'C42 24 46 20 51 18 L53 11 L58 18 C71 21 79 36 77 56 C76 66 71 74 68 80 Z'),
  ];
  static final List<Path> _knightLines = [
    _path('M59 25 C65 33 67 45 65 58'),
  ];
  static final Path _knightEye = Path()..addOval(Rect.fromCircle(center: const Offset(45, 32), radius: 2.5));

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 100);
    switch (level) {
      case FormLevel.collapse:
        // Roi renversé, couché sur le côté.
        canvas.save();
        canvas.translate(50, 54);
        canvas.rotate(-math.pi / 2 + 0.12);
        canvas.translate(-50, -50);
        _draw(canvas, _king, _kingLines);
        canvas.restore();
      case FormLevel.slump:
        _draw(canvas, _pawn, const []);
      case FormLevel.steady:
        _draw(canvas, _knight, _knightLines);
        canvas.drawPath(_knightEye, Paint()..color = _outline);
      case FormLevel.good:
        _draw(canvas, _queen, const []);
      case FormLevel.legendary:
        // Deux reines, l'une derrière l'autre.
        for (final dx in const [-15.0, 15.0]) {
          canvas.save();
          canvas.translate(50 + dx, 50 + (dx < 0 ? -3 : 5));
          canvas.scale(0.78);
          canvas.translate(-50, -50);
          _draw(canvas, _queen, const []);
          canvas.restore();
        }
    }
  }

  void _draw(Canvas canvas, List<Path> shapes, List<Path> lines) {
    final fillPaint = Paint()..color = fill;
    final stroke = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    for (final shape in shapes) {
      canvas.drawPath(shape, fillPaint);
      canvas.drawPath(shape, stroke);
    }
    for (final line in lines) {
      canvas.drawPath(line, stroke);
    }
  }

  @override
  bool shouldRepaint(_PiecePainter oldDelegate) => oldDelegate.level != level || oldDelegate.fill != fill;

  /// Tracé SVG simple, en coordonnées absolues : M, L, H, V, C, Z.
  static Path _path(String data) {
    final tokens = RegExp(r'[MLHVCZ]|-?\d+(?:\.\d+)?').allMatches(data).map((m) => m.group(0)!).toList();
    final path = Path();
    var i = 0;
    var command = 'M';
    var x = 0.0;
    var y = 0.0;
    double next() => double.parse(tokens[i++]);
    while (i < tokens.length) {
      if (RegExp(r'[A-Z]').hasMatch(tokens[i])) command = tokens[i++];
      switch (command) {
        case 'M':
          x = next();
          y = next();
          path.moveTo(x, y);
          command = 'L';
        case 'L':
          x = next();
          y = next();
          path.lineTo(x, y);
        case 'H':
          x = next();
          path.lineTo(x, y);
        case 'V':
          y = next();
          path.lineTo(x, y);
        case 'C':
          final x1 = next(), y1 = next(), x2 = next(), y2 = next();
          x = next();
          y = next();
          path.cubicTo(x1, y1, x2, y2, x, y);
        case 'Z':
          path.close();
      }
    }
    return path;
  }
}
