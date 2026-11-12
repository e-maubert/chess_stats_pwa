import 'dart:convert';

import 'package:chess_stats_pwa/services/country_stats_service.dart';
import 'package:chess_stats_pwa/services/player_country_cache_service.dart';
import 'package:chess_stats_pwa/services/player_country_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response _profile(String country) =>
    http.Response(jsonEncode({'country': 'https://api.chess.com/pub/country/$country'}), 200);

String _name(http.Request request) => request.url.pathSegments.last;

void main() {
  final now = DateTime(2026, 11, 12);
  PlayerCountryCacheService cache() => PlayerCountryCacheService(now: () => now);

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('PlayerCountryCacheService', () {
    test('enregistre en minuscules et relit', () async {
      await cache().save({'Alice': 'FR'});
      expect(await cache().load(), {'alice': 'FR'});
    });

    test('entrée expirée après 30 jours, retirée au prochain enregistrement', () async {
      await cache().save({'alice': 'FR'});
      final later = PlayerCountryCacheService(now: () => now.add(const Duration(days: 31)));
      expect(await later.load(), isEmpty);

      await later.save({'bob': 'US'});
      final prefs = await SharedPreferences.getInstance();
      final stored = jsonDecode(prefs.getString(PlayerCountryCacheService.storageKey)!) as Map;
      expect(stored.keys, ['bob']);
    });

    test('valeur illisible : cache vide', () {
      expect(PlayerCountryCacheService.decode('pas du json', now), isEmpty);
    });
  });

  group('PlayerCountryService', () {
    test('un seul appel par adversaire, quelle que soit la casse', () async {
      final calls = <String>[];
      final client = MockClient((request) async {
        calls.add(_name(request));
        return _profile('FR');
      });
      final result = await PlayerCountryService(client: client, cache: cache())
          .countries(['Alice', 'alice', 'ALICE', 'bob']);
      expect(result, {'alice': 'FR', 'bob': 'FR'});
      expect(calls..sort(), ['alice', 'bob']);
    });

    test('pays en cache : pas d\'appel', () async {
      await cache().save({'alice': 'DE'});
      final calls = <String>[];
      final client = MockClient((request) async {
        calls.add(_name(request));
        return _profile('FR');
      });
      final result = await PlayerCountryService(client: client, cache: cache()).countries(['alice', 'bob']);
      expect(result, {'alice': 'DE', 'bob': 'FR'});
      expect(calls, ['bob']);
      expect(await cache().load(), {'alice': 'DE', 'bob': 'FR'});
    });

    test('appels en parallèle, limités à concurrency', () async {
      var running = 0, maxRunning = 0;
      final client = MockClient((request) async {
        running++;
        maxRunning = running > maxRunning ? running : maxRunning;
        await Future<void>.delayed(const Duration(milliseconds: 5));
        running--;
        return _profile('FR');
      });
      final names = [for (var i = 0; i < 20; i++) 'joueur$i'];
      final result = await PlayerCountryService(client: client, cache: cache(), concurrency: 4).countries(names);
      expect(result.length, 20);
      expect(maxRunning, 4);
    });

    test('429 : on réessaie', () async {
      var attempts = 0;
      final client = MockClient((request) async => ++attempts < 2 ? http.Response('', 429) : _profile('IT'));
      final result = await PlayerCountryService(client: client, cache: cache(), retryDelay: Duration.zero)
          .countries(['alice']);
      expect(result, {'alice': 'IT'});
      expect(attempts, 2);
    });

    test('échec persistant : pays inconnu, non mis en cache', () async {
      final client = MockClient((request) async => http.Response('', 429));
      final result = await PlayerCountryService(client: client, cache: cache(), retryDelay: Duration.zero)
          .countries(['alice']);
      expect(result, {'alice': CountryStatsService.unknownCountry});
      expect(await cache().load(), isEmpty);
    });

    test('compte supprimé (404) : pays inconnu, mis en cache', () async {
      final client = MockClient((request) async => http.Response('', 404));
      final result = await PlayerCountryService(client: client, cache: cache()).countries(['alice']);
      expect(result, {'alice': CountryStatsService.unknownCountry});
      expect(await cache().load(), {'alice': CountryStatsService.unknownCountry});
    });
  });
}
