import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/country_game.dart';
import '../services/playing_hours_service.dart';
import '../theme/app_theme.dart';
import '../viewmodels/playing_hours_viewmodel.dart';
import 'time_class_filter.dart';

/// Page principale : cadran de 24 h des parties de la période selon leur heure
/// de début, en nombre de parties (activité) ou en performance, avec le
/// meilleur et le moins bon créneau. Filtrable par cadence.
class PlayingHoursCard extends StatelessWidget {
  final List<CountryGame> games;

  const PlayingHoursCard({super.key, required this.games});

  static const double _maxDialSize = 360;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return ChangeNotifierProvider(
      // Nouvelle liste (ex. après « Actualiser ») => nouveau viewmodel.
      key: ObjectKey(games),
      create: (_) => PlayingHoursViewModel(games),
      child: Consumer<PlayingHoursViewModel>(
        builder: (context, viewModel, child) {
          final hours = viewModel.hours;
          final total = hours.fold<int>(0, (sum, h) => sum + h.games);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.playingHours,
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TimeClassFilter(
                timeClasses: PlayingHoursViewModel.timeClasses,
                selected: viewModel.timeClass,
                onSelected: viewModel.setTimeClass,
              ),
              const SizedBox(height: 16),
              if (total == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text(l10n.noCountryData)),
                )
              else ...[
                SegmentedButton<PlayingHoursMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: PlayingHoursMode.activity,
                      icon: const Icon(Icons.schedule),
                      label: Text(l10n.playingHoursModeActivity),
                    ),
                    ButtonSegment(
                      value: PlayingHoursMode.performance,
                      icon: const Icon(Icons.trending_up),
                      label: Text(l10n.playingHoursModePerformance),
                    ),
                  ],
                  selected: {viewModel.mode},
                  onSelectionChanged: (selection) => viewModel.setMode(selection.first),
                ),
                const SizedBox(height: 8),
                Text(l10n.playingHoursHint, style: textTheme.bodySmall),
                const SizedBox(height: 8),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _maxDialSize),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _Dial(hours: hours, total: total, viewModel: viewModel),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (viewModel.mode == PlayingHoursMode.activity)
                  _activityLegend(context, PlayingHoursService.maxGames(hours), l10n)
                else
                  _performanceLegend(context, l10n),
                const SizedBox(height: 12),
                _summary(context, hours, viewModel, l10n),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _activityLegend(BuildContext context, int maxGames, AppLocalizations l10n) {
    final small = Theme.of(context).textTheme.bodySmall;
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(l10n.countryMapLegend, style: small),
        const SizedBox(width: 4),
        Text('1', style: small),
        for (var i = 0; i <= 4; i++) _swatch(AppTheme.mapCountryColor(i / 4)),
        Text('$maxGames', style: small),
      ],
    );
  }

  Widget _performanceLegend(BuildContext context, AppLocalizations l10n) {
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
        for (var i = 0; i < labels.length; i++) item(_swatch(AppTheme.performanceBandColor(i)), labels[i]),
        item(
          SizedBox(
            width: 14,
            height: 10,
            child: CustomPaint(
              painter: _HatchPainter(
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

  Widget _swatch(Color color) => Container(
        width: 14,
        height: 10,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
      );

  /// Meilleur et moins bon créneau, parmi les heures d'au moins
  /// [PlayingHoursService.minGames] parties. Chaque créneau est un lien
  /// qui le montre sur le cadran en mode Performance.
  Widget _summary(
    BuildContext context,
    List<HourStats> hours,
    PlayingHoursViewModel viewModel,
    AppLocalizations l10n,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final link = Theme.of(context).colorScheme.primary;
    final result = PlayingHoursService.bestAndWorst(hours);
    if (result == null) {
      return Text(l10n.playingHoursNoneJudged(PlayingHoursService.minGames), style: textTheme.bodySmall);
    }

    Widget line(IconData icon, Color color, String label, HourStats stats) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Wrap(
                spacing: 4,
                children: [
                  Text(label, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => viewModel.showHour(stats.hour),
                      child: Text(
                        l10n.playingHoursSlot(
                          l10n.playingHoursRange(stats.hour, stats.hour + 1),
                          _percent(stats.score),
                          stats.games,
                        ),
                        style: textTheme.bodyMedium?.copyWith(
                          color: link,
                          decoration: TextDecoration.underline,
                          decorationColor: link,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        line(Icons.trending_up, AppTheme.positiveText(context), l10n.playingHoursBest, result.best),
        if (result.worst != null) ...[
          const SizedBox(height: 4),
          line(Icons.trending_down, AppTheme.negativeText(context), l10n.playingHoursWorst, result.worst!),
        ],
      ],
    );
  }
}

/// Pourcentage arrondi d'un score entre 0 et 1.
int _percent(double score) => (score * 100).round();

/// Texte de la bulle d'une heure dans le mode affiché : la tranche, puis
/// ses chiffres.
(String, String) _bubbleText(HourStats stats, PlayingHoursMode mode, AppLocalizations l10n) {
  final title = l10n.playingHoursRange(stats.hour, stats.hour + 1);
  if (mode == PlayingHoursMode.activity) return (title, l10n.countryMapGames(stats.games));
  if (!stats.judged) {
    return (title, l10n.playingHoursNotEnoughDetail(stats.games, PlayingHoursService.minGames));
  }
  return (
    title,
    l10n.playingHoursPerformanceDetail(_percent(stats.score), stats.games, stats.wins, stats.draws, stats.losses),
  );
}

/// Cadran de 24 h, minuit en haut : une tranche par heure, colorée selon le
/// mode. Un clic sur une tranche affiche sa bulle de détail au-dessus
/// d'elle ; un nouveau clic, ou un clic hors des tranches, la ferme.
class _Dial extends StatelessWidget {
  final List<HourStats> hours;
  final int total;
  final PlayingHoursViewModel viewModel;

  const _Dial({required this.hours, required this.total, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final maxGames = PlayingHoursService.maxGames(hours);
    final performance = viewModel.mode == PlayingHoursMode.performance;

    // Couleur de chaque tranche ; null = hachurée (pas assez de parties).
    final colors = [
      for (final h in hours)
        if (!performance)
          h.games == 0 ? AppTheme.mapEmptyCountry(context) : AppTheme.mapCountryColor(h.games / maxGames)
        else if (h.judged)
          AppTheme.performanceBandColor(PlayingHoursService.band(h.score).index)
        else
          null,
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.biggest;
      final selected = viewModel.selectedHour;

      return Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTapUp: (details) => viewModel.tapHour(_DialPainter.hourAt(details.localPosition, size)),
            child: CustomPaint(
              size: size,
              painter: _DialPainter(
                colors: colors,
                emptyColor: AppTheme.mapEmptyCountry(context),
                hatchColor: AppTheme.mapNotEnoughGames(context),
                // Séparation des tranches de la couleur du fond de page.
                gapColor: Theme.of(context).scaffoldBackgroundColor,
                selectedColor: AppTheme.mapSelectedBorder(context),
                selectedHour: viewModel.selectedHour,
                labels: [for (var h = 0; h < 24; h += 3) l10n.playingHoursHourLabel(h)],
                labelStyle: textTheme.bodySmall!.copyWith(color: scheme.onSurfaceVariant),
                centerText: l10n.countryMapGames(total),
                centerStyle: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: scheme.onSurface),
              ),
            ),
          ),
          if (selected != null)
            _HourBubble(
              anchor: _DialPainter.sliceCenter(selected, size),
              area: size,
              text: _bubbleText(hours[selected], viewModel.mode, l10n),
            ),
        ],
      );
    });
  }
}

/// Bulle de détail d'une heure, au-dessus du milieu de sa tranche (en
/// dessous s'il n'y a pas la place), gardée dans la largeur du cadran.
/// Même aspect que la bulle de la carte des pays.
class _HourBubble extends StatelessWidget {
  final Offset anchor;
  final Size area;
  final (String, String) text;

  const _HourBubble({required this.anchor, required this.area, required this.text});

  /// [text] avec ses nombres en gras (« 54 parties · V 38 · N 6 · D 10 »).
  static List<TextSpan> _boldNumbers(String text) {
    final spans = <TextSpan>[];
    var start = 0;
    for (final match in RegExp(r'\d+').allMatches(text)) {
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
    final left = (anchor.dx - width / 2).clamp(0.0, area.width - width);
    final above = anchor.dy - height - 8;
    final top = above >= 0 ? above : anchor.dy + 12;
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

class _DialPainter extends CustomPainter {
  final List<Color?> colors;
  final Color emptyColor;
  final Color hatchColor;
  final Color gapColor;
  final Color selectedColor;
  final int? selectedHour;

  /// Heures écrites autour du cadran : 0 h, 3 h… 21 h.
  final List<String> labels;
  final TextStyle labelStyle;
  final String centerText;
  final TextStyle centerStyle;

  _DialPainter({
    required this.colors,
    required this.emptyColor,
    required this.hatchColor,
    required this.gapColor,
    required this.selectedColor,
    required this.selectedHour,
    required this.labels,
    required this.labelStyle,
    required this.centerText,
    required this.centerStyle,
  });

  /// Place laissée autour du cadran pour les heures.
  static const double _labelMargin = 24;
  static const double _innerRatio = 0.42;

  static double _outer(Size size) => size.shortestSide / 2 - _labelMargin;

  /// Angle de début d'une heure : minuit en haut, sens des aiguilles.
  static double _angle(int hour) => -math.pi / 2 + hour * 2 * math.pi / 24;

  /// Heure sous [position], null hors de l'anneau.
  static int? hourAt(Offset position, Size size) {
    final center = size.center(Offset.zero);
    final offset = position - center;
    final outer = _outer(size);
    final distance = offset.distance;
    if (distance > outer || distance < outer * _innerRatio) return null;
    // Angle depuis minuit (en haut), dans le sens des aiguilles.
    var angle = math.atan2(offset.dx, -offset.dy);
    if (angle < 0) angle += 2 * math.pi;
    return (angle / (2 * math.pi) * 24).floor() % 24;
  }

  /// Milieu de la tranche de [hour] (point d'ancrage de sa bulle).
  static Offset sliceCenter(int hour, Size size) {
    final outer = _outer(size);
    final radius = outer * (1 + _innerRatio) / 2;
    final angle = _angle(hour) + math.pi / 24;
    return size.center(Offset.zero) + Offset(math.cos(angle), math.sin(angle)) * radius;
  }

  Path _slice(Offset center, double inner, double outer, int hour) {
    final start = _angle(hour);
    const sweep = 2 * math.pi / 24;
    return Path()
      ..arcTo(Rect.fromCircle(center: center, radius: outer), start, sweep, true)
      ..arcTo(Rect.fromCircle(center: center, radius: inner), start + sweep, -sweep, false)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outer = _outer(size);
    final inner = outer * _innerRatio;
    final gap = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = gapColor;

    for (var hour = 0; hour < 24; hour++) {
      final path = _slice(center, inner, outer, hour);
      final color = colors[hour];
      if (color != null) {
        canvas.drawPath(path, Paint()..color = color);
      } else {
        canvas.save();
        canvas.clipPath(path);
        _HatchPainter.paintHatch(canvas, path.getBounds(), emptyColor, hatchColor);
        canvas.restore();
      }
      canvas.drawPath(path, gap);
    }

    if (selectedHour != null) {
      canvas.drawPath(
        _slice(center, inner, outer, selectedHour!),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = selectedColor,
      );
    }

    for (var i = 0; i < labels.length; i++) {
      final hour = i * 24 ~/ labels.length;
      final angle = -math.pi / 2 + hour * 2 * math.pi / 24;
      final radius = outer + _labelMargin / 2 + 2;
      _drawText(canvas, labels[i], labelStyle, center + Offset(math.cos(angle), math.sin(angle)) * radius);
    }

    _drawText(canvas, centerText, centerStyle, center, maxWidth: inner * 1.8);
  }

  void _drawText(Canvas canvas, String text, TextStyle style, Offset at, {double? maxWidth}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: maxWidth ?? double.infinity);
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.colors.toString() != colors.toString() ||
      old.selectedHour != selectedHour ||
      old.centerText != centerText ||
      old.gapColor != gapColor ||
      old.labelStyle != labelStyle;
}

/// Hachures des heures qui n'ont pas assez de parties pour juger la
/// performance (cadran et légende).
class _HatchPainter extends CustomPainter {
  final Color background;
  final Color line;

  _HatchPainter({required this.background, required this.line});

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
  bool shouldRepaint(_HatchPainter old) => old.background != background || old.line != line;
}
