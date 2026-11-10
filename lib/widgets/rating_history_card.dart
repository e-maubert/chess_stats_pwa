import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/country_game.dart';
import '../services/rating_history_service.dart';
import '../viewmodels/rating_history_viewmodel.dart';
import 'time_class_filter.dart';

/// Page principale : courbe du classement sur le mois pour une cadence,
/// avec le classement actuel et sa variation à droite du graphique.
class RatingHistoryCard extends StatelessWidget {
  final List<CountryGame> games;

  const RatingHistoryCard({super.key, required this.games});

  /// En dessous de cette largeur, le récapitulatif passe au-dessus du
  /// graphique pour lui laisser toute la largeur.
  static const double _wideLayoutMinWidth = 560;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider(
      // Nouvelle liste (ex. après « Actualiser ») => nouveau viewmodel.
      key: ObjectKey(games),
      create: (_) => RatingHistoryViewModel(games),
      child: Consumer<RatingHistoryViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.ratingEvolution,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(l10n.countryStatsPeriod, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              TimeClassFilter(
                timeClasses: RatingHistoryViewModel.timeClasses,
                selected: viewModel.timeClass,
                onSelected: viewModel.setTimeClass,
              ),
              const SizedBox(height: 16),
              if (viewModel.points.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text(l10n.noRatingData)),
                )
              else
                LayoutBuilder(builder: (context, constraints) {
                  final chart = SizedBox(height: 220, child: _chart(context, viewModel.points));
                  final summary = _summary(context, viewModel, l10n);
                  if (constraints.maxWidth < _wideLayoutMinWidth) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [summary, const SizedBox(height: 16), chart],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: chart),
                      const SizedBox(width: 24),
                      SizedBox(width: 180, child: summary),
                    ],
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  /// Classement actuel en gros, variation du mois en vert / rouge à côté.
  Widget _summary(BuildContext context, RatingHistoryViewModel viewModel, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final change = viewModel.change;
    final changeColor = change > 0
        ? Colors.green.shade700
        : change < 0
            ? Colors.red.shade700
            : Theme.of(context).colorScheme.onSurfaceVariant;
    final changeText = change > 0 ? '+$change' : '$change';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.ratingCurrent, style: textTheme.bodyMedium),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${viewModel.currentRating}',
              style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              changeText,
              style: textTheme.titleMedium?.copyWith(
                color: changeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(l10n.ratingSinceMonthStart, style: textTheme.bodySmall),
      ],
    );
  }

  Widget _chart(BuildContext context, List<RatingPoint> points) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dayFormat = DateFormat('d MMM', locale);
    final tooltipFormat = DateFormat('d MMM HH:mm', locale);
    final lineColor = theme.colorScheme.primary;
    final labelStyle = theme.textTheme.bodySmall;

    final spots = [
      for (final point in points)
        FlSpot(point.time.millisecondsSinceEpoch.toDouble(), point.rating.toDouble()),
    ];

    // Axe X : un écart nul (une seule partie) ferait planter le graphique.
    var minX = spots.first.x;
    var maxX = spots.last.x;
    const hour = 3600 * 1000.0;
    if (maxX - minX < hour) {
      minX -= hour;
      maxX += hour;
    }

    // Axe Y : marge autour des classements, arrondie à la dizaine.
    final ratings = points.map((p) => p.rating);
    final minY = ((ratings.reduce(math.min) - 10) / 10).floorToDouble() * 10;
    final maxY = ((ratings.reduce(math.max) + 10) / 10).ceilToDouble() * 10;

    // Environ 4 graduations sur chaque axe.
    final xInterval = (maxX - minX) / 4;
    final yInterval = math.max(10.0, ((maxY - minY) / 4 / 10).ceilToDouble() * 10);

    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: yInterval,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: yInterval,
              maxIncluded: false,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(value.toInt().toString(), style: labelStyle),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: xInterval,
              // Sinon la borne max s'affiche en plus de la dernière
              // graduation, quasi au même endroit (libellé en double).
              maxIncluded: false,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                child: Text(
                  dayFormat.format(DateTime.fromMillisecondsSinceEpoch(value.toInt())),
                  style: labelStyle,
                ),
              ),
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => theme.colorScheme.inverseSurface,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (touchedSpots) => [
              for (final spot in touchedSpots)
                LineTooltipItem(
                  '${spot.y.toInt()}\n',
                  TextStyle(
                    color: theme.colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: tooltipFormat.format(
                        DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()),
                      ),
                      style: TextStyle(
                        color: theme.colorScheme.onInverseSurface,
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: lineColor,
            barWidth: 2,
            // Points visibles seulement s'il y a peu de parties.
            dotData: FlDotData(show: spots.length <= 30),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}
