import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/country_game.dart';
import '../services/rating_history_service.dart';
import '../theme/app_theme.dart';
import '../viewmodels/rating_history_viewmodel.dart';
import '../viewmodels/time_class_viewmodel.dart';
import 'time_class_selector.dart';

/// Page principale : courbe du classement sur la période pour la cadence
/// choisie, ou une courbe par cadence sur « Toutes », avec le classement
/// actuel et sa variation à droite du graphique.
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
      create: (context) => RatingHistoryViewModel(games, context.read<TimeClassViewModel>()),
      child: Consumer<RatingHistoryViewModel>(
        builder: (context, viewModel, child) {
          final series = viewModel.series;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.ratingEvolution,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              if (series.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text(l10n.noRatingData)),
                )
              else
                LayoutBuilder(builder: (context, constraints) {
                  final chart = SizedBox(height: 220, child: _chart(context, series, l10n));
                  final summary = series.length == 1
                      ? _summary(context, series.single, l10n)
                      : _multiSummary(context, series, l10n);
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

  static Color _changeColor(BuildContext context, int change) => change > 0
      ? AppTheme.positiveText(context)
      : change < 0
          ? AppTheme.negativeText(context)
          : Theme.of(context).colorScheme.onSurfaceVariant;

  static String _changeText(int change) => change > 0 ? '+$change' : '$change';

  /// Une seule cadence : classement actuel en gros, variation sur la période
  /// en vert / rouge à côté.
  Widget _summary(BuildContext context, RatingSeries series, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
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
              '${series.current}',
              style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              _changeText(series.change),
              style: textTheme.titleMedium?.copyWith(
                color: _changeColor(context, series.change),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(l10n.ratingSincePeriodStart, style: textTheme.bodySmall),
      ],
    );
  }

  /// Plusieurs cadences : une ligne par courbe (pastille de sa couleur,
  /// cadence, classement actuel, variation), qui sert aussi de légende.
  Widget _multiSummary(BuildContext context, List<RatingSeries> series, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.ratingCurrent, style: textTheme.bodyMedium),
        const SizedBox(height: 4),
        for (final item in series)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppTheme.timeClassColor(context, item.timeClass),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: Text(TimeClassSelector.labelOf(item.timeClass, l10n), style: textTheme.bodyMedium),
                ),
                Text(
                  '${item.current}',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  _changeText(item.change),
                  style: textTheme.bodyMedium?.copyWith(
                    color: _changeColor(context, item.change),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 2),
        Text(l10n.ratingSincePeriodStart, style: textTheme.bodySmall),
      ],
    );
  }

  Widget _chart(BuildContext context, List<RatingSeries> series, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dayFormat = DateFormat('d MMM', locale);
    final tooltipFormat = DateFormat('d MMM HH:mm', locale);
    final labelStyle = theme.textTheme.bodySmall;
    final single = series.length == 1;

    // Une seule courbe : couleur principale du thème ; sinon une couleur par
    // cadence (celle de la légende).
    final colors = [
      for (final item in series)
        single ? theme.colorScheme.primary : AppTheme.timeClassColor(context, item.timeClass),
    ];
    final spotLists = [
      for (final item in series)
        [
          for (final point in item.points)
            FlSpot(point.time.millisecondsSinceEpoch.toDouble(), point.rating.toDouble()),
        ],
    ];
    final allSpots = spotLists.expand((spots) => spots).toList();

    // Axe X : un écart nul (une seule partie) ferait planter le graphique.
    var minX = allSpots.map((spot) => spot.x).reduce(math.min);
    var maxX = allSpots.map((spot) => spot.x).reduce(math.max);
    const hour = 3600 * 1000.0;
    if (maxX - minX < hour) {
      minX -= hour;
      maxX += hour;
    }

    // Axe Y : marge autour des classements, arrondie à la dizaine.
    final ratings = allSpots.map((spot) => spot.y);
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
              // Sinon les bornes s'affichent en plus des graduations, parfois
              // quasi au même endroit (libellés superposés, ex. sur 3 mois).
              minIncluded: false,
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
                  single
                      ? '${spot.y.toInt()}\n'
                      : '${TimeClassSelector.labelOf(series[spot.barIndex].timeClass, l10n)} ${spot.y.toInt()}\n',
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
          for (final (index, spots) in spotLists.indexed)
            LineChartBarData(
              spots: spots,
              color: colors[index],
              barWidth: 2,
              // Points visibles seulement s'il y a peu de parties.
              dotData: FlDotData(show: spots.length <= 30),
              // Aire sous la courbe seulement s'il n'y en a qu'une : plusieurs
              // aires superposées brouilleraient le graphique.
              belowBarData: BarAreaData(
                show: single,
                color: colors[index].withValues(alpha: 0.12),
              ),
            ),
        ],
      ),
    );
  }
}
