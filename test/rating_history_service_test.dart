import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/services/rating_history_service.dart';
import 'package:chess_stats_pwa/viewmodels/rating_history_viewmodel.dart';
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

  test('mostPlayed : cadence avec le plus de parties classées', () {
    expect(RatingHistoryService.mostPlayed(games, ['bullet', 'blitz', 'rapid']), 'bullet');
    expect(RatingHistoryService.mostPlayed(const [], ['bullet', 'blitz']), 'bullet');
  });

  test('le viewmodel démarre sur la cadence la plus jouée et notifie au changement', () {
    final viewModel = RatingHistoryViewModel(games);
    var notified = 0;
    viewModel.addListener(() => notified++);

    expect(viewModel.timeClass, 'bullet');
    expect(viewModel.currentRating, 1150);
    expect(viewModel.change, -50);

    viewModel.setTimeClass('blitz');
    expect(viewModel.currentRating, 1510);
    expect(viewModel.change, 10);

    viewModel.setTimeClass('rapid');
    expect(viewModel.points, isEmpty);
    expect(viewModel.currentRating, isNull);

    viewModel.setTimeClass('rapid');
    viewModel.setTimeClass(null);
    expect(notified, 2);
  });

  test('toJson / fromJson conserve classement, date et partie classée', () {
    final game = g('blitz', 1500, 1, rated: false);
    final copy = CountryGame.fromJson(game.toJson());
    expect(copy.rating, 1500);
    expect(copy.endTime, DateTime(2026, 11, 1));
    expect(copy.rated, isFalse);
  });
}
