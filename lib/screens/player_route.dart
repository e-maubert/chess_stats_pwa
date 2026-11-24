import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../models/country_game.dart';
import '../services/game_repository.dart';
import '../services/player_link_service.dart';
import '../services/player_open_service.dart';
import '../widgets/player_app_bar_title.dart';
import 'home_screen.dart';
import 'recap_screen.dart';
import 'scouting_screen.dart';
import 'stats_screen.dart';

/// Page d'un joueur après une recherche : bilan (première recherche du
/// joueur sur cet appareil) ou stats.
Route<void> playerRoute(PlayerOpening opening) => opening.showRecap
    ? recapRoute(opening.username, opening.games, upToDate: opening.upToDate)
    : statsRoute(opening.username, opening.games, upToDate: opening.upToDate);

/// Stats du joueur, à l'adresse `/<pseudo>`.
Route<void> statsRoute(String username, List<CountryGame> games, {required bool upToDate}) => MaterialPageRoute(
      settings: RouteSettings(name: PlayerLinkService.path(username)),
      builder: (_) => StatsScreen(username: username, initialGames: games, upToDate: upToDate),
    );

/// Bilan du mois, à l'adresse `/<pseudo>/recap`. [fromStats] : ouvert
/// au-dessus de la page des stats, en sortir y ramène.
Route<void> recapRoute(String username, List<CountryGame> games, {required bool upToDate, bool fromStats = false}) =>
    MaterialPageRoute(
      settings: RouteSettings(name: PlayerLinkService.path(username, page: PlayerPage.recap)),
      builder: (_) => RecapScreen(username: username, games: games, upToDate: upToDate, replay: fromStats),
    );

/// « Comment battre ce joueur », à l'adresse `/<pseudo>/scout` (cadence la
/// plus jouée) ou `/<pseudo>/scout/<cadence>` ([timeClass] choisie).
/// [fromStats] : ouvert au-dessus de la page des stats, en sortir y ramène.
Route<void> scoutRoute(
  String username,
  List<CountryGame> games, {
  required bool upToDate,
  bool fromStats = false,
  String? timeClass,
}) =>
    MaterialPageRoute(
      settings: RouteSettings(name: PlayerLinkService.path(username, page: PlayerPage.scout, timeClass: timeClass)),
      builder: (_) => ScoutingScreen(
        username: username,
        games: games,
        upToDate: upToDate,
        fromStats: fromStats,
        timeClass: timeClass,
      ),
    );

/// Accueil, à l'adresse `/`.
Route<void> homeRoute({String? username, bool notFound = false}) => MaterialPageRoute(
      settings: const RouteSettings(name: '/'),
      builder: (_) => HomeScreen(initialUsername: username, initialError: notFound),
    );

/// Ouverture d'un lien : chargement des parties, puis page des stats ; pour
/// `/<pseudo>/recap` et `/<pseudo>/scout`, diaporama au-dessus des stats
/// (en sortir y ramène). Jamais de bilan automatique. Joueur introuvable :
/// retour à l'accueil, pseudo pré-rempli et message d'erreur.
class PlayerLinkScreen extends StatefulWidget {
  final PlayerLink link;

  const PlayerLinkScreen({super.key, required this.link});

  @override
  State<PlayerLinkScreen> createState() => _PlayerLinkScreenState();
}

class _PlayerLinkScreenState extends State<PlayerLinkScreen> {
  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    final link = widget.link;
    try {
      final loaded = await PlayerOpenService(context.read<GameRepository>()).openLink(link);
      if (!mounted) return;
      final navigator = Navigator.of(context);
      navigator.pushReplacement(statsRoute(link.username, loaded.games, upToDate: loaded.upToDate));
      // La page des stats met les parties à jour ; le diaporama montre
      // celles déjà chargées.
      switch (link.page) {
        case PlayerPage.stats:
          break;
        case PlayerPage.recap:
          navigator.push(recapRoute(link.username, loaded.games, upToDate: true, fromStats: true));
        case PlayerPage.scout:
          navigator.push(
              scoutRoute(link.username, loaded.games, upToDate: true, fromStats: true, timeClass: link.timeClass));
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, homeRoute(username: link.username, notFound: true), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: PlayerAppBarTitle(username: widget.link.username)),
      body: Center(
        child: Semantics(
          label: AppLocalizations.of(context)!.playerLoading,
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
