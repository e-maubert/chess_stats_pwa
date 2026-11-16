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

class StatsScreen extends StatelessWidget {
  final String username;

  /// Parties déjà chargées par l'écran de recherche (stockées ou
  /// téléchargées), affichées tout de suite.
  final List<CountryGame>? initialGames;

  /// [initialGames] viennent d'être téléchargées : pas de mise à jour à
  /// l'ouverture.
  final bool upToDate;

  const StatsScreen({Key? key, required this.username, this.initialGames, this.upToDate = false}) : super(key: key);

  /// Hauteur de l'en-tête sous la barre du haut : sélecteur de période,
  /// dates et barre de mise à jour.
  static const double _periodHeaderHeight = 80;

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
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(size: 32, decorative: true),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    l10n.statsTitle(username),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: viewModel.isUpdating ? null : viewModel.update,
                tooltip: l10n.refresh,
              ),
              const ThemeToggleButton(),
            ],
            // Choix de la période, puis barre fine pendant la mise à jour en
            // arrière-plan des parties déjà affichées.
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(_periodHeaderHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PeriodSelector(now: context.read<GameRepository>().now),
                  const SizedBox(height: 6),
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
      return Column(
        children: [
          if (viewModel.updateFailed)
            MaterialBanner(
              content: Text(l10n.errorFetchingStats),
              actions: [TextButton(onPressed: viewModel.update, child: Text(l10n.retry))],
            ),
          Expanded(
            child: StatsDisplay(games: viewModel.gamesIn(context.watch<StatsPeriodViewModel>().period)),
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
