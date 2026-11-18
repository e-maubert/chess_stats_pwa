import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/country_game.dart';
import '../services/game_repository.dart';
import '../viewmodels/player_games_viewmodel.dart';
import '../viewmodels/stats_period_viewmodel.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import '../widgets/app_logo.dart';
import '../widgets/period_selector.dart';
import '../widgets/stats_display.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/time_class_selector.dart';

class StatsScreen extends StatelessWidget {
  final String username;

  /// Parties déjà chargées par l'écran de recherche (stockées ou
  /// téléchargées), affichées tout de suite.
  final List<CountryGame>? initialGames;

  /// [initialGames] viennent d'être téléchargées : pas de mise à jour à
  /// l'ouverture.
  final bool upToDate;

  const StatsScreen({Key? key, required this.username, this.initialGames, this.upToDate = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider(
      create: (context) => PlayerGamesViewModel(
        context.read<GameRepository>(),
        username,
        initialGames: initialGames,
        upToDate: upToDate,
      ),
      child: Consumer<PlayerGamesViewModel>(
        builder: (context, viewModel, child) => Scaffold(
          appBar: AppBar(
            // Nom de l'app en petit, puis le pseudo dessous : il a toute la
            // largeur pour lui et ne se fait plus rogner sur mobile.
            title: Semantics(
              label: l10n.statsTitle(username),
              excludeSemantics: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(size: 32, decorative: true),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.appTitle,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        Text(
                          username,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: viewModel.isUpdating ? null : viewModel.update,
                tooltip: l10n.refresh,
              ),
              const ThemeToggleButton(),
            ],
            // Choix de la période et de la cadence, puis barre fine pendant la mise à jour en
            // arrière-plan des parties déjà affichées.
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(PeriodSelector.height + TimeClassSelector.height + 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PeriodSelector(now: context.read<GameRepository>().now),
                  const TimeClassSelector(),
                  SizedBox(
                    height: 2,
                    child: viewModel.isUpdating && viewModel.games != null
                        ? const LinearProgressIndicator(minHeight: 2)
                        : null,
                  ),
                ],
              ),
            ),
          ),
          body: _body(context, viewModel, l10n),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, PlayerGamesViewModel viewModel, AppLocalizations l10n) {
    if (viewModel.games != null) {
      final period = context.watch<StatsPeriodViewModel>().period;
      return Column(
        children: [
          if (viewModel.updateFailed)
            MaterialBanner(
              content: Text(l10n.errorFetchingStats),
              actions: [TextButton(onPressed: viewModel.update, child: Text(l10n.retry))],
            ),
          Expanded(
            child: StatsDisplay(
              games: viewModel.gamesIn(period),
              countryGames: viewModel.countryGamesIn(period),
              phaseGames: viewModel.phaseGamesIn(period),
              phaseProgress: viewModel.phaseProgress,
            ),
          ),
        ],
      );
    }

    if (viewModel.updateFailed) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.errorFetchingStats,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.update,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }
}
