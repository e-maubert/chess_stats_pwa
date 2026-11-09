import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../l10n/translations.dart';
import '../models/country_game.dart';
import '../viewmodels/opening_stats_viewmodel.dart';
import 'result_summary.dart';
import 'time_class_filter.dart';

/// Page principale : victoires / nulles / défaites par famille d'ouvertures,
/// en barres comme sur la page des pays, filtrables par cadence.
class OpeningStatsCard extends StatelessWidget {
  final List<CountryGame> games;

  const OpeningStatsCard({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final translations = Provider.of<Translations>(context);

    return ChangeNotifierProvider(
      // Nouvelle liste (ex. après « Actualiser ») => nouveau viewmodel.
      key: ObjectKey(games),
      create: (_) => OpeningStatsViewModel(games),
      child: Consumer<OpeningStatsViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                translations.playedOpenings,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(l10n.countryStatsPeriod, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              TimeClassFilter(
                timeClasses: OpeningStatsViewModel.timeClasses,
                selected: viewModel.timeClass,
                onSelected: viewModel.setTimeClass,
              ),
              const SizedBox(height: 16),
              for (final family in viewModel.families) ...[
                ResultSummary(
                  label: family.name,
                  wins: family.wins,
                  draws: family.draws,
                  losses: family.losses,
                ),
                const SizedBox(height: 16),
              ],
            ],
          );
        },
      ),
    );
  }
}
