import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/services/loss_stats_service.dart';
import 'package:flutter_test/flutter_test.dart';

CountryGame g(String timeClass, String result, [String? lossCause]) => CountryGame(
      country: 'FR',
      opponent: 'x',
      timeClass: timeClass,
      result: result,
      playerColor: 'white',
      opening: 'Italian-Game',
      lossCause: lossCause,
    );

void main() {
  group('LossStatsService.lossCause', () {
    test('temps, mat, abandon ; déconnexion fusionnée avec abandon', () {
      expect(LossStatsService.lossCause('timeout'), LossStatsService.timeout);
      expect(LossStatsService.lossCause('checkmated'), LossStatsService.checkmated);
      expect(LossStatsService.lossCause('resigned'), LossStatsService.resigned);
      expect(LossStatsService.lossCause('abandoned'), LossStatsService.resigned);
      expect(LossStatsService.lossCause('lose'), LossStatsService.other);
      expect(LossStatsService.lossCause(null), LossStatsService.other);
    });
  });

  test('lossCause survit au cache (toJson / fromJson)', () {
    final game = CountryGame.fromJson(g('blitz', 'loss', 'timeout').toJson());
    expect(game.lossCause, 'timeout');
  });
}
