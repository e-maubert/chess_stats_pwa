import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../l10n/translations.dart';
import '../models/country_game.dart';
import '../models/opening_family_stats.dart';
import '../services/opening_stats_service.dart';
import '../viewmodels/opening_stats_viewmodel.dart';
import 'result_summary.dart';
import 'time_class_filter.dart';

/// Page principale : victoires / nulles / défaites par famille d'ouvertures,
/// séparées en blancs / noirs (top 5 + « Autres » chacun), en barres comme
/// sur la page des pays, filtrables par cadence.
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
              ..._colorBlock(context, translations.whiteStats, viewModel.white, l10n),
              const SizedBox(height: 8),
              ..._colorBlock(context, translations.blackStats, viewModel.black, l10n),
            ],
          );
        },
      ),
    );
  }

  /// Sous-bloc d'une couleur : titre, puis top des ouvertures et « Autres ».
  List<Widget> _colorBlock(
    BuildContext context,
    String title,
    List<OpeningFamilyStats> families,
    AppLocalizations l10n,
  ) {
    return [
      Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      const SizedBox(height: 12),
      if (families.isEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(l10n.noCountryData, style: Theme.of(context).textTheme.bodyMedium),
        ),
      for (final family in families) ...[
        ResultSummary(
          label: family.name == OpeningStatsService.others ? l10n.openingOthers : family.name,
          wins: family.wins,
          draws: family.draws,
          losses: family.losses,
        ),
        const SizedBox(height: 16),
      ],
    ];
  }
}
