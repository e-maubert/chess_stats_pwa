import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import '../services/playing_hours_service.dart';
import '../theme/app_theme.dart';

/// Éléments communs aux cartes Heures de jeu et Jours de jeu : légendes
/// Activité / Performance, hachures, bulle de détail.

/// Pourcentage arrondi d'un score entre 0 et 1.
int percentOf(double score) => (score * 100).round();

/// Légende du mode Activité : de 1 partie à [maxGames], du bleu clair au
/// bleu foncé.
class ActivityLegend extends StatelessWidget {
  final int maxGames;

  const ActivityLegend({super.key, required this.maxGames});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final small = Theme.of(context).textTheme.bodySmall;
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(l10n.countryMapLegend, style: small),
        const SizedBox(width: 4),
        Text('1', style: small),
        for (var i = 0; i <= 4; i++) LegendSwatch(AppTheme.mapCountryColor(i / 4)),
        Text('$maxGames', style: small),
      ],
    );
  }
}

/// Légende du mode Performance : les 5 classes, puis les hachures (pas assez
/// de parties).
class PerformanceLegend extends StatelessWidget {
  const PerformanceLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final small = Theme.of(context).textTheme.bodySmall;
    final labels = [
      l10n.playingHoursBandVeryLow,
      l10n.playingHoursBandLow,
      l10n.playingHoursBandEven,
      l10n.playingHoursBandHigh,
      l10n.playingHoursBandVeryHigh,
    ];
    Widget item(Widget swatch, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [swatch, const SizedBox(width: 6), Text(label, style: small)],
        );
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        for (var i = 0; i < labels.length; i++) item(LegendSwatch(AppTheme.performanceBandColor(i)), labels[i]),
        item(
          SizedBox(
            width: 14,
            height: 10,
            child: CustomPaint(
              painter: HatchPainter(
                background: AppTheme.mapEmptyCountry(context),
                line: AppTheme.mapNotEnoughGames(context),
              ),
            ),
          ),
          l10n.countryMapNotEnoughLegend(PlayingHoursService.minGames),
        ),
      ],
    );
  }
}

/// Petit rectangle de couleur d'une légende.
class LegendSwatch extends StatelessWidget {
  final Color color;

  const LegendSwatch(this.color, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: 14,
        height: 10,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
      );
}

/// Hachures des créneaux ou des jours qui n'ont pas assez de parties pour
/// juger la performance.
class HatchPainter extends CustomPainter {
  final Color background;
  final Color line;

  HatchPainter({required this.background, required this.line});

  static void paintHatch(Canvas canvas, Rect bounds, Color background, Color line) {
    canvas.drawRect(bounds, Paint()..color = background);
    final paint = Paint()
      ..color = line
      ..strokeWidth = 1.2;
    const spacing = 5.0;
    for (var x = bounds.left - bounds.height; x < bounds.right; x += spacing) {
      canvas.drawLine(Offset(x, bounds.bottom), Offset(x + bounds.height, bounds.top), paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(2)));
    paintHatch(canvas, Offset.zero & size, background, line);
    canvas.restore();
  }

  @override
  bool shouldRepaint(HatchPainter old) => old.background != background || old.line != line;
}

/// Bulle de détail (titre, puis chiffres en gras), au-dessus de [anchor]
/// (en dessous s'il n'y a pas la place), gardée dans la largeur de [area].
/// Même aspect que la bulle de la carte des pays. À placer dans un `Stack`.
class StatsBubble extends StatelessWidget {
  final Offset anchor;
  final Size area;
  final (String, String) text;

  /// Écart entre [anchor] et la bulle.
  final double gap;

  const StatsBubble({super.key, required this.anchor, required this.area, required this.text, this.gap = 8});

  /// [text] avec ses nombres en gras (« 54 parties · V 38 · N 6 · D 10 »).
  static List<TextSpan> _boldNumbers(String text) {
    final spans = <TextSpan>[];
    var start = 0;
    for (final match in RegExp(r'\d+([.,]\d+)?').allMatches(text)) {
      if (match.start > start) spans.add(TextSpan(text: text.substring(start, match.start)));
      spans.add(TextSpan(text: match[0], style: const TextStyle(fontWeight: FontWeight.bold)));
      start = match.end;
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (title, detail) = text;
    const maxWidth = 260.0;
    const height = 52.0; // deux lignes
    final width = math.min(maxWidth, area.width);
    final left = (anchor.dx - width / 2).clamp(0.0, math.max(0.0, area.width - width)).toDouble();
    final above = anchor.dy - height - gap;
    final top = above >= 0 ? above : anchor.dy + gap + 4;
    return Positioned(
      left: left,
      top: top,
      width: width,
      child: IgnorePointer(
        child: Center(
          child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(6),
            color: theme.colorScheme.inverseSurface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onInverseSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text.rich(
                    TextSpan(children: _boldNumbers(detail)),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onInverseSurface),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
