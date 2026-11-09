import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../l10n/translations.dart';
import '../models/color_stats.dart';
import '../models/country_game.dart';
import '../viewmodels/color_stats_viewmodel.dart';
import 'result_bar.dart';

/// Page principale : victoires / nulles / défaites avec les blancs et avec
/// les noirs, en barres comme sur la page des pays, filtrables par cadence.
class ColorStatsCard extends StatelessWidget {
  final List<CountryGame> games;

  const ColorStatsCard({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final translations = Provider.of<Translations>(context);

    return ChangeNotifierProvider(
      // Nouvelle liste (ex. après « Actualiser ») => nouveau viewmodel.
      key: ObjectKey(games),
      create: (_) => ColorStatsViewModel(games),
      child: Consumer<ColorStatsViewModel>(
        builder: (context, viewModel, child) {
          final stats = viewModel.stats;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                translations.colorStats,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(l10n.countryStatsPeriod, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              _buildTimeClassFilter(viewModel, l10n),
              const SizedBox(height: 16),
              _buildColorRow(context, translations.whiteStats, stats.white, l10n),
              const SizedBox(height: 16),
              _buildColorRow(context, translations.blackStats, stats.black, l10n),
            ],
          );
        },
      ),
    );
  }

  String _percent(double rate) => '${(rate * 100).toStringAsFixed(0)}%';

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

  Widget _buildTimeClassFilter(ColorStatsViewModel viewModel, AppLocalizations l10n) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ColorStatsViewModel.timeClasses
          .map((timeClass) => ChoiceChip(
                label: Text(_timeClassLabel(timeClass, l10n)),
                selected: viewModel.timeClass == timeClass,
                onSelected: (_) => viewModel.setTimeClass(timeClass),
              ))
          .toList(),
    );
  }

  /// Une couleur : libellé + nombre de parties, barre victoires / nulles /
  /// défaites et pourcentages.
  Widget _buildColorRow(
    BuildContext context,
    String label,
    ColorStats colorStats,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            Text(
              l10n.played(colorStats.totalGames),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (colorStats.totalGames > 0) ...[
          ResultBar(
            wins: colorStats.wins,
            draws: colorStats.draws,
            losses: colorStats.losses,
            width: double.infinity,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.countryResultRates(
              _percent(colorStats.winRate),
              _percent(colorStats.drawRate),
              _percent(colorStats.lossRate),
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
