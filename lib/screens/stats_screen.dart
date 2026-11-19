import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/country_game.dart';
import '../services/game_repository.dart';
import '../viewmodels/player_games_viewmodel.dart';
import '../viewmodels/stats_filter_viewmodel.dart';
import '../viewmodels/stats_period_viewmodel.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import '../widgets/period_selector.dart';
import '../widgets/player_app_bar_title.dart';
import '../widgets/stats_display.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/stats_filter_selectors.dart';
import 'recap_screen.dart';

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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => PlayerGamesViewModel(
            context.read<GameRepository>(),
            username,
            initialGames: initialGames,
            upToDate: upToDate,
          ),
        ),
        // Filtres de l'en-tête, propres à ce joueur : remis à leur valeur
        // par défaut (1 mois, toutes cadences, les deux couleurs, toutes
        // ouvertures, parties classées) pour chaque joueur consulté, jamais
        // mémorisés.
        ChangeNotifierProvider(create: (_) => StatsPeriodViewModel()),
        ChangeNotifierProvider(create: (_) => RatedFilterViewModel()),
        ChangeNotifierProvider(create: (_) => TimeClassViewModel()),
        ChangeNotifierProvider(create: (_) => PlayerColorViewModel()),
        ChangeNotifierProvider(create: (_) => OpeningFilterViewModel()),
      ],
      child: Consumer<PlayerGamesViewModel>(
        builder: (context, viewModel, child) => Scaffold(
          appBar: AppBar(
            // Nom de l'app en petit, puis le pseudo dessous : il a toute la
            // largeur pour lui et ne se fait plus rogner sur mobile.
            title: PlayerAppBarTitle(username: username),
            actions: [
              // Revoir le bilan du dernier mois (montré automatiquement
              // seulement à la première recherche du joueur).
              IconButton(
                icon: const Icon(Icons.auto_stories_outlined),
                tooltip: l10n.recapReplay,
                onPressed: viewModel.games == null
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecapScreen(
                              username: username,
                              games: viewModel.games!,
                              upToDate: true,
                              replay: true,
                            ),
                          ),
                        ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: viewModel.isUpdating ? null : viewModel.update,
                tooltip: l10n.refresh,
              ),
              const ThemeToggleButton(),
            ],
            // Choix de la période, des parties classées, de la cadence, de la couleur et de
            // l'ouverture, puis barre fine pendant la mise à jour en
            // arrière-plan des parties déjà affichées.
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(PeriodSelector.height + 4 * filterRowHeight + 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PeriodSelector(now: context.read<GameRepository>().now),
                  const RatedSelector(),
                  const TimeClassSelector(),
                  const PlayerColorSelector(),
                  OpeningSelector(
                    games: viewModel.games == null
                        ? const []
                        : viewModel.gamesIn(
                            context.watch<StatsPeriodViewModel>().period,
                            ratedOnly: context.watch<RatedFilterViewModel>().ratedOnly,
                          ),
                  ),
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
      final ratedOnly = context.watch<RatedFilterViewModel>().ratedOnly;
      return Column(
        children: [
          if (viewModel.updateFailed)
            MaterialBanner(
              content: Text(l10n.errorFetchingStats),
              actions: [TextButton(onPressed: viewModel.update, child: Text(l10n.retry))],
            ),
          Expanded(
            child: StatsDisplay(
              games: viewModel.gamesIn(period, ratedOnly: ratedOnly),
              countryGames: viewModel.countryGamesIn(period, ratedOnly: ratedOnly),
              phaseGames: viewModel.phaseGamesIn(period, ratedOnly: ratedOnly),
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
