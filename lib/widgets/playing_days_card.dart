import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/country_game.dart';
import '../services/playing_days_service.dart';
import '../services/playing_hours_service.dart';
import '../services/stats_period_service.dart';
import '../theme/app_theme.dart';
import '../viewmodels/playing_days_viewmodel.dart';
import '../viewmodels/playing_hours_viewmodel.dart';
import '../viewmodels/stats_filter_viewmodel.dart';
import '../viewmodels/stats_period_viewmodel.dart';
import 'playing_time_widgets.dart';

/// Page principale : grille façon GitHub des parties de la période, une case
/// par jour et une colonne par semaine, plus une colonne finale qui résume
/// chaque jour de la semaine. En nombre de parties (activité) ou en
/// performance, avec le meilleur et le moins bon jour, et la comparaison
/// week-end / semaine.
class PlayingDaysCard extends StatelessWidget {
  final List<CountryGame> games;

  const PlayingDaysCard({super.key, required this.games});

  /// Premier jour de la semaine selon la langue (lundi en français,
  /// dimanche en anglais), en [DateTime.weekday].
  static int firstWeekday(BuildContext context) {
    final index = MaterialLocalizations.of(context).firstDayOfWeekIndex; // 0 = dimanche
    return index == 0 ? DateTime.sunday : index;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final period = context.watch<StatsPeriodViewModel>().period;
    final now = DateTime.now();
    final weekStart = firstWeekday(context);

    return ChangeNotifierProvider(
      // Nouvelle liste (période, « Actualiser ») => nouveau viewmodel.
      key: ValueKey((games, weekStart)),
      create: (context) => PlayingDaysViewModel(
        games,
        from: StatsPeriodService.start(period, now),
        to: now,
        firstWeekday: weekStart,
        timeClassFilter: context.read<TimeClassViewModel>(),
        colorFilter: context.read<PlayerColorViewModel>(),
        openingFilter: context.read<OpeningFilterViewModel>(),
      ),
      child: Consumer<PlayingDaysViewModel>(
        builder: (context, viewModel, child) {
          final grid = viewModel.grid;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.playingDays, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (grid.totalGames == 0)
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
                      icon: const Icon(Icons.calendar_month),
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
                Text(l10n.playingDaysHint, style: textTheme.bodySmall),
                const SizedBox(height: 12),
                _DaysGrid(viewModel: viewModel),
                const SizedBox(height: 12),
                if (viewModel.mode == PlayingHoursMode.activity)
                  ActivityLegend(maxGames: grid.maxGames)
                else
                  const PerformanceLegend(),
                const SizedBox(height: 12),
                _Summary(viewModel: viewModel),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Nom du jour de la semaine [weekday] dans la langue de l'interface
/// (« lundi », « Monday »), ou abrégé si [short] (« lun. », « Mon »).
String _weekdayName(BuildContext context, int weekday, {bool short = false}) {
  final locale = Localizations.localeOf(context).toString();
  // Le 2 novembre 2026 est un lundi.
  final date = DateTime(2026, 11, 1 + weekday);
  return (short ? DateFormat.E(locale) : DateFormat.EEEE(locale)).format(date);
}

String _capitalized(String text) => text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

/// Meilleur et moins bon jour de la semaine (liens qui les montrent dans la
/// colonne finale) et comparaison week-end / semaine, seulement quand
/// l'écart est net.
class _Summary extends StatelessWidget {
  final PlayingDaysViewModel viewModel;

  const _Summary({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final link = Theme.of(context).colorScheme.primary;
    final weekdays = viewModel.grid.weekdays;
    final standout = PlayingDaysService.standout(weekdays);
    final weekend = PlayingDaysService.weekendVsWeek(weekdays);

    if (standout == null && weekend == null) {
      final judged = weekdays.where((w) => w.results.judged).length;
      return Text(
        judged < 2 ? l10n.playingDaysNoneJudged(PlayingHoursService.minGames) : l10n.playingDaysEven,
        style: textTheme.bodySmall,
      );
    }

    Widget row(IconData icon, Color color, Widget content) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Icon(icon, size: 18, color: color), const SizedBox(width: 6), Expanded(child: content)],
        );

    Widget dayLine(IconData icon, Color color, String label, WeekdayStats stats) => row(
          icon,
          color,
          Wrap(
            spacing: 4,
            children: [
              Text(label, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => viewModel.showWeekday(weekdays.indexOf(stats)),
                  child: Text(
                    l10n.playingHoursSlot(
                      _capitalized(_weekdayName(context, stats.weekday)),
                      percentOf(stats.results.score),
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
        );

    final lines = <Widget>[
      if (weekend != null)
        row(
          Icons.weekend_outlined,
          Theme.of(context).colorScheme.onSurfaceVariant,
          Text(
            weekend.weekend.score > weekend.week.score
                ? l10n.playingDaysWeekendBetter(percentOf(weekend.weekend.score), percentOf(weekend.week.score))
                : l10n.playingDaysWeekBetter(percentOf(weekend.weekend.score), percentOf(weekend.week.score)),
            style: textTheme.bodyMedium,
          ),
        ),
      if (standout != null) ...[
        dayLine(Icons.trending_up, AppTheme.positiveText(context), l10n.playingDaysBest, standout.best),
        dayLine(Icons.trending_down, AppTheme.negativeText(context), l10n.playingDaysWorst, standout.worst),
      ],
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, line) in lines.indexed) ...[if (i > 0) const SizedBox(height: 4), line],
      ],
    );
  }
}

/// Grille : noms des jours à gauche, mois au-dessus, une colonne par
/// semaine, puis la colonne finale un peu à l'écart. Un clic sur une case
/// ouvre sa bulle ; un nouveau clic, ou un clic à côté, la ferme.
class _DaysGrid extends StatelessWidget {
  final PlayingDaysViewModel viewModel;

  const _DaysGrid({required this.viewModel});

  static const double _spacing = 3;
  static const double _labelWidth = 36;
  static const double _headerHeight = 18;

  /// Écart supplémentaire avant la colonne finale.
  static const double _totalGap = 10;
  static const double _minCell = 10;
  static const double _maxCell = 26;

  @override
  Widget build(BuildContext context) {
    final grid = viewModel.grid;
    final weeks = grid.weekStarts.length;
    final columns = weeks + 1;

    return LayoutBuilder(builder: (context, constraints) {
      final available = constraints.maxWidth - _labelWidth - _totalGap - columns * _spacing;
      final cell = (available / columns).clamp(_minCell, _maxCell);
      final step = cell + _spacing;
      final width = _labelWidth + columns * step + _totalGap;
      final height = _headerHeight + 7 * step;

      double left(int week) => _labelWidth + week * step + (week == weeks ? _totalGap : 0);
      double top(int row) => _headerHeight + row * step;

      final selected = viewModel.selected;
      return Center(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (selected != null) viewModel.tap(null);
          },
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ..._headers(context, grid, cell, left),
                for (var row = 0; row < 7; row++)
                  Positioned(
                    left: 0,
                    top: top(row),
                    width: _labelWidth - 4,
                    height: cell,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _weekdayName(context, grid.weekdays[row].weekday, short: true),
                        style: _labelStyle(context),
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                      ),
                    ),
                  ),
                for (var week = 0; week <= weeks; week++)
                  for (var row = 0; row < 7; row++)
                    if (week == weeks || grid.cell(week, row) != null)
                      Positioned(
                        left: left(week),
                        top: top(row),
                        width: cell,
                        height: cell,
                        child: _Cell(
                          color: _color(context, week, row),
                          hatched: _hatched(week, row),
                          selected: selected == (week: week, row: row),
                          onTap: () => viewModel.tap((week: week, row: row)),
                        ),
                      ),
                if (selected != null)
                  StatsBubble(
                    anchor: Offset(left(selected.week) + cell / 2, top(selected.row)),
                    area: Size(width, height),
                    text: _bubbleText(context, selected),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  TextStyle? _labelStyle(BuildContext context) => Theme.of(context)
      .textTheme
      .labelSmall
      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

  /// Mois au-dessus de la colonne où il commence (sans chevauchement), et
  /// titre de la colonne finale.
  List<Widget> _headers(BuildContext context, PlayingDaysGrid grid, double cell, double Function(int) left) {
    final locale = Localizations.localeOf(context).toString();
    final format = DateFormat.MMM(locale);
    final style = _labelStyle(context);
    final weeks = grid.weekStarts.length;

    // Colonnes où un nouveau mois apparaît (premier jour de la période
    // compris).
    final starts = <(int, DateTime)>[];
    int? previousMonth;
    for (var week = 0; week < weeks; week++) {
      final day = grid.weekStarts[week].isBefore(grid.from) ? grid.from : grid.weekStarts[week];
      if (day.month != previousMonth) starts.add((week, day));
      previousMonth = day.month;
    }
    // Un mois trop proche du suivant (moins de 3 colonnes) n'est pas écrit.
    final labels = [
      for (final (i, (week, day)) in starts.indexed)
        if (i == starts.length - 1 || starts[i + 1].$1 - week >= 3) (week, day),
    ];

    return [
      for (final (week, day) in labels)
        Positioned(
          left: left(week),
          top: 0,
          child: Text(format.format(day), style: style, maxLines: 1),
        ),
      Positioned(
        left: left(weeks) - 8,
        width: cell + 16,
        top: 0,
        child: Text(
          AppLocalizations.of(context)!.playingDaysAverageHeader,
          style: style?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ),
    ];
  }

  /// Résultats de la case : un jour, ou un jour de la semaine (colonne
  /// finale).
  ResultCounts _results(int week, int row) =>
      week == viewModel.grid.weekStarts.length ? viewModel.grid.weekdays[row].results : viewModel.grid.cell(week, row)!.results;

  bool _hatched(int week, int row) {
    if (viewModel.mode != PlayingHoursMode.performance) return false;
    final results = _results(week, row);
    return results.games > 0 && !results.judged;
  }

  /// Couleur de la case (ignorée si elle est hachurée).
  Color _color(BuildContext context, int week, int row) {
    final grid = viewModel.grid;
    final results = _results(week, row);
    if (results.games == 0) return AppTheme.mapEmptyCountry(context);
    if (viewModel.mode == PlayingHoursMode.performance) {
      return AppTheme.performanceBandColor(PlayingHoursService.band(results.score).index);
    }
    // Colonne finale : moyenne par jour, sur la même échelle que les jours.
    final games = week == grid.weekStarts.length ? grid.weekdays[row].averageGames : results.games.toDouble();
    return AppTheme.mapCountryColor(math.min(1, games / grid.maxGames));
  }

  (String, String) _bubbleText(BuildContext context, DayCell cell) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final grid = viewModel.grid;
    final total = viewModel.isTotalColumn(cell);
    final results = _results(cell.week, cell.row);

    final String title;
    if (total) {
      title = l10n.playingDaysWeekdayTitle(_weekdayName(context, grid.weekdays[cell.row].weekday));
    } else {
      title = _capitalized(DateFormat.yMMMMEEEEd(locale).format(grid.cell(cell.week, cell.row)!.date));
    }

    final String detail;
    if (viewModel.mode == PlayingHoursMode.activity) {
      detail = total
          ? l10n.playingDaysAverageDetail(
              NumberFormat('0.#', locale).format(grid.weekdays[cell.row].averageGames),
              results.games,
            )
          : l10n.countryMapGames(results.games);
    } else if (!results.judged) {
      detail = l10n.playingHoursNotEnoughDetail(results.games, PlayingHoursService.minGames);
    } else {
      detail = l10n.playingHoursPerformanceDetail(
        percentOf(results.score),
        results.games,
        results.wins,
        results.draws,
        results.losses,
      );
    }
    return (_capitalized(title), detail);
  }
}

/// Une case de la grille : couleur pleine ou hachures, contour si elle est
/// sélectionnée.
class _Cell extends StatelessWidget {
  final Color color;
  final bool hatched;
  final bool selected;
  final VoidCallback onTap;

  const _Cell({required this.color, required this.hatched, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(3);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: hatched ? null : color,
            borderRadius: radius,
            border: selected ? Border.all(color: AppTheme.mapSelectedBorder(context), width: 2) : null,
          ),
          child: hatched
              ? ClipRRect(
                  borderRadius: radius,
                  child: CustomPaint(
                    painter: HatchPainter(
                      background: AppTheme.mapEmptyCountry(context),
                      line: AppTheme.mapNotEnoughGames(context),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
