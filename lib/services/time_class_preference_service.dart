import 'package:shared_preferences/shared_preferences.dart';

/// Mémorise la cadence choisie dans l'en-tête de la page des stats, comme la
/// période. Sans choix enregistré : toutes les cadences (null).
class TimeClassPreferenceService {
  static const String _key = 'stats_time_class';

  /// Valeur enregistrée pour « Toutes » (null ne se stocke pas).
  static const String _all = 'all';

  /// Cadences reconnues ; une valeur inconnue retombe sur « Toutes ».
  final List<String?> allowed;

  const TimeClassPreferenceService({this.allowed = const [null, 'bullet', 'blitz', 'rapid']});

  Future<String?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    return allowed.contains(value) ? value : null;
  }

  Future<void> save(String? timeClass) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, timeClass ?? _all);
  }
}
