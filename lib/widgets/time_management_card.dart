import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/country_game.dart';
import '../services/time_management_service.dart';
import '../viewmodels/time_management_viewmodel.dart';
import 'time_class_filter.dart';

/// Page principale : sur les parties perdues, écart de pendule avec
/// l'adversaire en fin de partie, répartition des défaites selon cet écart
/// et abandons sous pression du temps. Filtrable par cadence.
class TimeManagementCard extends StatelessWidget {
  final List<CountryGame> games;

  const TimeManagementCard({super.key, required this.games});

  static const Color _behindColor = Colors.orange;
  static const Color _balancedColor = Colors.grey;
  static const Color _aheadColor = Colors.blueGrey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return ChangeNotifierProvider(
      // Nouvelle liste (ex. après « Actualiser ») => nouveau viewmodel.
      key: ObjectKey(games),
      create: (_) => TimeManagementViewModel(games),
      child: Consumer<TimeManagementViewModel>(
        builder: (context, viewModel, child) {
          final stats = viewModel.stats;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.timeManagement,
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(l10n.countryStatsPeriod, style: textTheme.bodyMedium),
              const SizedBox(height: 12),
              TimeClassFilter(
                timeClasses: TimeManagementViewModel.timeClasses,
                selected: viewModel.timeClass,
                onSelected: viewModel.setTimeClass,
              ),
              const SizedBox(height: 16),
              if (stats.losses == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text(l10n.noLossData)),
                )
              else ...[
                _averageGap(context, stats, l10n),
                const SizedBox(height: 16),
                _gapBar(stats),
                const SizedBox(height: 8),
                _legendRow(context, l10n.timeBehind, stats.behind, stats.behindRate, _behindColor, l10n),
                _legendRow(context, l10n.timeBalanced, stats.balanced, stats.balancedRate, _balancedColor, l10n),
                _legendRow(context, l10n.timeAhead, stats.ahead, stats.aheadRate, _aheadColor, l10n),
                Text(l10n.timeThresholdNote, style: textTheme.bodySmall),
                const SizedBox(height: 16),
                _resignations(context, stats, l10n),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Écart moyen en gros : rouge si on finit avec moins de temps que
  /// l'adversaire, vert sinon.
  Widget _averageGap(BuildContext context, TimeManagementStats stats, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final gap = stats.averageGap.round();
    final color = gap < 0
        ? Colors.red.shade700
        : gap > 0
            ? Colors.green.shade700
            : Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TimeManagementService.formatGap(stats.averageGap),
          style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
        Text(l10n.timeGapAverage, style: textTheme.bodyMedium),
      ],
    );
  }

  /// Barre en trois couleurs : en retard / équilibré / en avance au temps.
  Widget _gapBar(TimeManagementStats stats) {
    Widget segment(int flex, Color color) =>
        flex > 0 ? Expanded(flex: flex, child: Container(color: color)) : const SizedBox.shrink();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: SizedBox(
        height: 12,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(
            children: [
              segment(stats.behind, _behindColor),
              segment(stats.balanced, _balancedColor),
              segment(stats.ahead, _aheadColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendRow(
    BuildContext context,
    String label,
    int count,
    double rate,
    Color color,
    AppLocalizations l10n,
  ) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(label)),
            Text(
              l10n.lossCauseValue(count, '${(rate * 100).toStringAsFixed(0)}%'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resignations(BuildContext context, TimeManagementStats stats, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.resignationsUnderPressure,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.resignationsUnderPressureValue(
            stats.resignationsUnderPressure,
            stats.resignations,
          ),
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(l10n.resignationsUnderPressureNote, style: textTheme.bodySmall),
      ],
    );
  }
}
