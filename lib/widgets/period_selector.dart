import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/stats_period.dart';
import '../services/stats_period_service.dart';
import '../viewmodels/stats_period_viewmodel.dart';

/// En-tête de la page des stats : choix « 1 mois / 3 mois » et dates
/// exactes de la période en légende.
class PeriodSelector extends StatelessWidget {
  /// Date de référence (fin de la période).
  final DateTime now;

  const PeriodSelector({super.key, required this.now});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<StatsPeriodViewModel>();
    final dateFormat = DateFormat.Md(Localizations.localeOf(context).toString());
    final start = StatsPeriodService.start(viewModel.period, now);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SegmentedButton<StatsPeriod>(
          segments: [
            ButtonSegment(value: StatsPeriod.oneMonth, label: Text(l10n.periodOneMonth)),
            ButtonSegment(value: StatsPeriod.threeMonths, label: Text(l10n.periodThreeMonths)),
          ],
          selected: {viewModel.period},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => viewModel.select(selection.first),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.periodRange(dateFormat.format(start.toLocal()), dateFormat.format(now.toLocal())),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
