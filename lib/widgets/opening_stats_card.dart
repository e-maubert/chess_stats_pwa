import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/country_game.dart';
import '../models/opening_family_stats.dart';
import '../services/opening_stats_service.dart';
import '../services/opening_name_service.dart';
import '../services/pagination_service.dart';
import '../viewmodels/opening_stats_viewmodel.dart';
import '../viewmodels/stats_filter_viewmodel.dart';
import 'pagination_controls.dart';
import 'result_bar.dart';

/// Page principale : un tableau des ouvertures jouées avec les blancs et un
/// avec les noirs, sur le modèle du tableau des pays : rang, ouverture,
/// parties jouées, barre victoires / nulles / défaites. Filtrable par cadence
/// et triable par parties jouées ou par taux de victoires / nulles / défaites.
class OpeningStatsCard extends StatelessWidget {
  final List<CountryGame> games;

  const OpeningStatsCard({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider(
      // Nouvelle liste (ex. après « Actualiser ») => nouveau viewmodel.
      key: ObjectKey(games),
      create: (context) => OpeningStatsViewModel(
        games,
        timeClassFilter: context.read<TimeClassViewModel>(),
        colorFilter: context.read<PlayerColorViewModel>(),
        openingFilter: context.read<OpeningFilterViewModel>(),
      ),
      child: Consumer<OpeningStatsViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.playedOpenings,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              for (final (index, color) in viewModel.shownColors.indexed) ...[
                if (index > 0) const SizedBox(height: 24),
                ..._colorBlock(
                  context,
                  color == OpeningStatsViewModel.colorWhite ? l10n.withWhite : l10n.withBlack,
                  viewModel,
                  color,
                  l10n,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Sous-bloc d'une couleur : titre, puis tableau paginé (ou message si
  /// vide).
  List<Widget> _colorBlock(
    BuildContext context,
    String title,
    OpeningStatsViewModel viewModel,
    String color,
    AppLocalizations l10n,
  ) {
    final total = viewModel.families(color).length;
    final page = viewModel.page(color);
    final families = viewModel.pageFamilies(color);
    return [
      Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      const SizedBox(height: 8),
      if (families.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(l10n.noCountryData, style: Theme.of(context).textTheme.bodyMedium),
        )
      else ...[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildTable(context, viewModel, families, PaginationService.firstRank(page, total), l10n),
        ),
        PaginationControls(
          page: page,
          totalItems: total,
          onPageChanged: (page) => viewModel.setPage(color, page),
        ),
      ],
    ];
  }

  /// En-tête cliquable : trie les tableaux selon [key], avec une flèche
  /// indiquant le sens du tri quand la colonne est active.
  Widget _sortHeader(OpeningStatsViewModel viewModel, OpeningSortKey key, String label) {
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
    OpeningStatsViewModel viewModel,
    List<OpeningFamilyStats> families,
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
        DataColumn(label: Text(l10n.openingColumn)),
        DataColumn(
          numeric: true,
          label: _sortHeader(viewModel, OpeningSortKey.gamesPlayed, l10n.gamesPlayed),
        ),
        DataColumn(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sortHeader(viewModel, OpeningSortKey.winRate, l10n.wins),
              _sortHeader(viewModel, OpeningSortKey.drawRate, l10n.draws),
              _sortHeader(viewModel, OpeningSortKey.lossRate, l10n.losses),
            ],
          ),
        ),
      ],
      rows: [
        for (var i = 0; i < families.length; i++)
          DataRow(cells: [
            DataCell(Text('${firstRank + i}')),
            DataCell(Text(
              l10n.openingFamilyName(
                OpeningNameService.key(families[i].name),
                OpeningNameService.fallback(families[i].name),
              ),
              softWrap: false,
            )),
            DataCell(Text('${families[i].totalGames}')),
            DataCell(Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResultBar(
                  wins: families[i].wins,
                  draws: families[i].draws,
                  losses: families[i].losses,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.countryResultRates(
                    _percent(families[i].winRate),
                    _percent(families[i].drawRate),
                    _percent(families[i].lossRate),
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
