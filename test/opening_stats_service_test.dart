import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/models/opening_family_stats.dart';
import 'package:chess_stats_pwa/services/opening_stats_service.dart';
import 'package:chess_stats_pwa/viewmodels/opening_stats_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

CountryGame g(String opening, String timeClass, String result, [String color = 'white']) =>
    CountryGame(
      country: 'FR',
      opponent: 'x',
      timeClass: timeClass,
      result: result,
      playerColor: color,
      opening: opening,
    );

OpeningFamilyStats f(String name, int wins, int draws, int losses) =>
    OpeningFamilyStats(name: name, wins: wins, draws: draws, losses: losses);

void main() {
  final games = [
    g('Sicilian-Defense-Najdorf', 'blitz', 'win'),
    g('Sicilian-Defense-Dragon', 'blitz', 'draw'),
    g('Sicilian-Defense', 'bullet', 'loss'),
    g('Italian-Game', 'bullet', 'win'),
    g('Italian-Game', 'blitz', 'loss'),
    g('Reti-Opening', 'rapid', 'win'),
    g('French-Defense', 'blitz', 'win', 'black'),
    g('Sicilian-Defense', 'blitz', 'loss', 'black'),
  ];

  group('aggregate', () {
    test('regroupe par famille et compte les nulles à part', () {
      final families = OpeningStatsService.aggregate(games, playerColor: 'white');
      final sicilian = families.firstWhere((f) => f.name == 'Sicilian-Defense');
      expect(sicilian.totalGames, 3);
      expect(sicilian.wins, 1);
      expect(sicilian.draws, 1);
      expect(sicilian.losses, 1);
    });

    test('trie par nombre de parties, puis par nom', () {
      final names =
          OpeningStatsService.aggregate(games, playerColor: 'white').map((f) => f.name).toList();
      expect(names, ['Sicilian-Defense', 'Italian-Game', 'Reti-Opening']);
    });

    test('filtre par cadence et retire les familles sans partie', () {
      final families =
          OpeningStatsService.aggregate(games, timeClass: 'bullet', playerColor: 'white');
      expect(families.map((f) => f.name), ['Italian-Game', 'Sicilian-Defense']);
      expect(families.first.wins, 1);
      expect(families.last.losses, 1);
    });

    test('sépare les couleurs ; sans couleur, compte les deux', () {
      final black = OpeningStatsService.aggregate(games, playerColor: 'black');
      expect(black.map((f) => f.name), ['French-Defense', 'Sicilian-Defense']);
      expect(black.last.losses, 1);

      final both = OpeningStatsService.aggregate(games);
      expect(both.firstWhere((f) => f.name == 'Sicilian-Defense').totalGames, 4);
    });
  });

  group('sort', () {
    final families = [
      f('A', 6, 0, 4), // 10 parties : 60 % V, 40 % D
      f('B', 1, 0, 0), // 1 partie : 100 % V
      f('C', 0, 1, 2), // 3 parties : 33 % N, 67 % D
      f('D', 0, 0, 1), // 1 partie : 100 % D
      f('E', 0, 0, 3), // 3 parties : 100 % D
    ];
    List<String> names(List<OpeningFamilyStats> list) => list.map((f) => f.name).toList();

    test('par parties jouées, décroissant puis croissant', () {
      expect(names(OpeningStatsService.sort(families, OpeningSortKey.gamesPlayed)),
          ['A', 'C', 'E', 'B', 'D']);
      expect(
          names(OpeningStatsService.sort(families, OpeningSortKey.gamesPlayed, descending: false)),
          ['B', 'D', 'C', 'E', 'A']);
    });

    test('par taux ; à égalité la plus jouée passe devant', () {
      expect(names(OpeningStatsService.sort(families, OpeningSortKey.lossRate)),
          ['E', 'D', 'C', 'A', 'B']);
      expect(names(OpeningStatsService.sort(families, OpeningSortKey.winRate)).take(2), ['B', 'A']);
      expect(names(OpeningStatsService.sort(families, OpeningSortKey.drawRate)).first, 'C');
    });
  });

  test('le viewmodel sépare les couleurs, applique la cadence et notifie', () {
    final viewModel = OpeningStatsViewModel(games);
    var notified = 0;
    viewModel.addListener(() => notified++);

    expect(viewModel.white.length, 3);
    expect(viewModel.black.length, 2);
    viewModel.setTimeClass('rapid');
    expect(viewModel.white.single.name, 'Reti-Opening');
    expect(viewModel.black, isEmpty);
    viewModel.setTimeClass('rapid');
    expect(notified, 1);
  });

  test('le viewmodel trie les deux tableaux ; re-clic inverse le sens', () {
    final viewModel = OpeningStatsViewModel(games);
    expect(viewModel.sortKey, OpeningSortKey.gamesPlayed);

    viewModel.sortBy(OpeningSortKey.lossRate);
    expect(viewModel.descending, isTrue);
    expect(viewModel.black.first.name, 'Sicilian-Defense'); // 100 % D
    expect(viewModel.white.last.name, 'Reti-Opening'); // 0 % D

    viewModel.sortBy(OpeningSortKey.lossRate);
    expect(viewModel.descending, isFalse);
    expect(viewModel.black.first.name, 'French-Defense');
  });
}
