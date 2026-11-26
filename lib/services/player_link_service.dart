import 'scouting_service.dart';

/// Page d'un joueur ouverte par une adresse.
enum PlayerPage {
  /// `/<pseudo>` : page des stats.
  stats(''),

  /// `/<pseudo>/recap` : bilan du mois en diapositives.
  recap('recap'),

  /// `/<pseudo>/scout` : « Comment battre ce joueur », dans sa cadence la
  /// plus jouée ; `/<pseudo>/scout/<cadence>` (bullet, blitz, rapid) : dans
  /// cette cadence.
  scout('scout');

  /// Dernier segment de l'adresse (vide pour les stats).
  final String segment;

  const PlayerPage(this.segment);
}

/// Joueur, page et cadence (pour [PlayerPage.scout], null = la plus jouée)
/// désignés par une adresse.
typedef PlayerLink = ({String username, PlayerPage page, String? timeClass});

/// Adresses d'un joueur dans l'app, à partager : `/<pseudo>` (stats),
/// `/<pseudo>/recap` (bilan), `/<pseudo>/scout[/<cadence>]` (comment le
/// battre).
class PlayerLinkService {
  /// Pseudos chess.com : lettres, chiffres, `_` et `-`.
  static final RegExp _path = RegExp(r'^/([A-Za-z0-9_-]{2,30})(?:/([A-Za-z]+)(?:/([A-Za-z]+))?)?/?$');

  /// Joueur et page d'une adresse ; null pour l'accueil (`/`) ou une
  /// adresse qui n'est pas celle d'un joueur.
  static PlayerLink? fromPath(String? path) {
    if (path == null) return null;
    final match = _path.firstMatch(path);
    if (match == null) return null;
    final segment = match.group(2)?.toLowerCase() ?? '';
    final page = PlayerPage.values.where((page) => page.segment == segment).firstOrNull;
    if (page == null) return null;
    final timeClass = match.group(3)?.toLowerCase();
    if (timeClass != null && (page != PlayerPage.scout || !ScoutingService.timeClasses.contains(timeClass))) {
      return null;
    }
    return (username: match.group(1)!.toLowerCase(), page: page, timeClass: timeClass);
  }

  /// Chemin d'une page du joueur, pseudo en minuscules ; [timeClass]
  /// seulement pour [PlayerPage.scout].
  static String path(String username, {PlayerPage page = PlayerPage.stats, String? timeClass}) {
    final base = '/${username.trim().toLowerCase()}';
    if (page == PlayerPage.stats) return base;
    final withPage = '$base/${page.segment}';
    return page == PlayerPage.scout && timeClass != null ? '$withPage/$timeClass' : withPage;
  }

  /// Lien complet vers une page du joueur, sur le site [base] (par défaut
  /// celui de la page ouverte).
  static Uri link(String username, {PlayerPage page = PlayerPage.stats, String? timeClass, Uri? base}) {
    final site = base ?? Uri.base;
    return Uri(
      scheme: site.scheme,
      host: site.host,
      port: site.hasPort ? site.port : null,
      path: path(username, page: page, timeClass: timeClass),
    );
  }
}
