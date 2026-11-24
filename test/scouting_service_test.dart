import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/models/stats_period.dart';
import 'package:chess_stats_pwa/services/game_phase_service.dart';
import 'package:chess_stats_pwa/services/scouting_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 23, 12);

  /// Conseils d'ouverture, de cadence et de forme du plan de jeu (les
  /// parties de test, une par heure, font aussi réagir l'après-défaite).
  const openingTips = {
    ScoutingTip.cadence,
    ScoutingTip.whiteTarget,
    ScoutingTip.whiteAvoid,
    ScoutingTip.blackTarget,
    ScoutingTip.blackAvoid,
    ScoutingTip.form,
  };
  List<ScoutingTip> openingPlan(ScoutingReport report) =>
      ScoutingService.plan(report).where(openingTips.contains).toList();

  /// [count] parties identiques, une par heure en remontant depuis
  /// [daysAgo] jours.
  List<CountryGame> games(
    int count, {
    String timeClass = 'blitz',
    String result = 'win',
    String color = 'white',
    String opening = 'Italian-Game',
    int daysAgo = 1,
    int? rating,
    bool rated = true,
    List<String>? moves,
  }) =>
      [
        for (var i = 0; i < count; i++)
          CountryGame(
            opponent: 'opp$i',
            timeClass: timeClass,
            result: result,
            playerColor: color,
            opening: opening,
            rated: rated,
            rating: rating,
            openingMoves: moves,
            endTime: now.subtract(Duration(days: daysAgo, hours: i)),
          ),
      ];

  group('période et cadence analysée', () {
    test('la cadence la plus jouée du mois', () {
      final report = ScoutingService.build([...games(25), ...games(8, timeClass: 'rapid')], now)!;
      expect(report.period, StatsPeriod.oneMonth);
      expect(report.timeClass, 'blitz');
      expect(report.games, 25);
    });

    test('trop peu de parties sur un mois : 3 mois', () {
      final report = ScoutingService.build([...games(5), ...games(30, daysAgo: 50)], now)!;
      expect(report.period, StatsPeriod.threeMonths);
      expect(report.games, 35);
    });

    test('parties par correspondance écartées, aucune autre : pas de rapport', () {
      expect(ScoutingService.build(games(30, timeClass: 'daily'), now), isNull);
      expect(ScoutingService.build(const [], now), isNull);
    });

    test('parties non classées écartées quand il y en a de classées', () {
      final report = ScoutingService.build([...games(25), ...games(40, timeClass: 'bullet', rated: false)], now)!;
      expect(report.timeClass, 'blitz');
    });

    test('cadence choisie : analysée même si elle est moins jouée', () {
      final all = [...games(30), ...games(22, timeClass: 'bullet', result: 'checkmated')];
      expect(ScoutingService.build(all, now)!.isMain, isTrue);

      final report = ScoutingService.build(all, now, timeClass: 'bullet')!;
      expect(report.timeClass, 'bullet');
      expect(report.isMain, isFalse);
      expect(report.period, StatsPeriod.oneMonth);
      expect(report.games, 22);
      expect(report.analyzed.every((g) => g.timeClass == 'bullet'), isTrue);
    });

    test('cadence choisie peu jouée sur un mois : 3 mois ; moins de 3 parties : pas de rapport', () {
      final all = [...games(30), ...games(5, timeClass: 'rapid'), ...games(10, timeClass: 'rapid', daysAgo: 50)];
      final report = ScoutingService.build(all, now, timeClass: 'rapid')!;
      expect(report.period, StatsPeriod.threeMonths);
      expect(report.games, 15);

      expect(ScoutingService.build([...games(30), ...games(2, timeClass: 'bullet')], now, timeClass: 'bullet'), isNull);
    });

    test('phase et gestion du temps proposées seulement avec assez de parties', () {
      final few = ScoutingService.build(games(7), now)!;
      expect(few.phasesPossible, isFalse);
      expect(few.timePossible, isFalse);

      final some = ScoutingService.build(games(9), now)!;
      expect(some.phasesPossible, isTrue);
      expect(some.timePossible, isFalse);

      final many = ScoutingService.build(games(10), now)!;
      expect(many.phasesPossible, isTrue);
      expect(many.timePossible, isTrue);
    });

    test('cadences proposées au choix : au moins 3 parties sur 3 mois', () {
      final all = [
        ...games(30),
        ...games(2, timeClass: 'bullet'),
        ...games(3, timeClass: 'rapid', daysAgo: 60),
        ...games(10, timeClass: 'daily'),
      ];
      expect(ScoutingService.choosableTimeClasses(all, now), ['blitz', 'rapid']);
    });
  });

  group('forme du moment', () {
    FormLevel level(int? change, int wins, int losses, {int draws = 0}) =>
        ScoutingService.formLevel(ratingChange: change, recent: GameResults(wins: wins, draws: draws, losses: losses));

    test('les cinq niveaux', () {
      expect(level(120, 14, 6), FormLevel.legendary);
      expect(level(40, 11, 9), FormLevel.good);
      expect(level(5, 10, 10), FormLevel.steady);
      expect(level(-40, 9, 11), FormLevel.slump);
      expect(level(-90, 6, 14), FormLevel.collapse);
    });

    test('jamais en forme avec plus de défaites que de victoires', () {
      // +60 points mais 9 victoires pour 11 défaites : stable.
      expect(level(60, 9, 11), FormLevel.steady);
      // Beaucoup de nulles : 8 victoires, 4 nulles, 8 défaites.
      expect(level(120, 8, 8, draws: 4), FormLevel.steady);
    });

    test('jamais en difficulté avec plus de victoires que de défaites', () {
      expect(level(-60, 11, 9), FormLevel.steady);
    });

    test('signaux contraires : forme stable', () {
      expect(level(50, 7, 13), FormLevel.steady);
      expect(level(-50, 14, 6), FormLevel.steady);
    });

    test('légendaire exige aussi un bon score récent', () {
      expect(level(150, 11, 9), FormLevel.good);
    });

    test('variation du classement et score des dernières parties', () {
      final history = [
        for (var i = 0; i < 30; i++)
          CountryGame(
            opponent: 'o',
            timeClass: 'blitz',
            result: i < 20 ? 'win' : 'loss',
            playerColor: 'white',
            opening: 'Italian-Game',
            rating: 1500 + i * 5,
            endTime: now.subtract(Duration(hours: i)),
          ),
      ];
      final form = ScoutingService.build(history, now)!.form;
      // 20 dernières parties : i = 0 à 19 ; classement d'avant : i = 20
      // (1600), dernier : i = 0 (1500).
      expect(form.ratingChange, -100);
      expect(form.currentRating, 1500);
      expect(form.recent.games, 20);
      expect(form.recent.wins, 20);
      expect(form.recent.winRate, 1.0);
    });
  });

  group('cadence la plus faible', () {
    test('la plus jouée est aussi la plus faible', () {
      final report = ScoutingService.build([
        ...games(15, result: 'loss'),
        ...games(10, result: 'win'),
        ...games(12, timeClass: 'rapid'),
      ], now)!;
      expect(report.cadence.kind, CadenceCase.same);
      expect(report.cadence.weakest, 'blitz');
    });

    test('une autre cadence, assez jouée, plus faible', () {
      final report = ScoutingService.build([
        ...games(30),
        ...games(12, timeClass: 'rapid', result: 'loss'),
      ], now)!;
      expect(report.cadence.kind, CadenceCase.other);
      expect(report.cadence.weakest, 'rapid');
      expect(report.cadence.weakestResults.games, 12);
      expect(report.cadence.weakestResults.winRate, 0);
      expect(report.cadence.byWinRate, isTrue);
      expect(ScoutingService.plan(report).first, ScoutingTip.cadence);
    });

    test('trop peu de parties : comparaison au classement, signalée', () {
      final report = ScoutingService.build([
        ...games(30, rating: 2000),
        ...games(6, timeClass: 'rapid', rating: 1800),
      ], now)!;
      expect(report.cadence.kind, CadenceCase.otherFewGames);
      expect(report.cadence.weakest, 'rapid');
      expect(report.cadence.byWinRate, isFalse);
      expect(ScoutingService.plan(report), isNot(contains(ScoutingTip.cadence)));
    });

    test("autre cadence sur moins de 3 parties : on n'en dit rien", () {
      final report = ScoutingService.build([
        ...games(30, rating: 2000),
        ...games(2, timeClass: 'rapid', rating: 1800),
      ], now)!;
      expect(report.cadence.kind, CadenceCase.focusOnly);
      expect(report.cadence.weakest, 'blitz');
      expect(ScoutingService.plan(report), isNot(contains(ScoutingTip.cadence)));
    });

    test('une seule cadence', () {
      expect(ScoutingService.build(games(30), now)!.cadence.kind, CadenceCase.single);
    });
  });

  group('ouvertures par couleur', () {
    test('top 3 des familles, inconnues écartées', () {
      final report = ScoutingService.build([
        ...games(10, opening: 'Italian-Game'),
        ...games(8, opening: 'Sicilian-Defense'),
        ...games(6, opening: 'French-Defense'),
        ...games(2, opening: 'Caro-Kann-Defense'),
        ...games(4, opening: 'Unknown-Opening'),
      ], now)!;
      expect(report.white.games, 30);
      expect(report.white.top.map((o) => o.family), ['Italian-Game', 'Sicilian-Defense', 'French-Defense']);
    });

    test('avec les blancs : réponse à son premier coup habituel', () {
      final report = ScoutingService.build([
        ...games(12, moves: ['d4', 'd5'], result: 'win'),
        ...games(8, moves: ['d4', 'e6'], result: 'loss'),
        ...games(3, moves: ['d4', 'Nf6'], result: 'loss'),
        ...games(5, moves: ['e4', 'c5'], result: 'loss'),
      ], now)!;
      final white = report.white;
      expect(white.mainMove?.move, 'd4');
      expect(white.mainMoveShare, closeTo(23 / 28, 1e-9));
      // 1…e6 : 0 % sur 8 ; 1…Nf6 trop peu jouée ; 1.e4 n'est pas son coup
      // habituel.
      expect(white.target?.move, 'e6');
      expect(white.target?.games, 8);
      expect(white.avoid?.move, 'd5');
      expect(ScoutingService.plan(report), contains(ScoutingTip.whiteTarget));
    });

    test("avec les noirs : premier coup de l'adversaire", () {
      final report = ScoutingService.build([
        ...games(10, color: 'black', moves: ['e4', 'c5'], result: 'win'),
        ...games(6, color: 'black', moves: ['d4', 'Nf6'], result: 'loss'),
        ...games(7, color: 'white', moves: ['e4', 'e5'], result: 'win', daysAgo: 4),
        ...games(7, color: 'white', moves: ['e4', 'e5'], result: 'loss', daysAgo: 5),
      ], now)!;
      final black = report.black;
      expect(black.mainMove, isNull);
      expect(black.target?.move, 'd4');
      expect(black.avoid?.move, 'e4');
      expect(openingPlan(report), [ScoutingTip.blackTarget, ScoutingTip.form]);
    });

    test('à éviter : un gros échantillon passe devant un 100 % sur peu de parties', () {
      List<CountryGame> asBlack(int count, String move, String result, {int daysAgo = 1}) =>
          games(count, color: 'black', moves: [move, 'e5'], result: result, daysAgo: daysAgo);
      // 1.e4 : 26/30 (lissé 27/32 = 84 %) ; 1.c4 : 5/5 (lissé 6/7 = 86 %).
      final report = ScoutingService.build([
        ...asBlack(5, 'c4', 'win'),
        ...asBlack(26, 'e4', 'win'),
        ...asBlack(4, 'e4', 'loss', daysAgo: 2),
      ], now)!;
      expect(report.black.avoid?.move, 'c4');
      // 1.e4 : 40/42 (lissé 41/44 = 93 %) : passe devant.
      final more = ScoutingService.build([
        ...asBlack(5, 'c4', 'win'),
        ...asBlack(40, 'e4', 'win'),
        ...asBlack(2, 'e4', 'loss', daysAgo: 2),
      ], now)!;
      expect(more.black.avoid?.move, 'e4');
    });

    test('coup trop peu joué ou coups inconnus : pas de conseil', () {
      final report = ScoutingService.build([
        ...games(10, moves: ['e4', 'e5'], result: 'win', daysAgo: 4),
        ...games(10, moves: ['e4', 'e5'], result: 'loss', daysAgo: 5),
        ...games(4, moves: ['e4', 'c6'], result: 'loss'),
        ...games(10, color: 'black'),
      ], now)!;
      expect(report.white.target, isNull);
      expect(report.white.avoid, isNull);
      expect(report.black.target, isNull);
      expect(openingPlan(report), [ScoutingTip.form]);
    });

    test("plan de jeu : cadence et ouvertures d'abord, 4 conseils au plus", () {
      final report = ScoutingService.build([
        ...games(20, moves: ['e4', 'c5'], result: 'loss'),
        ...games(10, moves: ['e4', 'e5'], result: 'win', daysAgo: 3),
        ...games(10, color: 'black', moves: ['d4', 'd5'], result: 'loss'),
        ...games(12, timeClass: 'rapid', result: 'loss'),
        ...games(20, timeClass: 'rapid', result: 'loss', daysAgo: 2),
      ], now)!;
      expect(ScoutingService.plan(report).take(3), [ScoutingTip.cadence, ScoutingTip.whiteTarget, ScoutingTip.blackTarget]);
      expect(ScoutingService.plan(report).length, lessThanOrEqualTo(ScoutingService.planSize));
    });
  });

  group('premiers coups', () {
    test('lus dans le PGN, pendules et résultat ignorés', () {
      const text = '1. d4 {[%clk 0:02:59.9]} 1... e6 {[%clk 0:02:58]} 2. c4 {[%clk 0:02:57]} 1-0';
      expect(GamePhaseService.firstMoves(text), ['d4', 'e6']);
      expect(GamePhaseService.firstMoves('1. e4 1-0'), ['e4']);
      expect(GamePhaseService.firstMoves('0-1'), isNull);
      expect(GamePhaseService.firstMoves(null), isNull);
    });

    test('conservés dans le stockage', () {
      final game = games(1, moves: ['d4', 'e6']).single;
      expect(CountryGame.fromJson(game.toJson()).openingMoves, ['d4', 'e6']);
    });
  });
}
