import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/country_game.dart';
import '../models/country_stats.dart';
import '../services/country_name_service.dart';
import '../services/country_stats_service.dart';
import '../services/pagination_service.dart';
import '../viewmodels/country_stats_viewmodel.dart';
import 'country_map.dart';
import 'pagination_controls.dart';
import 'result_bar.dart';
import 'time_class_filter.dart';

/// Statistiques par pays des adversaires (mois en cours) : carte du monde
/// colorée selon le nombre de parties, puis tableau rang,
/// pays, parties jouées, adversaires, barre victoires / nulles / défaites.
/// Filtrable par cadence et triable par parties jouées ou par taux.
class CountryStatsCard extends StatelessWidget {
  final List<CountryGame> games;

  const CountryStatsCard({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider(
      // Nouvelle liste (ex. après « Actualiser ») => nouveau viewmodel.
      key: ObjectKey(games),
      create: (_) => CountryStatsViewModel(games),
      child: Consumer<CountryStatsViewModel>(
        builder: (context, viewModel, child) {
          final countries = viewModel.countries;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.countryStats,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(l10n.countryStatsPeriod, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              TimeClassFilter(
                timeClasses: CountryStatsViewModel.timeClasses,
                selected: viewModel.timeClass,
                onSelected: viewModel.setTimeClass,
              ),
              const SizedBox(height: 16),
              if (countries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text(l10n.noCountryData)),
                )
              else ...[
                CountryMap(countries: countries),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildTable(
                    context,
                    viewModel,
                    viewModel.pageCountries,
                    PaginationService.firstRank(viewModel.page, countries.length),
                    l10n,
                  ),
                ),
                PaginationControls(
                  page: viewModel.page,
                  totalItems: countries.length,
                  onPageChanged: viewModel.setPage,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  /// En-tête cliquable : trie le tableau selon [key], avec une flèche
  /// indiquant le sens du tri quand la colonne est active.
  Widget _sortHeader(CountryStatsViewModel viewModel, CountrySortKey key, String label) {
    final active = viewModel.sortKey == key;
    return InkWell(
      onTap: () => viewModel.sortBy(key),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(fontWeight: active ? FontWeight.bold : FontWeight.normal)),
            if (active)
              Icon(viewModel.descending ? Icons.arrow_downward : Icons.arrow_upward, size: 14),
          ],
        ),
      ),
    );
  }

  String _percent(double rate) => '${(rate * 100).toStringAsFixed(0)}%';

  Widget _buildTable(
    BuildContext context,
    CountryStatsViewModel viewModel,
    List<CountryStats> countries,
    int firstRank,
    AppLocalizations l10n,
  ) {
    return DataTable(
      columnSpacing: 16,
      horizontalMargin: 8,
      headingRowHeight: 48,
      dataRowMinHeight: 56,
      dataRowMaxHeight: 64,
      columns: [
        DataColumn(label: Text(l10n.countryRankColumn)),
        DataColumn(label: Text(l10n.countryColumn)),
        DataColumn(
          numeric: true,
          label: _sortHeader(viewModel, CountrySortKey.gamesPlayed, l10n.gamesPlayed),
        ),
        DataColumn(numeric: true, label: Text(l10n.opponentsColumn)),
        DataColumn(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sortHeader(viewModel, CountrySortKey.winRate, l10n.wins),
              _sortHeader(viewModel, CountrySortKey.drawRate, l10n.draws),
              _sortHeader(viewModel, CountrySortKey.lossRate, l10n.losses),
            ],
          ),
        ),
      ],
      rows: [
        for (var i = 0; i < countries.length; i++)
          DataRow(cells: [
            DataCell(Text('${firstRank + i}')),
            DataCell(Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Largeur fixe : la largeur mesurée d'un drapeau emoji varie
                // (police de repli), ce qui faisait déborder le nom du pays.
                SizedBox(
                  width: 28,
                  child: Text(
                    CountryNameService.getFlag(countries[i].name),
                    style: const TextStyle(fontSize: 20),
                    softWrap: false,
                    overflow: TextOverflow.clip,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  CountryNameService.getCountryName(context, countries[i].name),
                  softWrap: false,
                ),
              ],
            )),
            DataCell(Text('${countries[i].gamesPlayed}')),
            DataCell(Text('${countries[i].opponentsCount}')),
            DataCell(Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResultBar(
                  wins: countries[i].gamesWon,
                  draws: countries[i].gamesDrawn,
                  losses: countries[i].gamesLost,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.countryResultRates(
                    _percent(countries[i].winRate),
                    _percent(countries[i].drawRate),
                    _percent(countries[i].lossRate),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            )),
          ]),
      ],
    );
  }
}
