/// Adresse d'un joueur dans l'app : `/<pseudo>` (ex. `/hikaru`), à
/// partager pour ouvrir directement ses stats.
class PlayerLinkService {
  /// Pseudos chess.com : lettres, chiffres, `_` et `-`.
  static final RegExp _path = RegExp(r'^/([A-Za-z0-9_-]{2,30})/?$');

  /// Pseudo d'une adresse `/<pseudo>` ; null pour l'accueil (`/`) ou une
  /// adresse qui n'est pas celle d'un joueur.
  static String? usernameFromPath(String? path) {
    if (path == null) return null;
    final match = _path.firstMatch(path);
    return match?.group(1)!.toLowerCase();
  }

  /// Chemin de la page d'un joueur, pseudo en minuscules.
  static String path(String username) => '/${username.trim().toLowerCase()}';

  /// Lien complet vers la page d'un joueur, sur le site [base] (par défaut
  /// celui de la page ouverte).
  static Uri link(String username, {Uri? base}) {
    final site = base ?? Uri.base;
    return Uri(
      scheme: site.scheme,
      host: site.host,
      port: site.hasPort ? site.port : null,
      path: path(username),
    );
  }
}
