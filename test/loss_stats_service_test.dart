import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/services/loss_stats_service.dart';
import 'package:chess_stats_pwa/viewmodels/loss_stats_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

CountryGame g(String timeClass, String result, [String? lossCause]) => CountryGame(
      country: 'FR',
      opponent: 'x',
      timeClass: timeClass,
      result: result,
      playerColor: 'white',
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

  final games = [
    g('blitz', 'loss', 'timeout'),
    g('blitz', 'loss', 'timeout'),
    g('blitz', 'loss', 'checkmated'),
    g('bullet', 'loss', 'resigned'),
    g('rapid', 'loss', 'other'),
    g('blitz', 'win'),
    g('blitz', 'draw'),
  ];

  test('ne compte que les défaites, avec leur part', () {
    final stats = LossStatsService.aggregate(games);
    expect(stats.total, 5);
    expect(stats.timeout, 2);
    expect(stats.checkmated, 1);
    expect(stats.resigned, 1);
    expect(stats.other, 1);
    expect(stats.timeoutRate, closeTo(0.4, 1e-9));
    expect(stats.checkmatedRate, closeTo(0.2, 1e-9));
    expect(stats.resignedRate, closeTo(0.2, 1e-9));
  });

  test('filtre par cadence', () {
    final blitz = LossStatsService.aggregate(games, timeClass: 'blitz');
    expect(blitz.total, 3);
    expect(blitz.timeout, 2);
    expect(blitz.checkmated, 1);
    expect(blitz.resigned, 0);
  });

  test('aucune défaite : parts à zéro', () {
    final stats = LossStatsService.aggregate([g('blitz', 'win')]);
    expect(stats.total, 0);
    expect(stats.timeoutRate, 0);
  });

  test('le viewmodel recalcule selon la cadence choisie', () {
    final vm = LossStatsViewModel(games);
    expect(vm.stats.total, 5);
    vm.setTimeClass('bullet');
    expect(vm.stats.total, 1);
    expect(vm.stats.resigned, 1);
  });

  test('lossCause survit au cache (toJson / fromJson)', () {
    final game = CountryGame.fromJson(g('blitz', 'loss', 'timeout').toJson());
    expect(game.lossCause, 'timeout');
  });
}
