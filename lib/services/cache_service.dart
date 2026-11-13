import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chess_stats.dart';

class CacheService {
  // v2 : ajout de `countryGames` (stats par pays filtrables par cadence) ;
  // les entrées en cache de l'ancien format ne contiennent pas ces données.
  // v3 : ajout de `lossCause` dans `countryGames` (répartition des défaites).
  // v8 : ajout de `startTime` dans `countryGames` (heures de jeu).
  static const String _statsPrefix = 'chess_stats_v8_';
  static const Duration _cacheDuration = Duration(hours: 1);

  Future<void> cacheStats(String username, ChessStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _statsPrefix + username.toLowerCase();
    
    final data = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'stats': stats.toJson(),
    };

    await prefs.setString(key, json.encode(data));
  }

  Future<ChessStats?> getCachedStats(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _statsPrefix + username.toLowerCase();
    
    final cachedData = prefs.getString(key);
    if (cachedData == null) return null;

    final data = json.decode(cachedData) as Map<String, dynamic>;
    final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int);
    
    // Vérifier si le cache est expiré
    if (DateTime.now().difference(timestamp) > _cacheDuration) {
      await prefs.remove(key);
      return null;
    }

    return ChessStats.fromJson(data['stats'] as Map<String, dynamic>);
  }

  Future<void> clearCache(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _statsPrefix + username.toLowerCase();
    await prefs.remove(key);
  }
} 