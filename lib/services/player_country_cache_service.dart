import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Pays des joueurs chess.com déjà interrogés, gardés [validity] dans le
/// navigateur : un même adversaire n'est demandé qu'une fois par mois, quel
/// que soit le joueur consulté. Une seule clé, de la forme
/// { "pseudo en minuscules": ["FR", date d'expiration en ms] }.
class PlayerCountryCacheService {
  static const String storageKey = 'player_country_v1';
  static const Duration validity = Duration(days: 30);

  final DateTime Function() _now;

  PlayerCountryCacheService({DateTime Function()? now}) : _now = now ?? DateTime.now;

  /// Entrées encore valides, pseudo en minuscules → code pays.
  Future<Map<String, String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return decode(prefs.getString(storageKey), _now()).map((name, entry) => MapEntry(name, entry.country));
  }

  /// Ajoute [countries] (pseudo → code pays) aux entrées valides, avec une
  /// nouvelle date d'expiration, et retire au passage les entrées expirées.
  Future<void> save(Map<String, String> countries) async {
    if (countries.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final now = _now();
    final entries = decode(prefs.getString(storageKey), now);
    final expiresAt = now.add(validity);
    countries.forEach((name, country) {
      entries[name.toLowerCase()] = (country: country, expiresAt: expiresAt);
    });
    await prefs.setString(storageKey, encode(entries));
  }

  /// Entrées valides à la date [now] ; une valeur absente ou illisible
  /// donne un cache vide plutôt qu'une erreur.
  static Map<String, ({String country, DateTime expiresAt})> decode(String? source, DateTime now) {
    if (source == null) return {};
    try {
      final json = jsonDecode(source) as Map<String, dynamic>;
      final entries = <String, ({String country, DateTime expiresAt})>{};
      json.forEach((name, value) {
        final list = value as List;
        final expiresAt = DateTime.fromMillisecondsSinceEpoch((list[1] as num).toInt());
        if (expiresAt.isAfter(now)) {
          entries[name] = (country: list[0] as String, expiresAt: expiresAt);
        }
      });
      return entries;
    } catch (_) {
      return {};
    }
  }

  static String encode(Map<String, ({String country, DateTime expiresAt})> entries) => jsonEncode({
        for (final e in entries.entries) e.key: [e.value.country, e.value.expiresAt.millisecondsSinceEpoch],
      });
}
