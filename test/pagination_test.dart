import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/services/country_stats_service.dart';
import 'package:chess_stats_pwa/services/opening_stats_service.dart';
import 'package:chess_stats_pwa/services/pagination_service.dart';
import 'package:chess_stats_pwa/viewmodels/country_stats_viewmodel.dart';
import 'package:chess_stats_pwa/viewmodels/opening_stats_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

/// [count] parties contre le pays [country] (ouverture [opening], couleur
/// [color]).
List<CountryGame> games(String country, String opening, int count,
        {String color = 'white', String timeClass = 'blitz'}) =>
    List.generate(
      count,
      (i) => CountryGame(
        country: country,
        opponent: '$country$i',
        timeClass: timeClass,
        result: 'win',
        playerColor: color,
        opening: opening,
      ),
    );

void main() {
  group('PaginationService', () {
    test('nombre de pages, au moins une', () {
      expect(PaginationService.pageCount(0), 1);
      expect(PaginationService.pageCount(10), 1);
      expect(PaginationService.pageCount(11), 2);
      expect(PaginationService.pageCount(37), 4);
    });

    test('éléments et premier rang de chaque page', () {
      final items = List.generate(23, (i) => i + 1);
      expect(PaginationService.pageItems(items, 0), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      expect(PaginationService.pageItems(items, 2), [21, 22, 23]);
      expect(PaginationService.firstRank(2, 23), 21);
    });

    test('page hors limites ramenée à la première ou la dernière', () {
      final items = List.generate(23, (i) => i + 1);
      expect(PaginationService.pageItems(items, 9), [21, 22, 23]);
      expect(PaginationService.pageItems(items, -1).first, 1);
      expect(PaginationService.pageItems(<int>[], 3), isEmpty);
      expect(PaginationService.firstRank(5, 0), 1);
    });
  });

  group('CountryStatsViewModel', () {
    // 25 pays, du plus joué (AA, 25 parties) au moins joué (AY, 1 partie).
    final countryGames = [
      for (var i = 0; i < 25; i++) ...games('A${String.fromCharCode(65 + i)}', 'Italian-Game', 25 - i),
    ];

    test('le tableau affiche 10 pays par page, la carte les a tous', () {
      final viewModel = CountryStatsViewModel(countryGames);
      expect(viewModel.countries.length, 25);
      expect(viewModel.pageCountries.length, 10);
      expect(viewModel.pageCountries.first.name, 'AA');

      viewModel.setPage(2);
      expect(viewModel.page, 2);
      expect(viewModel.pageCountries.map((c) => c.name), ['AU', 'AV', 'AW', 'AX', 'AY']);
    });

    test('page limitée à la dernière, sans notification inutile', () {
      final viewModel = CountryStatsViewModel(countryGames);
      var notified = 0;
      viewModel.addListener(() => notified++);
      viewModel.setPage(99);
      expect(viewModel.page, 2);
      viewModel.setPage(2);
      expect(notified, 1);
    });

    test('changer de tri ou de cadence revient à la première page', () {
      final viewModel = CountryStatsViewModel(countryGames)..setPage(1);
      viewModel.sortBy(CountrySortKey.winRate);
      expect(viewModel.page, 0);

      viewModel.setPage(1);
      viewModel.setTimeClass('bullet');
      expect(viewModel.page, 0);
      expect(viewModel.pageCountries, isEmpty);
    });
  });

  group('OpeningStatsViewModel', () {
    const openings = [
      'Sicilian-Defense',
      'French-Defense',
      'Caro-Kann-Defense',
      'Italian-Game',
      'Ruy-Lopez',
      'Scotch-Game',
      'Vienna-Game',
      'English-Opening',
      'Reti-Opening',
      'Queens-Gambit',
      'Kings-Gambit',
      'Pirc-Defense',
    ];
    final openingGames = [
      for (var i = 0; i < openings.length; i++) ...games('FR', openings[i], openings.length - i),
      ...games('FR', 'French-Defense', 3, color: 'black'),
    ];

    test('pages indépendantes pour les blancs et les noirs', () {
      final viewModel = OpeningStatsViewModel(openingGames);
      final white = OpeningStatsViewModel.colorWhite;
      final black = OpeningStatsViewModel.colorBlack;
      final whiteCount = viewModel.families(white).length;
      expect(whiteCount, greaterThan(PaginationService.pageSize));
      expect(viewModel.pageFamilies(white).length, PaginationService.pageSize);

      viewModel.setPage(white, 1);
      expect(viewModel.page(white), 1);
      expect(viewModel.pageFamilies(white).length, whiteCount - PaginationService.pageSize);
      expect(viewModel.page(black), 0);
      expect(viewModel.pageFamilies(black).length, 1);

      viewModel.sortBy(OpeningSortKey.lossRate);
      expect(viewModel.page(white), 0);
    });
  });
}
