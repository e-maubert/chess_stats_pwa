import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../services/game_repository.dart';
import '../services/player_link_service.dart';
import '../services/player_open_service.dart';
import '../widgets/player_app_bar_title.dart';
import 'home_screen.dart';
import 'recap_screen.dart';
import 'stats_screen.dart';

/// Page d'un joueur (bilan ou stats), à l'adresse `/<pseudo>`.
Route<void> playerRoute(PlayerOpening opening) => MaterialPageRoute(
      settings: RouteSettings(name: PlayerLinkService.path(opening.username)),
      builder: (_) => opening.showRecap
          ? RecapScreen(username: opening.username, games: opening.games, upToDate: opening.upToDate)
          : StatsScreen(username: opening.username, initialGames: opening.games, upToDate: opening.upToDate),
    );

/// Accueil, à l'adresse `/`.
Route<void> homeRoute({String? username, bool notFound = false}) => MaterialPageRoute(
      settings: const RouteSettings(name: '/'),
      builder: (_) => HomeScreen(initialUsername: username, initialError: notFound),
    );

/// Ouverture d'un lien `/<pseudo>` : chargement des parties, puis bilan ou
/// stats. Joueur introuvable : retour à l'accueil, pseudo pré-rempli et
/// message d'erreur.
class PlayerLinkScreen extends StatefulWidget {
  final String username;

  const PlayerLinkScreen({super.key, required this.username});

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
    try {
      final opening = await PlayerOpenService(context.read<GameRepository>()).open(widget.username);
      if (!mounted) return;
      Navigator.pushReplacement(context, playerRoute(opening));
    } catch (_) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, homeRoute(username: widget.username, notFound: true), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: PlayerAppBarTitle(username: widget.username)),
      body: Center(
        child: Semantics(
          label: AppLocalizations.of(context)!.playerLoading,
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
