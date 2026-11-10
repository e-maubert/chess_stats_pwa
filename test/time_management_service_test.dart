import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/services/time_management_service.dart';
import 'package:chess_stats_pwa/viewmodels/time_management_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

CountryGame g(
  String result,
  double? mine,
  double? theirs, {
  String timeClass = 'blitz',
  int? base = 180,
  String? lossCause,
}) =>
    CountryGame(
      country: 'FR',
      opponent: 'x',
      timeClass: timeClass,
      result: result,
      playerColor: 'white',
      opening: 'Italian-Game',
      lossCause: lossCause,
      playerClock: mine,
      opponentClock: theirs,
      baseTime: base,
    );

void main() {
  group('lastClocks', () {
    test('dernière pendule de chaque couleur, en secondes', () {
      const pgn = '[TimeControl "180"]\n\n'
          '1. d4 {[%clk 0:03:00]} 1... Nf6 {[%clk 0:02:59.5]} '
          '2. Bg5 {[%clk 0:02:58.7]} 2... e6 {[%clk 0:01:05.1]} '
          '3. Nd2 {[%clk 1:00:12.4]} 1-0';
      final clocks = TimeManagementService.lastClocks(pgn);
      expect(clocks.white, closeTo(3612.4, 1e-9));
      expect(clocks.black, closeTo(65.1, 1e-9));
    });

    test('couleur sans coup ou PGN sans pendule : null', () {
      final clocks = TimeManagementService.lastClocks('1. e4 {[%clk 0:00:59.9]} 1-0');
      expect(clocks.white, closeTo(59.9, 1e-9));
      expect(clocks.black, isNull);
      expect(TimeManagementService.lastClocks('1. e4 e5 1/2-1/2').white, isNull);
    });
  });

  test('baseTime : temps initial, null en correspondance', () {
    expect(TimeManagementService.baseTime('180'), 180);
    expect(TimeManagementService.baseTime('180+2'), 180);
    expect(TimeManagementService.baseTime('1/86400'), isNull);
    expect(TimeManagementService.baseTime(null), isNull);
  });

  test('formatGap : signe et m:ss arrondis à la seconde', () {
    expect(TimeManagementService.formatGap(-42.4), '-0:42');
    expect(TimeManagementService.formatGap(65), '+1:05');
    expect(TimeManagementService.formatGap(0.3), '0:00');
  });

  group('aggregate', () {
    // Blitz 3 min : seuil de 10 % = 18 s.
    final games = [
      g('loss', 5, 60, lossCause: 'resigned'), // -55 s : en retard
      g('loss', 40, 70, lossCause: 'resigned'), // -30 s : en retard
      g('loss', 0, 30, lossCause: 'timeout'), // -30 s : en retard
      g('loss', 50, 60, lossCause: 'checkmated'), // -10 s : équilibré
      g('loss', 100, 20, lossCause: 'resigned'), // +80 s : en avance
      g('win', 1, 100), // victoire : ignorée
      g('loss', null, 60), // sans pendule : ignorée
      g('loss', 10, 50, timeClass: 'daily', base: null), // correspondance : ignorée
      g('loss', 2, 20, timeClass: 'bullet', base: 60, lossCause: 'resigned'), // seuil 6 s
    ];

    test('répartition selon un écart de 10 % du temps initial', () {
      final stats = TimeManagementService.aggregate(games, timeClass: 'blitz');
      expect(stats.losses, 5);
      expect(stats.behind, 3);
      expect(stats.balanced, 1);
      expect(stats.ahead, 1);
      expect(stats.averageGap, closeTo((-55 - 30 - 30 - 10 + 80) / 5, 1e-9));
      expect(stats.behindRate, closeTo(0.6, 1e-9));
    });

    test('toutes cadences : seuil propre à chaque partie', () {
      final stats = TimeManagementService.aggregate(games);
      expect(stats.losses, 6);
      // Bullet 1 min, -18 s : en retard (seuil 6 s).
      expect(stats.behind, 4);
      // Seuil moyen : (5 × 18 + 6) / 6.
      expect(stats.averageLimit, closeTo((5 * 18 + 6) / 6, 1e-9));
    });

    test('écart moyen classé avec le seuil moyen', () {
      // Blitz : moyenne -9 s, seuil 18 s => équilibré.
      expect(TimeManagementService.aggregate(games, timeClass: 'blitz').averageCategory,
          TimeGap.balanced);
      // Bullet : -18 s, seuil 6 s => en retard.
      expect(TimeManagementService.aggregate(games, timeClass: 'bullet').averageCategory,
          TimeGap.behind);
      final ahead = TimeManagementService.aggregate([g('loss', 100, 20)]);
      expect(ahead.averageCategory, TimeGap.ahead);
    });

    test('classify : bornes du seuil incluses dans « équilibré »', () {
      expect(TimeManagementService.classify(-18, 18), TimeGap.balanced);
      expect(TimeManagementService.classify(-18.1, 18), TimeGap.behind);
      expect(TimeManagementService.classify(18.1, 18), TimeGap.ahead);
    });

    test('aucune défaite : moyenne et taux à 0', () {
      final stats = TimeManagementService.aggregate(games, timeClass: 'rapid');
      expect(stats.losses, 0);
      expect(stats.averageGap, 0);
      expect(stats.behindRate, 0);
    });
  });

  test('le viewmodel filtre par cadence et notifie', () {
    final viewModel = TimeManagementViewModel([g('loss', 5, 60), g('loss', 2, 20, timeClass: 'bullet', base: 60)]);
    var notified = 0;
    viewModel.addListener(() => notified++);
    expect(viewModel.stats.losses, 2);
    viewModel.setTimeClass('bullet');
    viewModel.setTimeClass('bullet');
    expect(viewModel.stats.losses, 1);
    expect(notified, 1);
  });

  test('toJson / fromJson conserve pendules et temps initial', () {
    final copy = CountryGame.fromJson(g('loss', 5.5, 60, base: 180).toJson());
    expect(copy.playerClock, 5.5);
    expect(copy.opponentClock, 60);
    expect(copy.baseTime, 180);
  });
}
