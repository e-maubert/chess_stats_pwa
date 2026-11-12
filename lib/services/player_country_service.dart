import 'dart:convert';

import 'package:http/http.dart' as http;

import 'country_stats_service.dart';
import 'player_country_cache_service.dart';

/// Pays des adversaires. L'API chess.com ne le donne que dans le profil de
/// chaque joueur : un appel par adversaire. Pour aller vite :
/// - chaque adversaire n'est demandé qu'une fois, même s'il a été joué
///   plusieurs fois ;
/// - les pays déjà connus sont relus du cache local (1 mois) ;
/// - les autres sont demandés [concurrency] à la fois. Au-delà, chess.com
///   peut répondre 429 (trop de requêtes) : on attend puis on réessaie.
class PlayerCountryService {
  static const String baseUrl = 'https://api.chess.com/pub/player';
  static const int defaultConcurrency = 6;
  static const int maxAttempts = 3;

  final http.Client _client;
  final PlayerCountryCacheService _cache;
  final int concurrency;
  final Duration retryDelay;

  PlayerCountryService({
    http.Client? client,
    PlayerCountryCacheService? cache,
    this.concurrency = defaultConcurrency,
    this.retryDelay = const Duration(milliseconds: 500),
  })  : _client = client ?? http.Client(),
        _cache = cache ?? PlayerCountryCacheService();

  /// Pseudo en minuscules → code pays, pour chaque pseudo de [usernames]
  /// ([CountryStatsService.unknownCountry] si le pays n'a pas pu être lu).
  Future<Map<String, String>> countries(Iterable<String> usernames) async {
    final wanted = {for (final name in usernames) name.toLowerCase()};
    final cached = await _cache.load();
    final result = <String, String>{
      for (final name in wanted)
        if (cached[name] != null) name: cached[name]!,
    };
    final missing = wanted.where((name) => !result.containsKey(name)).toList();

    // Seules les vraies réponses sont mises en cache, pas les échecs
    // passagers (réseau, 429 persistant), qu'on retentera la fois suivante.
    final fetched = <String, String>{};
    final queue = missing.iterator;
    Future<void> worker() async {
      while (queue.moveNext()) {
        final name = queue.current;
        final country = await _fetch(name);
        result[name] = country ?? CountryStatsService.unknownCountry;
        if (country != null) fetched[name] = country;
      }
    }

    await Future.wait([for (var i = 0; i < concurrency && i < missing.length; i++) worker()]);
    await _cache.save(fetched);
    return result;
  }

  /// Code pays d'un joueur ; [CountryStatsService.unknownCountry] si le
  /// compte n'existe plus ; null en cas d'échec passager.
  Future<String?> _fetch(String username) async {
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await _client.get(Uri.parse('$baseUrl/$username'));
        switch (response.statusCode) {
          case 200:
            final country = (json.decode(response.body) as Map<String, dynamic>)['country'];
            return country is String ? country.split('/').last : CountryStatsService.unknownCountry;
          case 404:
          case 410:
            return CountryStatsService.unknownCountry;
          case 429:
          case >= 500:
            break; // réessayer
          default:
            return null;
        }
      } catch (_) {
        // Erreur réseau : réessayer.
      }
      if (attempt < maxAttempts) await Future<void>.delayed(retryDelay * attempt);
    }
    return null;
  }
}
