import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/country_game.dart';
import '../models/loss_stats.dart';
import '../viewmodels/loss_stats_viewmodel.dart';

/// Page principale : répartition des défaites par cause (temps, mat,
/// abandon), en camembert, filtrable par cadence.
class LossBreakdownCard extends StatelessWidget {
  final List<CountryGame> games;

  const LossBreakdownCard({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider(
      // Nouvelle liste (ex. après « Actualiser ») => nouveau viewmodel.
      key: ObjectKey(games),
      create: (_) => LossStatsViewModel(games),
      child: Consumer<LossStatsViewModel>(
        builder: (context, viewModel, child) {
          final stats = viewModel.stats;
          final slices = _slices(stats, l10n);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.lossBreakdown,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(l10n.countryStatsPeriod, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              _buildTimeClassFilter(viewModel, l10n),
              const SizedBox(height: 16),
              if (stats.total == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text(l10n.noLossData)),
                )
              else
                Row(
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 0,
                          sections: [
                            for (final slice in slices)
                              PieChartSectionData(
                                value: slice.count.toDouble(),
                                color: slice.color,
                                radius: 70,
                                showTitle: false,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final slice in slices) _buildLegendRow(context, slice, l10n),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  /// Parts affichées ; « Autre » n'apparaît que s'il y en a.
  List<_Slice> _slices(LossStats stats, AppLocalizations l10n) => [
        _Slice(l10n.lossByTimeout, stats.timeout, stats.timeoutRate, Colors.orange),
        _Slice(l10n.lossByCheckmate, stats.checkmated, stats.checkmatedRate, Colors.red),
        _Slice(l10n.lossByResignation, stats.resigned, stats.resignedRate, Colors.blueGrey),
        if (stats.other > 0) _Slice(l10n.lossOther, stats.other, stats.otherRate, Colors.grey),
      ];

  String _timeClassLabel(String? timeClass, AppLocalizations l10n) {
    switch (timeClass) {
      case 'bullet':
        return l10n.timeClassBullet;
      case 'blitz':
        return l10n.timeClassBlitz;
      case 'rapid':
        return l10n.timeClassRapid;
      default:
        return l10n.timeClassAll;
    }
  }

  Widget _buildTimeClassFilter(LossStatsViewModel viewModel, AppLocalizations l10n) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: LossStatsViewModel.timeClasses
          .map((timeClass) => ChoiceChip(
                label: Text(_timeClassLabel(timeClass, l10n)),
                selected: viewModel.timeClass == timeClass,
                onSelected: (_) => viewModel.setTimeClass(timeClass),
              ))
          .toList(),
    );
  }

  Widget _buildLegendRow(BuildContext context, _Slice slice, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: slice.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(slice.label)),
          Text(
            l10n.lossCauseValue(slice.count, '${(slice.rate * 100).toStringAsFixed(0)}%'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _Slice {
  final String label;
  final int count;
  final double rate;
  final Color color;

  const _Slice(this.label, this.count, this.rate, this.color);
}
