import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Camembert du temps à un moment de la partie : moitié haute pour le
/// joueur, moitié basse pour l'adversaire, séparées par une ligne
/// horizontale. Dans chaque moitié, le temps restant part de la gauche ; le
/// reste, à droite (temps écoulé), est hachuré. Seul le temps
/// restant du joueur est en couleur ([playerColor]) : on voit d'un coup
/// d'œil qui a le plus de temps.
class ClockPie extends StatelessWidget {
  /// Temps restant en part du temps initial (ramené entre 0 et 1).
  final double player;
  final double opponent;
  final Color playerColor;
  final double size;
  final String semanticsLabel;

  const ClockPie({
    super.key,
    required this.player,
    required this.opponent,
    required this.playerColor,
    required this.semanticsLabel,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _ClockPiePainter(
            player: player.clamp(0, 1),
            opponent: opponent.clamp(0, 1),
            playerColor: playerColor,
            remainingColor: colors.outline,
            elapsedColor: colors.surfaceContainerHighest,
            hatchColor: colors.outline.withValues(alpha: 0.45),
            separatorColor: colors.surfaceContainerLow,
          ),
        ),
      ),
    );
  }
}

/// Petit carré hachuré pour la légende (temps écoulé).
class HatchedSwatch extends StatelessWidget {
  final double size;

  const HatchedSwatch({super.key, this.size = 12});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _HatchPainter(
            background: colors.surfaceContainerHighest,
            stripe: colors.outline.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}

class _HatchPainter extends CustomPainter {
  final Color background;
  final Color stripe;

  _HatchPainter({required this.background, required this.stripe});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final paint = Paint()
      ..color = stripe
      ..strokeWidth = 1.5;
    for (var x = -size.height; x < size.width; x += 4) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_HatchPainter old) => old.background != background || old.stripe != stripe;
}

class _ClockPiePainter extends CustomPainter {
  final double player;
  final double opponent;
  final Color playerColor;
  final Color remainingColor;
  final Color elapsedColor;
  final Color hatchColor;
  final Color separatorColor;

  _ClockPiePainter({
    required this.player,
    required this.opponent,
    required this.playerColor,
    required this.remainingColor,
    required this.elapsedColor,
    required this.hatchColor,
    required this.separatorColor,
  });

  /// Côté gauche du cercle (angle 0 = droite, sens horaire positif).
  static const double _left = math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2;
    final circle = Rect.fromCircle(center: center, radius: radius);

    // Moitié haute (joueur) : de la gauche vers la droite en passant par le
    // haut (sens horaire) ; moitié basse (adversaire) : par le bas.
    _slice(canvas, circle, _left, math.pi * player, playerColor);
    _hatched(canvas, circle, _left + math.pi * player, math.pi * (1 - player));
    _slice(canvas, circle, _left, -math.pi * opponent, remainingColor);
    _hatched(canvas, circle, _left - math.pi * opponent, -math.pi * (1 - opponent));

    // Trait horizontal séparant les deux moitiés.
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      Paint()
        ..color = separatorColor
        ..strokeWidth = 2,
    );
  }

  Path _path(Rect circle, double start, double sweep) => Path()
    ..moveTo(circle.center.dx, circle.center.dy)
    ..arcTo(circle, start, sweep, false)
    ..close();

  void _slice(Canvas canvas, Rect circle, double start, double sweep, Color color) {
    if (sweep.abs() < 1e-6) return;
    canvas.drawPath(_path(circle, start, sweep), Paint()..color = color);
  }

  /// Temps écoulé : fond gris clair et rayures diagonales.
  void _hatched(Canvas canvas, Rect circle, double start, double sweep) {
    if (sweep.abs() < 1e-6) return;
    final path = _path(circle, start, sweep);
    canvas.drawPath(path, Paint()..color = elapsedColor);
    canvas.save();
    canvas.clipPath(path);
    final stripes = Paint()
      ..color = hatchColor
      ..strokeWidth = 2;
    const gap = 7.0;
    for (var x = circle.left - circle.height; x < circle.right; x += gap) {
      canvas.drawLine(Offset(x, circle.bottom), Offset(x + circle.height, circle.top), stripes);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ClockPiePainter old) =>
      old.player != player ||
      old.opponent != opponent ||
      old.playerColor != playerColor ||
      old.remainingColor != remainingColor ||
      old.elapsedColor != elapsedColor ||
      old.hatchColor != hatchColor;
}
