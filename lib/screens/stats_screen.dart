import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/country_game.dart';
import '../services/game_repository.dart';
import '../services/layout_service.dart';
import '../viewmodels/player_games_viewmodel.dart';
import '../viewmodels/stats_filter_viewmodel.dart';
import '../viewmodels/stats_period_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import '../widgets/player_app_bar_title.dart';
import '../widgets/share_player.dart';
import '../widgets/stats_display.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/stats_filter_panel.dart';
import 'player_route.dart';

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
        // Filtres de la page, propres à ce joueur : remis à leur valeur
        // par défaut (1 mois, toutes cadences, les deux couleurs, toutes
        // ouvertures, parties classées) pour chaque joueur consulté, jamais
        // mémorisés.
        ChangeNotifierProvider(create: (_) => StatsPeriodViewModel()),
        ChangeNotifierProvider(create: (_) => RatedFilterViewModel()),
        ChangeNotifierProvider(create: (_) => TimeClassViewModel()),
        ChangeNotifierProvider(create: (_) => PlayerColorViewModel()),
        ChangeNotifierProvider(create: (_) => OpeningFilterViewModel()),
      ],
      child: _StatsScaffold(username: username),
    );
  }
}

/// Page des stats et ses filtres : panneau fixe à gauche sur grand écran ;
/// sur mobile et tablette, tiroir glissant ouvert par le bouton en haut à
/// gauche (menu : filtres puis section « Plus ») ou par le résumé des
/// filtres sous la barre du haut.
class _StatsScaffold extends StatelessWidget {
  final String username;

  const _StatsScaffold({required this.username});

  /// Largeur du panneau des filtres fixe (grand écran).
  static const double _panelWidth = 300;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;
    final wide = LayoutService.columnCount(width) > 1;
    final canPop = Navigator.of(context).canPop();

    return Consumer<PlayerGamesViewModel>(
      builder: (context, viewModel, child) {
        final now = context.read<GameRepository>().now;
        final periodGames = viewModel.games == null
            ? const <CountryGame>[]
            : viewModel.gamesIn(
                context.watch<StatsPeriodViewModel>().period,
                ratedOnly: context.watch<RatedFilterViewModel>().ratedOnly,
              );
        final body = _body(context, viewModel, l10n);
        final progress = SizedBox(
          height: 2,
          child: viewModel.isUpdating && viewModel.games != null ? const LinearProgressIndicator(minHeight: 2) : null,
        );

        return Scaffold(
          drawer: wide
              ? null
              : Drawer(
                  width: width * 0.88 < 360 ? width * 0.88 : 360,
                  child: SafeArea(
                    child: Builder(
                      builder: (context) => StatsFilterPanel(
                        games: periodGames,
                        now: now,
                        title: l10n.menuTitle,
                        onDone: () => Navigator.of(context).pop(),
                        more: _menuActions(context, viewModel, l10n),
                      ),
                    ),
                  ),
                ),
          appBar: AppBar(
            // Sur mobile et tablette : retour (si on vient de la recherche)
            // puis bouton des filtres, en haut à gauche.
            automaticallyImplyLeading: wide,
            leadingWidth: !wide && canPop ? 96 : null,
            leading: wide
                ? null
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [if (canPop) const BackButton(), const StatsFilterButton()],
                  ),
            // Nom de l'app en petit, puis le pseudo dessous : il a toute la
            // largeur pour lui et ne se fait plus rogner sur mobile.
            title: PlayerAppBarTitle(username: username),
            // Sur mobile et tablette, seul le partage reste dans la barre :
            // bilan, mise à jour et thème sont dans la section « Plus » du
            // menu.
            actions: [
              if (wide) ...[
                _scoutButton(context, viewModel, l10n),
                _recapButton(context, viewModel, l10n),
              ],
              SharePlayerButton(username: username),
              if (wide) ...[
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: viewModel.isUpdating ? null : viewModel.update,
                  tooltip: l10n.refresh,
                ),
                const ThemeToggleButton(),
              ],
            ],
            // Résumé des filtres (mobile et tablette), puis barre fine pendant
            // la mise à jour en arrière-plan des parties déjà affichées.
            bottom: PreferredSize(
              preferredSize: Size.fromHeight((wide ? 0 : StatsFilterSummary.height) + 2),
              child: Column(
                children: [if (!wide) const StatsFilterSummary(), progress],
              ),
            ),
          ),
          body: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: _panelWidth,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border(right: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
                        ),
                        child: StatsFilterPanel(games: periodGames, now: now),
                      ),
                    ),
                    Expanded(child: body),
                  ],
                )
              : body,
        );
      },
    );
  }

  /// Revoir le bilan du dernier mois (montré automatiquement seulement à la
  /// première recherche du joueur).
  void _openRecap(NavigatorState navigator, PlayerGamesViewModel viewModel) =>
      navigator.push(recapRoute(username, viewModel.games!, upToDate: true, fromStats: true));

  /// « Comment battre ce joueur », sur les parties déjà affichées.
  void _openScouting(NavigatorState navigator, PlayerGamesViewModel viewModel) =>
      navigator.push(scoutRoute(username, viewModel.games!, upToDate: true, fromStats: true));

  Widget _scoutButton(BuildContext context, PlayerGamesViewModel viewModel, AppLocalizations l10n) => IconButton(
        icon: const Icon(Icons.emoji_objects_outlined),
        tooltip: l10n.scoutButton,
        onPressed: viewModel.games == null ? null : () => _openScouting(Navigator.of(context), viewModel),
      );

  Widget _recapButton(BuildContext context, PlayerGamesViewModel viewModel, AppLocalizations l10n) => IconButton(
        icon: const Icon(Icons.auto_stories_outlined),
        tooltip: l10n.recapReplay,
        onPressed: viewModel.games == null ? null : () => _openRecap(Navigator.of(context), viewModel),
      );

  /// Section « Plus » du menu (mobile et tablette) : comment le battre,
  /// bilan, mise à jour,
  /// thème. [context] est celui du tiroir, refermé avant l'action.
  List<Widget> _menuActions(BuildContext context, PlayerGamesViewModel viewModel, AppLocalizations l10n) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final navigator = Navigator.of(context);
    void closeThen(VoidCallback action) {
      navigator.pop();
      action();
    }

    return [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.emoji_objects_outlined),
        title: Text(l10n.scoutButton),
        enabled: viewModel.games != null,
        onTap: () => closeThen(() => _openScouting(navigator, viewModel)),
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.auto_stories_outlined),
        title: Text(l10n.recapReplay),
        enabled: viewModel.games != null,
        onTap: () => closeThen(() => _openRecap(navigator, viewModel)),
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.refresh),
        title: Text(l10n.refresh),
        enabled: !viewModel.isUpdating,
        onTap: () => closeThen(viewModel.update),
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
        title: Text(isDark ? l10n.switchToLightMode : l10n.switchToDarkMode),
        // Le menu reste ouvert : on voit le thème changer.
        onTap: () => context.read<ThemeViewModel>().toggle(brightness),
      ),
    ];
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
