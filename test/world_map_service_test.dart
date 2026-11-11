import 'dart:io';

import 'package:chess_stats_pwa/models/country_stats.dart';
import 'package:chess_stats_pwa/services/world_map_service.dart';
import 'package:flutter_test/flutter_test.dart';

CountryStats c(String code, int games) => CountryStats(name: code, gamesPlayed: games, gamesWon: 0);

void main() {
  group('mapCode', () {
    test('codes ISO inchangés, minuscules acceptées', () {
      expect(WorldMapService.mapCode('FR'), 'FR');
      expect(WorldMapService.mapCode('us'), 'US');
    });

    test('nations britanniques et régions espagnoles rattachées à leur pays', () {
      for (final code in ['XE', 'XS', 'XW']) {
        expect(WorldMapService.mapCode(code), 'GB');
      }
      for (final code in ['XA', 'XB', 'XC', 'XG']) {
        expect(WorldMapService.mapCode(code), 'ES');
      }
      expect(WorldMapService.mapCode('XP'), 'PS');
      expect(WorldMapService.mapCode('XK'), 'XK');
    });

    test('International et pays inconnu : hors carte', () {
      expect(WorldMapService.mapCode('XX'), isNull);
      expect(WorldMapService.mapCode('Unknown'), isNull);
    });
  });

  test('gamesByMapCountry additionne les codes rattachés au même pays', () {
    final games = WorldMapService.gamesByMapCountry([
      c('GB', 3),
      c('XE', 5),
      c('XS', 1),
      c('FR', 2),
      c('XX', 7),
      c('Unknown', 4),
    ]);
    expect(games, {'GB': 9, 'FR': 2});
  });

  group('topCountries', () {
    test('les 3 pays les plus joués, du premier au troisième', () {
      expect(
        WorldMapService.topCountries({'FR': 5, 'US': 17, 'UA': 24, 'TR': 19, 'DE': 2}),
        ['UA', 'TR', 'US'],
      );
    });

    test('égalité : ordre alphabétique des codes', () {
      expect(WorldMapService.topCountries({'US': 4, 'DE': 4, 'FR': 4, 'AR': 4}), ['AR', 'DE', 'FR']);
    });

    test('moins de 3 pays joués : seulement ceux-là', () {
      expect(WorldMapService.topCountries({'FR': 1}), ['FR']);
      expect(WorldMapService.topCountries({}), isEmpty);
    });
  });

  group('intensity', () {
    test('1 partie = 0, pays le plus joué = 1', () {
      expect(WorldMapService.intensity(1, 50), 0);
      expect(WorldMapService.intensity(50, 50), 1);
    });

    test('échelle logarithmique : un pays dominant n\'écrase pas les autres', () {
      // 10 parties sur un maximum de 100 : à mi-chemin, pas à 10 %.
      expect(WorldMapService.intensity(10, 100), closeTo(0.5, 1e-9));
    });

    test('croissante', () {
      var previous = -1.0;
      for (var games = 1; games <= 300; games++) {
        final value = WorldMapService.intensity(games, 300);
        expect(value, greaterThanOrEqualTo(previous));
        previous = value;
      }
    });

    test('un seul pays joué une fois : couleur pleine', () {
      expect(WorldMapService.intensity(1, 1), 1);
    });
  });

  group('WorldMap', () {
    test('projection : origine au centre, nord vers le haut, est vers la droite', () {
      expect(WorldMap.project(0, 0), Offset.zero);
      expect(WorldMap.project(0, 45).dy, lessThan(0));
      expect(WorldMap.project(90, 0).dx, greaterThan(0));
    });

    test('parse et countryAt sur deux carrés', () {
      // AA : 0..10° de longitude, BB : 20..30°, tous deux entre 0 et 10° de latitude.
      final map = WorldMap.parse('{"countries":{"AA":[[0,0,1000,0,1000,1000,0,1000]],'
          '"BB":[[2000,0,3000,0,3000,1000,2000,1000]]},"labels":{"AA":[500,500]}}');
      expect(map.locate(0, 10), Offset.zero);
      expect(map.countryAt(map.locate(5, 5)), 'AA');
      expect(map.countryAt(map.locate(25, 5)), 'BB');
      expect(map.countryAt(map.locate(15, 5)), isNull);
      expect(map.labels['AA'], map.locate(5, 5));
      expect(map.labels.containsKey('BB'), isFalse);
    });

    test('le fichier de la carte contient les pays attendus, sans l\'Antarctique', () {
      final map = WorldMap.parse(File(WorldMap.assetPath).readAsStringSync());
      expect(map.countries.keys, containsAll(['FR', 'US', 'GB', 'IN', 'BR', 'RU', 'XK', 'PS', 'SG']));
      expect(map.countries.containsKey('AQ'), isFalse);
      expect(map.countryAt(map.locate(2.35, 48.85)), 'FR'); // Paris
      expect(map.countryAt(map.locate(-98.0, 38.5)), 'US'); // Kansas
      expect(map.countryAt(map.locate(-0.13, 51.5)), 'GB'); // Londres
      expect(map.countryAt(map.locate(-30.0, 30.0)), isNull); // Atlantique
      // Chaque pays a un point d'étiquette, posé sur son propre territoire.
      expect(map.labels.keys.toSet(), map.countries.keys.toSet());
      for (final code in ['FR', 'US', 'GB', 'NO', 'CL', 'AU', 'RU']) {
        expect(map.countryAt(map.labels[code]!), code, reason: code);
      }
    });
  });
}
