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

  group('topWithOthers', () {
    final sorted = [
      f('A', 5, 0, 0),
      f('B', 4, 0, 0),
      f('C', 3, 0, 0),
      f('D', 1, 1, 0),
      f('E', 0, 1, 1),
    ];

    test('regroupe au-delà de la limite dans « Autres », en dernier', () {
      final result = OpeningStatsService.topWithOthers(sorted, limit: 2);
      expect(result.map((f) => f.name), ['A', 'B', OpeningStatsService.others]);
      final others = result.last;
      expect(others.wins, 4);
      expect(others.draws, 2);
      expect(others.losses, 1);
      expect(others.totalGames, 7);
    });

    test('pas de ligne « Autres » quand tout tient dans la limite', () {
      expect(OpeningStatsService.topWithOthers(sorted, limit: 5), sorted);
      expect(OpeningStatsService.topWithOthers([], limit: 5), isEmpty);
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

  test('le viewmodel limite à 5 ouvertures + « Autres » par couleur', () {
    final many = [
      for (final name in ['A-a', 'B-b', 'C-c', 'D-d', 'E-e', 'F-f', 'G-g']) g(name, 'blitz', 'win'),
    ];
    final white = OpeningStatsViewModel(many).white;
    expect(white.length, OpeningStatsViewModel.topCount + 1);
    expect(white.last.name, OpeningStatsService.others);
    expect(white.last.totalGames, 2);
  });
}
