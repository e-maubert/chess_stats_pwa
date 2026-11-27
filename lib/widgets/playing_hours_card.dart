import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/country_game.dart';
import '../services/playing_hours_service.dart';
import '../theme/app_theme.dart';
import '../viewmodels/playing_hours_viewmodel.dart';
import '../viewmodels/stats_filter_viewmodel.dart';
import 'playing_time_widgets.dart';

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
      create: (context) => PlayingHoursViewModel(
        games,
        timeClassFilter: context.read<TimeClassViewModel>(),
        colorFilter: context.read<PlayerColorViewModel>(),
        openingFilter: context.read<OpeningFilterViewModel>(),
      ),
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
                  ActivityLegend(maxGames: PlayingHoursService.maxGames(hours))
                else
                  const PerformanceLegend(),
                const SizedBox(height: 12),
                _summary(context, hours, viewModel, l10n),
              ],
            ],
          );
        },
      ),
    );
  }

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
                          percentOf(stats.score),
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
    l10n.playingHoursPerformanceDetail(percentOf(stats.score), stats.games, stats.wins, stats.draws, stats.losses),
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
            StatsBubble(
              anchor: _DialPainter.sliceCenter(selected, size),
              area: size,
              text: _bubbleText(hours[selected], viewModel.mode, l10n),
            ),
        ],
      );
    });
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
        HatchPainter.paintHatch(canvas, path.getBounds(), emptyColor, hatchColor);
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
