import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/services/position_evaluator.dart';
import 'package:chess_stats_pwa/viewmodels/opening_improvement_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoEval implements PositionEvaluator {
  @override
  Future<PositionEval?> evaluate(String fen) async => null;
}

class _RateLimited implements PositionEvaluator {
  @override
  Future<PositionEval?> evaluate(String fen) async => throw const EvaluationRateLimited();
}

void main() {
  final now = DateTime.utc(2026, 11, 26);

  CountryGame game(String timeClass, String color, {int daysAgo = 1, bool rated = true}) => CountryGame(
        opponent: 'x',
        timeClass: timeClass,
        result: 'loss',
        playerColor: color,
        opening: 'Scotch-Game',
        rated: rated,
        endTime: now.subtract(Duration(days: daysAgo)),
        openingMoves: const ['e4', 'e5', 'Nf3', 'Nc6'],
      );

  Future<void> settle(OpeningImprovementViewModel viewModel) async {
    while (viewModel.loading) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  test('cadence la plus jouée sur 3 mois, parties classées, chaque couleur', () async {
    final viewModel = OpeningImprovementViewModel(_NoEval());
    viewModel.analyze([
      for (var i = 0; i < 4; i++) game('blitz', 'white'),
      for (var i = 0; i < 3; i++) game('blitz', 'black', daysAgo: 80),
      for (var i = 0; i < 5; i++) game('rapid', 'white', rated: false),
      for (var i = 0; i < 5; i++) game('rapid', 'white', daysAgo: 100),
    ], now);
    await settle(viewModel);
    expect(viewModel.timeClass, 'blitz');
    expect(viewModel.white!.opening.games, hasLength(4));
    expect(viewModel.black!.opening.games, hasLength(3));
    expect(viewModel.white!.mistake, isNull);
    expect(viewModel.failed, isFalse);
  });

  test('aucune partie classée : pas de cadence', () async {
    final viewModel = OpeningImprovementViewModel(_NoEval());
    viewModel.analyze([game('blitz', 'white', rated: false)], now);
    await settle(viewModel);
    expect(viewModel.timeClass, isNull);
  });

  test('service indisponible : échec signalé', () async {
    final viewModel = OpeningImprovementViewModel(_RateLimited());
    viewModel.analyze([for (var i = 0; i < 3; i++) game('blitz', 'white')], now);
    await settle(viewModel);
    expect(viewModel.failed, isTrue);
  });
}
