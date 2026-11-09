import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/services/opening_stats_service.dart';
import 'package:chess_stats_pwa/viewmodels/opening_stats_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

CountryGame g(String opening, String timeClass, String result) => CountryGame(
      country: 'FR',
      opponent: 'x',
      timeClass: timeClass,
      result: result,
      playerColor: 'white',
      opening: opening,
    );

void main() {
  final games = [
    g('Sicilian-Defense-Najdorf', 'blitz', 'win'),
    g('Sicilian-Defense-Dragon', 'blitz', 'draw'),
    g('Sicilian-Defense', 'bullet', 'loss'),
    g('Italian-Game', 'bullet', 'win'),
    g('Italian-Game', 'blitz', 'loss'),
    g('Reti-Opening', 'rapid', 'win'),
  ];

  test('regroupe par famille et compte les nulles à part', () {
    final families = OpeningStatsService.aggregate(games);
    final sicilian = families.firstWhere((f) => f.name == 'Sicilian-Defense');
    expect(sicilian.totalGames, 3);
    expect(sicilian.wins, 1);
    expect(sicilian.draws, 1);
    expect(sicilian.losses, 1);
  });

  test('trie par nombre de parties, puis par nom', () {
    final names = OpeningStatsService.aggregate(games).map((f) => f.name).toList();
    expect(names, ['Sicilian-Defense', 'Italian-Game', 'Reti-Opening']);
  });

  test('filtre par cadence et retire les familles sans partie', () {
    final families = OpeningStatsService.aggregate(games, timeClass: 'bullet');
    expect(families.map((f) => f.name), ['Italian-Game', 'Sicilian-Defense']);
    expect(families.first.wins, 1);
    expect(families.last.losses, 1);
  });

  test('le viewmodel applique la cadence choisie et notifie', () {
    final viewModel = OpeningStatsViewModel(games);
    var notified = 0;
    viewModel.addListener(() => notified++);

    expect(viewModel.families.length, 3);
    viewModel.setTimeClass('rapid');
    expect(viewModel.families.single.name, 'Reti-Opening');
    viewModel.setTimeClass('rapid');
    expect(notified, 1);
  });
}
