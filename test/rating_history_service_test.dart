import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/services/rating_history_service.dart';
import 'package:chess_stats_pwa/viewmodels/rating_history_viewmodel.dart';
import 'package:chess_stats_pwa/viewmodels/stats_filter_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

CountryGame g(String timeClass, int? rating, int day, {bool rated = true}) => CountryGame(
      country: 'FR',
      opponent: 'x',
      timeClass: timeClass,
      result: 'win',
      playerColor: 'white',
      opening: 'Italian-Game',
      rating: rating,
      endTime: DateTime(2026, 11, day),
      rated: rated,
    );

void main() {
  final games = [
    g('blitz', 1510, 3),
    g('blitz', 1500, 1), // hors ordre : doit être trié
    g('blitz', 1490, 2),
    g('blitz', 1600, 4, rated: false), // amicale : ignorée
    g('blitz', null, 5), // sans classement : ignorée
    g('bullet', 1200, 1),
    g('bullet', 1180, 2),
    g('bullet', 1170, 3),
    g('bullet', 1150, 4),
  ];

  test('history : parties classées de la cadence, dans l\'ordre chronologique', () {
    final points = RatingHistoryService.history(games, 'blitz');
    expect(points.map((p) => p.rating), [1500, 1490, 1510]);
    expect(points.first.time, DateTime(2026, 11, 1));
  });

  test('change : dernier classement moins le premier', () {
    expect(RatingHistoryService.change(RatingHistoryService.history(games, 'blitz')), 10);
    expect(RatingHistoryService.change(RatingHistoryService.history(games, 'bullet')), -50);
    expect(RatingHistoryService.change(const []), 0);
  });

  test("series : une courbe par cadence jouée, dans l'ordre demandé", () {
    final series = RatingHistoryService.series(games, ['bullet', 'blitz', 'rapid']);
    expect(series.map((s) => s.timeClass), ['bullet', 'blitz']);
    expect(series.first.current, 1150);
    expect(series.first.change, -50);
    expect(series.last.current, 1510);
    expect(series.last.change, 10);
  });

  test('viewmodel : toutes les courbes sur « Toutes », une seule sinon', () {
    final filter = TimeClassViewModel.temporary();
    final viewModel = RatingHistoryViewModel(games, timeClassFilter: filter);
    var notified = 0;
    viewModel.addListener(() => notified++);

    expect(viewModel.series.map((s) => s.timeClass), ['bullet', 'blitz']);

    filter.select('blitz');
    expect(viewModel.series.single.current, 1510);

    filter.select('rapid');
    expect(viewModel.series, isEmpty);

    filter.select('rapid');
    expect(notified, 2);

    viewModel.dispose();
    filter.select(null); // plus suivi après dispose
    expect(notified, 2);
  });

  group('tendance (filtre de couleur)', () {
    CountryGame c(String color, int rating, int day, {String timeClass = 'blitz'}) => CountryGame(
          country: 'FR',
          opponent: 'x',
          timeClass: timeClass,
          result: 'win',
          playerColor: color,
          opening: 'Italian-Game',
          rating: rating,
          endTime: DateTime(2026, 11, day),
        );
    final mixed = [
      c('white', 1500, 1), // 1re partie : pas d'écart, non comptée
      c('black', 1490, 2), // -10 (noirs)
      c('white', 1510, 3), // +20 (blancs, écart avec la partie noire)
      c('black', 1505, 4), // -5 (noirs)
      c('white', 1530, 5), // +25 (blancs)
      c('white', 1200, 1, timeClass: 'bullet'),
    ];

    test('écart avec la partie précédente de la cadence, toutes couleurs', () {
      final white = RatingHistoryService.trend(mixed, 'blitz', (g) => g.playerColor == 'white');
      expect(white.points, 45);
      expect(white.games, 2);
      expect(white.current, 1530); // dernière partie de la cadence
      final bullet = RatingHistoryService.trend(mixed, 'bullet', (g) => g.playerColor == 'black');
      expect(bullet.current, 1200); // classement même sans partie comptée
      expect(bullet.games, 0);
      final black = RatingHistoryService.trend(mixed, 'blitz', (g) => g.playerColor == 'black');
      expect(black.points, -15);
      expect(black.games, 2);
    });

    test('viewmodel : courbes sans couleur, tendance par cadence avec', () {
      final colorFilter = PlayerColorViewModel.temporary();
      final viewModel = RatingHistoryViewModel(mixed, colorFilter: colorFilter);
      expect(viewModel.showsTrend, isFalse);

      colorFilter.select('white');
      expect(viewModel.showsTrend, isTrue);
      // Bullet : une seule partie, pas d'écart => absente.
      expect(viewModel.trends.single.timeClass, 'blitz');
      expect(viewModel.trends.single.points, 45);
    });

    test("pas assez de parties : aucune tendance", () {
      final colorFilter = PlayerColorViewModel.temporary();
      final viewModel = RatingHistoryViewModel([c('white', 1500, 1)], colorFilter: colorFilter);
      colorFilter.select('white');
      expect(viewModel.trends, isEmpty);
    });
  });

  test('toJson / fromJson conserve classement, date et partie classée', () {
    final game = g('blitz', 1500, 1, rated: false);
    final copy = CountryGame.fromJson(game.toJson());
    expect(copy.rating, 1500);
    expect(copy.endTime, DateTime(2026, 11, 1));
    expect(copy.rated, isFalse);
  });
}
