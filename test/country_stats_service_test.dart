import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/services/country_stats_service.dart';
import 'package:chess_stats_pwa/viewmodels/country_stats_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

CountryGame g(String country, String opponent, String timeClass, String result) =>
    CountryGame(country: country, opponent: opponent, timeClass: timeClass, result: result);

void main() {
  final games = [
    g('IN', 'raj', 'blitz', 'win'),
    g('IN', 'Raj', 'blitz', 'loss'),
    g('IN', 'amit', 'rapid', 'draw'),
    g('CA', 'bob', 'bullet', 'win'),
    g('Unknown', 'ghost', 'blitz', 'loss'),
    g('Unknown', 'shadow', 'blitz', 'loss'),
  ];

  group('CountryStatsService.aggregate', () {
    test('compte parties, résultats et adversaires distincts par pays', () {
      final stats = {for (final c in CountryStatsService.aggregate(games)) c.name: c};

      final india = stats['IN']!;
      expect(india.gamesPlayed, 3);
      expect(india.gamesWon, 1);
      expect(india.gamesLost, 1);
      expect(india.gamesDrawn, 1);
      expect(india.winRate, closeTo(1 / 3, 1e-9));
      expect(india.drawRate, closeTo(1 / 3, 1e-9));
      expect(india.lossRate, closeTo(1 / 3, 1e-9));
      // 'raj' et 'Raj' sont le même joueur
      expect(india.opponentsCount, 2);

      // Les pays inconnus sont regroupés sur une seule ligne
      expect(stats['Unknown']!.gamesPlayed, 2);
      expect(stats['Unknown']!.opponentsCount, 2);
    });

    test('filtre par cadence', () {
      final blitz = CountryStatsService.aggregate(games, timeClass: 'blitz');
      expect(blitz.map((c) => c.name).toSet(), {'IN', 'Unknown'});
      final india = blitz.firstWhere((c) => c.name == 'IN');
      expect(india.gamesPlayed, 2);
      expect(india.opponentsCount, 1);
    });
  });

  group('CountryStatsService.sort', () {
    final countries = CountryStatsService.aggregate(games);

    test('par nombre de parties décroissant', () {
      final sorted = CountryStatsService.sort(countries, CountrySortKey.gamesPlayed);
      expect(sorted.map((c) => c.name).toList(), ['IN', 'Unknown', 'CA']);
    });

    test('par taux de victoire, croissant ou décroissant', () {
      expect(
        CountryStatsService.sort(countries, CountrySortKey.winRate).first.name,
        'CA',
      );
      expect(
        CountryStatsService.sort(countries, CountrySortKey.winRate, descending: false).first.name,
        'Unknown',
      );
    });

    test('par taux de défaite', () {
      expect(
        CountryStatsService.sort(countries, CountrySortKey.lossRate).first.name,
        'Unknown',
      );
    });
  });

  test('le viewmodel inverse le tri sur un second clic et filtre par cadence', () {
    final vm = CountryStatsViewModel(games);
    expect(vm.countries.first.name, 'IN');

    vm.sortBy(CountrySortKey.gamesPlayed);
    expect(vm.descending, isFalse);
    expect(vm.countries.first.name, 'CA');

    vm.setTimeClass('bullet');
    expect(vm.countries.map((c) => c.name).toList(), ['CA']);
  });
}
