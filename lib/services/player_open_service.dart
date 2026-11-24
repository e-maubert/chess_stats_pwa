import '../models/country_game.dart';
import 'game_repository.dart';
import 'player_link_service.dart';
import 'recap_seen_service.dart';

/// Ce qu'il faut pour afficher un joueur : ses parties, et s'il faut
/// d'abord montrer le bilan du mois.
class PlayerOpening {
  final String username;
  final List<CountryGame> games;

  /// [games] viennent d'être téléchargées : pas de mise à jour à l'arrivée.
  final bool upToDate;

  /// Première recherche du joueur sur cet appareil : bilan d'abord.
  final bool showRecap;

  const PlayerOpening({
    required this.username,
    required this.games,
    required this.upToDate,
    required this.showRecap,
  });
}

/// Ouverture d'un joueur, depuis la recherche ou depuis un lien partagé.
/// Le bilan ne s'affiche de lui-même qu'après une recherche, jamais à
/// l'ouverture d'un lien (trop intrusif pour qui veut voir des stats).
class PlayerOpenService {
  final GameRepository _repository;
  final RecapSeenService _recapSeen;

  PlayerOpenService(this._repository, {RecapSeenService? recapSeen}) : _recapSeen = recapSeen ?? RecapSeenService();

  /// Recherche du joueur : parties déjà stockées (affichées tout de suite,
  /// mises à jour ensuite), sinon premier téléchargement. Échoue si le
  /// joueur est introuvable.
  Future<PlayerOpening> open(String username) async {
    final stored = await _repository.storedGames(username);
    final games = stored ?? await _repository.updateGames(username);
    // Bilan seulement à la première recherche du joueur sur cet appareil.
    final showRecap = !await _recapSeen.hasSeen(username);
    if (showRecap) await _recapSeen.markSeen(username);
    return PlayerOpening(username: username, games: games, upToDate: stored == null, showRecap: showRecap);
  }

  /// Parties du joueur pour « Comment battre ce joueur » : déjà stockées
  /// (mises à jour ensuite), sinon téléchargées. Ne touche pas au bilan du
  /// mois. Échoue si le joueur est introuvable.
  Future<({List<CountryGame> games, bool upToDate})> loadGames(String username) async {
    final stored = await _repository.storedGames(username);
    return (games: stored ?? await _repository.updateGames(username), upToDate: stored == null);
  }

  /// Ouverture d'un lien vers [link] : parties comme pour [loadGames]. Le
  /// bilan ouvert par son lien compte comme vu : pas de nouveau bilan
  /// automatique à la prochaine recherche du joueur.
  Future<({List<CountryGame> games, bool upToDate})> openLink(PlayerLink link) async {
    final loaded = await loadGames(link.username);
    if (link.page == PlayerPage.recap) await _recapSeen.markSeen(link.username);
    return loaded;
  }
}
