import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/models/game_phase_summary.dart';
import 'package:chess_stats_pwa/services/loss_stats_service.dart';
import 'package:chess_stats_pwa/services/scouting_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 23, 12);

  /// Une partie de blitz terminée [minutesAgo] minutes avant [now].
  CountryGame game(
    String result, {
    int minutesAgo = 60,
    GamePhase? endPhase,
    double? clockMiddle,
    double? clockEnd,
    String? lossCause,
  }) =>
      CountryGame(
        opponent: 'x',
        timeClass: 'blitz',
        result: result,
        playerColor: 'white',
        opening: 'Italian-Game',
        lossCause: lossCause,
        baseTime: 180,
        endTime: now.subtract(Duration(minutes: minutesAgo)),
        phases: endPhase == null
            ? null
            : GamePhaseSummary(
                endPhase: endPhase,
                playerClockAtMiddlegame: clockMiddle,
                opponentClockAtMiddlegame: clockMiddle == null ? null : 120,
                playerClockAtEndgame: endPhase == GamePhase.endgame ? clockEnd : null,
                opponentClockAtEndgame: endPhase == GamePhase.endgame && clockEnd != null ? 60 : null,
              ),
      );

  /// [count] parties identiques espacées d'un jour (pas d'effet
  /// après-défaite).
  List<CountryGame> spaced(int count, String result, {int fromDay = 1, GamePhase? endPhase}) => [
        for (var i = 0; i < count; i++) game(result, minutesAgo: (fromDay + i) * 24 * 60, endPhase: endPhase),
      ];

  group('phase où il craque', () {
    test('phase la moins réussie, nettement sous son habitude', () {
      final games = [
        ...spaced(10, 'win', endPhase: GamePhase.middlegame),
        ...spaced(2, 'loss', fromDay: 11, endPhase: GamePhase.middlegame),
        ...spaced(3, 'win', fromDay: 13, endPhase: GamePhase.endgame),
        ...spaced(7, 'loss', fromDay: 16, endPhase: GamePhase.endgame),
        ...spaced(3, 'win', fromDay: 23, endPhase: GamePhase.opening),
      ];
      final insight = ScoutingService.phases(games)!;
      expect(insight.byPhase[GamePhase.endgame]!.games, 10);
      // Ouverture : 3 parties seulement, pas comparée.
      expect(insight.weakest, GamePhase.endgame);
      expect(insight.notable, isTrue);
    });

    test('phases inconnues : rien', () {
      expect(ScoutingService.phases(spaced(20, 'win')), isNull);
    });

    test('une seule phase assez jouée : pas de phase fragile', () {
      final insight = ScoutingService.phases(spaced(20, 'win', endPhase: GamePhase.middlegame))!;
      expect(insight.weakest, isNull);
    });
  });

  group('gestion du temps', () {
    List<CountryGame> clocks(int count, double middle, {double? end, String result = 'win'}) => [
          for (var i = 0; i < count; i++)
            game(result,
                minutesAgo: (i + 1) * 24 * 60,
                endPhase: end == null ? GamePhase.middlegame : GamePhase.endgame,
                clockMiddle: middle,
                clockEnd: end),
        ];

    test('en retard à la pendule : lent', () {
      // Sortie d'ouverture : 90 s contre 120 s sur 180 s (-17 %).
      final insight = ScoutingService.time(clocks(12, 90))!;
      expect(insight.gapAtMiddlegame, closeTo(-30 / 180, 1e-9));
      expect(insight.gapAtEndgame, isNull);
      expect(insight.profile, TimeProfile.slow);
    });

    test('en avance : rapide', () {
      // Finale : 100 s contre 60 s (+22 %).
      final insight = ScoutingService.time(clocks(12, 130, end: 100))!;
      expect(insight.profile, TimeProfile.fast);
    });

    test('beaucoup de défaites au temps : lent même sans retard moyen', () {
      final games = [
        ...clocks(8, 120),
        for (var i = 0; i < 4; i++)
          game('loss',
              minutesAgo: (20 + i) * 24 * 60,
              endPhase: GamePhase.middlegame,
              clockMiddle: 120,
              lossCause: LossStatsService.timeout),
      ];
      final insight = ScoutingService.time(games)!;
      expect(insight.timeoutShare, 1.0);
      expect(insight.profile, TimeProfile.slow);
    });

    test('trop peu de parties chronométrées : rien', () {
      expect(ScoutingService.time(clocks(5, 90)), isNull);
    });
  });

  group('après une défaite', () {
    /// Séries « défaite puis partie 20 minutes après », un jour d'écart
    /// entre les séries.
    List<CountryGame> pairs(int count, String after) => [
          for (var i = 0; i < count; i++) ...[
            game('loss', minutesAgo: (i + 1) * 24 * 60),
            game(after, minutesAgo: (i + 1) * 24 * 60 - 20),
          ],
        ];

    test('il perd ses moyens juste après une défaite', () {
      final report = ScoutingService.build([...pairs(10, 'loss'), ...spaced(20, 'win', fromDay: 12)], now)!;
      expect(report.tilt.afterLoss.games, 10);
      expect(report.tilt.kind, TiltKind.tilts);
      expect(ScoutingService.plan(report), contains(ScoutingTip.tilt));
    });

    test('une défaite le motive', () {
      final report = ScoutingService.build([...pairs(10, 'win'), ...spaced(10, 'loss', fromDay: 12)], now)!;
      expect(report.tilt.kind, TiltKind.resilient);
    });

    test('partie suivante plus d\'une heure après : pas comptée', () {
      final games = [
        for (var i = 0; i < 10; i++) ...[
          game('loss', minutesAgo: (i + 1) * 24 * 60),
          game('loss', minutesAgo: (i + 1) * 24 * 60 - 90),
        ],
      ];
      final report = ScoutingService.build(games, now)!;
      expect(report.tilt.afterLoss.games, 0);
      expect(report.tilt.kind, TiltKind.unknown);
    });
  });

  group('selon l\'heure', () {
    test('moments de la journée', () {
      expect(ScoutingService.dayPart(5), DayPart.morning);
      expect(ScoutingService.dayPart(12), DayPart.afternoon);
      expect(ScoutingService.dayPart(21), DayPart.evening);
      expect(ScoutingService.dayPart(23), DayPart.night);
      expect(ScoutingService.dayPart(4), DayPart.night);
    });

    test('moment où il gagne le moins', () {
      final evening = spaced(12, 'win');
      final night = [...spaced(4, 'win', fromDay: 20), ...spaced(8, 'loss', fromDay: 30)];
      final report = ScoutingService.build(
        [...evening, ...night],
        now,
        hourOf: (g) => evening.contains(g) ? 20 : 23,
      )!;
      expect(report.hours.byPart[DayPart.evening]!.games, 12);
      expect(report.hours.weakest, DayPart.night);
      expect(report.hours.notable, isTrue);
    });
  });
}
