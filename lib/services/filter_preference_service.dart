import 'package:shared_preferences/shared_preferences.dart';

/// Mémorise un filtre de l'en-tête de la page des stats (cadence, couleur),
/// comme la période. Sans choix enregistré, ou avec une valeur inconnue :
/// null (= pas de filtre, « Toutes » / « Les deux »).
class FilterPreferenceService {
  /// Clé de stockage.
  final String key;

  /// Valeurs reconnues.
  final List<String?> allowed;

  /// Valeur enregistrée pour null (null ne se stocke pas).
  static const String _none = 'all';

  const FilterPreferenceService(this.key, this.allowed);

  Future<String?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);
    return allowed.contains(value) ? value : null;
  }

  Future<void> save(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value ?? _none);
  }
}
