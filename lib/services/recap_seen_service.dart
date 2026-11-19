import 'package:shared_preferences/shared_preferences.dart';

/// Joueurs dont le bilan a déjà été montré sur cet appareil : il ne
/// s'affiche automatiquement qu'à la première recherche de chaque joueur
/// (on peut ensuite le revoir depuis la page des stats).
class RecapSeenService {
  static const String _key = 'recap_seen_players';

  static String _normalize(String username) => username.trim().toLowerCase();

  /// Le bilan de [username] a déjà été montré.
  Future<bool> hasSeen(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(_key) ?? const []).contains(_normalize(username));
    } catch (_) {
      // Stockage indisponible : on montre le bilan.
      return false;
    }
  }

  /// Note que le bilan de [username] a été montré.
  Future<void> markSeen(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getStringList(_key) ?? const [];
      final name = _normalize(username);
      if (!seen.contains(name)) await prefs.setStringList(_key, [...seen, name]);
    } catch (_) {
      // Sans stockage, le bilan sera simplement remontré.
    }
  }
}
