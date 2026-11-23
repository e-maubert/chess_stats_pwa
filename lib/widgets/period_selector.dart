import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/stats_period.dart';
import '../services/stats_period_service.dart';
import '../viewmodels/stats_period_viewmodel.dart';
import 'option_toggle.dart';

/// Panneau des filtres : choix de la période, puis dates exactes de la
/// période dessous.
class PeriodSelector extends StatelessWidget {
  /// Date de référence (fin de la période).
  final DateTime now;

  const PeriodSelector({super.key, required this.now});

  /// Libellé d'une période. Toute nouvelle période de [StatsPeriod] doit
  /// avoir le sien : elle apparaît alors automatiquement dans le sélecteur.
  static String labelOf(StatsPeriod period, AppLocalizations l10n) => switch (period) {
        StatsPeriod.oneMonth => l10n.periodOneMonth,
        StatsPeriod.threeMonths => l10n.periodThreeMonths,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<StatsPeriodViewModel>();
    final dateFormat = DateFormat.Md(Localizations.localeOf(context).toString());
    final start = StatsPeriodService.start(viewModel.period, now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OptionToggle<StatsPeriod>(
          options: StatsPeriod.values,
          selected: viewModel.period,
          labelOf: (period) => labelOf(period, l10n),
          onChanged: viewModel.select,
          expanded: true,
        ),
        const SizedBox(height: 6),
        Text(
          l10n.periodRange(dateFormat.format(start.toLocal()), dateFormat.format(now.toLocal())),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
