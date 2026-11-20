import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/country_game.dart';
import '../services/game_repository.dart';
import '../services/layout_service.dart';
import '../viewmodels/collapsible_header.dart';
import '../viewmodels/player_games_viewmodel.dart';
import '../viewmodels/stats_filter_viewmodel.dart';
import '../viewmodels/stats_period_viewmodel.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import '../widgets/period_selector.dart';
import '../widgets/player_app_bar_title.dart';
import '../widgets/share_player.dart';
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
      child: _StatsScaffold(username: username),
    );
  }
}

/// Page des stats avec ses filtres dans l'en-tête. Sur mobile (une seule
/// colonne de cartes), les filtres se replient quand on fait défiler les
/// stats vers le bas et reviennent quand on remonte.
class _StatsScaffold extends StatefulWidget {
  final String username;

  const _StatsScaffold({required this.username});

  @override
  State<_StatsScaffold> createState() => _StatsScaffoldState();
}

class _StatsScaffoldState extends State<_StatsScaffold> with SingleTickerProviderStateMixin {
  /// Hauteur des filtres dépliés (période, parties classées, cadence,
  /// couleur, ouverture).
  static const double _filtersHeight = PeriodSelector.height + 4 * filterRowHeight;

  /// 1 = filtres affichés, 0 = repliés.
  late final AnimationController _filters = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: 1,
  );

  @override
  void dispose() {
    _filters.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollUpdateNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) return false;
    final visible = _filters.status == AnimationStatus.forward || _filters.status == AnimationStatus.completed;
    final next = CollapsibleHeader.visibleAfterScroll(
      visible: visible,
      scrollDelta: notification.scrollDelta ?? 0,
      pixels: notification.metrics.pixels,
    );
    if (next != visible) next ? _filters.forward() : _filters.reverse();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final username = widget.username;
    final collapsible = LayoutService.columnCount(MediaQuery.sizeOf(context).width) == 1;
    if (!collapsible && _filters.value < 1) _filters.value = 1;

    return Consumer<PlayerGamesViewModel>(
      builder: (context, viewModel, child) => AnimatedBuilder(
        animation: _filters,
        // Contenu construit une fois : l'animation ne fait que changer la
        // hauteur de l'en-tête.
        child: NotificationListener<ScrollUpdateNotification>(
          onNotification: collapsible ? _onScroll : null,
          child: _body(context, viewModel, l10n),
        ),
        builder: (context, body) {
          final shown = Curves.easeInOut.transform(_filters.value);
          return Scaffold(
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
                SharePlayerButton(username: username),
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
                preferredSize: Size.fromHeight(_filtersHeight * shown + 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (shown > 0)
                      ClipRect(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          heightFactor: shown,
                          child: Opacity(
                            opacity: shown,
                            child: Column(
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
                              ],
                            ),
                          ),
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
            body: body,
          );
        },
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
