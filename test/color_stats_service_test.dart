import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/services/color_stats_service.dart';
import 'package:chess_stats_pwa/viewmodels/color_stats_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

CountryGame g(String color, String timeClass, String result) => CountryGame(
      country: 'FR',
      opponent: 'x',
      timeClass: timeClass,
      result: result,
      playerColor: color,
      opening: 'Italian-Game',
    );

void main() {
  final games = [
    g('white', 'blitz', 'win'),
    g('white', 'blitz', 'win'),
    g('white', 'bullet', 'loss'),
    g('white', 'rapid', 'draw'),
    g('black', 'blitz', 'loss'),
    g('black', 'bullet', 'win'),
    g('black', 'bullet', 'draw'),
  ];

  test('sépare les blancs et les noirs, toutes cadences', () {
    final stats = ColorStatsService.aggregate(games);
    expect(stats.white.wins, 2);
    expect(stats.white.losses, 1);
    expect(stats.white.draws, 1);
    expect(stats.white.totalGames, 4);
    expect(stats.black.wins, 1);
    expect(stats.black.losses, 1);
    expect(stats.black.draws, 1);
  });

  test('filtre par cadence', () {
    final stats = ColorStatsService.aggregate(games, timeClass: 'bullet');
    expect(stats.white.totalGames, 1);
    expect(stats.white.losses, 1);
    expect(stats.black.totalGames, 2);
    expect(stats.black.wins, 1);
    expect(stats.black.draws, 1);
  });

  test('cadence sans partie : tout à zéro', () {
    final stats = ColorStatsService.aggregate(games, timeClass: 'daily');
    expect(stats.white.totalGames, 0);
    expect(stats.white.winRate, 0);
    expect(stats.black.totalGames, 0);
  });

  test('le viewmodel applique la cadence choisie et notifie', () {
    final viewModel = ColorStatsViewModel(games);
    var notified = 0;
    viewModel.addListener(() => notified++);

    expect(viewModel.stats.white.totalGames, 4);
    viewModel.setTimeClass('blitz');
    expect(viewModel.stats.white.totalGames, 2);
    expect(viewModel.stats.black.totalGames, 1);
    viewModel.setTimeClass('blitz');
    expect(notified, 1);
  });
}
