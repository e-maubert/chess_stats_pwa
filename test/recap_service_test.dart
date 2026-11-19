import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/services/recap_service.dart';
import 'package:flutter_test/flutter_test.dart';

CountryGame g(
  String result, {
  int day = 1,
  int hour = 12,
  String timeClass = 'blitz',
  String opening = 'Italian-Game',
  String opponent = 'x',
  String? lossCause,
  int? rating,
  bool rated = true,
}) =>
    CountryGame(
      opponent: opponent,
      timeClass: timeClass,
      result: result,
      playerColor: 'white',
      opening: opening,
      lossCause: result == 'loss' ? (lossCause ?? 'resigned') : null,
      rating: rating,
      rated: rated,
      endTime: DateTime.utc(2026, 11, day, hour),
    );

int? utcHour(CountryGame game) => game.endTime?.toUtc().hour;
DateTime? utcDay(CountryGame game) {
  final end = game.endTime!.toUtc();
  return DateTime.utc(end.year, end.month, end.day);
}

PlayerRecap? build(List<CountryGame> games) => RecapService.build(games, hourOf: utcHour, dayOf: utcDay);

void main() {
  test('aucune partie : pas de bilan', () {
    expect(build(const []), isNull);
  });

  test('bilan global : parties, résultats et score', () {
    final recap = build([g('win'), g('win'), g('draw'), g('loss')])!;
    expect(recap.games, 4);
    expect((recap.wins, recap.draws, recap.losses), (2, 1, 1));
    expect(recap.score, 0.625);
  });

  test('cadence favorite, classement de cette cadence seulement', () {
    final recap = build([
      g('win', day: 1, timeClass: 'blitz', rating: 1500),
      g('loss', day: 2, timeClass: 'blitz', rating: 1490),
      g('win', day: 3, timeClass: 'blitz', rating: 1560),
      g('win', day: 4, timeClass: 'blitz', rating: 1530),
      g('win', day: 5, timeClass: 'bullet', rating: 2000),
      // Partie non classée : ignorée pour le classement.
      g('win', day: 6, timeClass: 'blitz', rating: 1700, rated: false),
    ])!;
    expect(recap.favoriteTimeClass, 'blitz');
    expect(recap.favoriteTimeClassGames, 5);
    expect(recap.ratingChange, 30);
    expect(recap.peakRating, 1560);
  });

  test('plus longue série de victoires, dans l\'ordre chronologique', () {
    final recap = build([
      g('win', day: 5),
      g('win', day: 1),
      g('loss', day: 2),
      g('win', day: 3),
      g('win', day: 4),
      g('draw', day: 6),
    ])!;
    expect(recap.longestWinStreak, 3);
  });

  test('ouverture favorite et ouverture la plus réussie (assez jouée, différente)', () {
    final recap = build([
      for (var i = 0; i < 6; i++) g(i < 3 ? 'win' : 'loss', opening: 'Sicilian-Defense-Najdorf'),
      for (var i = 0; i < 5; i++) g(i < 4 ? 'win' : 'draw', opening: 'Italian-Game'),
      // Très réussie mais pas assez jouée.
      for (var i = 0; i < 2; i++) g('win', opening: 'French-Defense'),
      for (var i = 0; i < 9; i++) g('loss', opening: 'Unknown-Opening'),
    ])!;
    expect(recap.favoriteOpening, 'Sicilian-Defense');
    expect(recap.favoriteOpeningGames, 6);
    expect(recap.favoriteOpeningScore, 0.5);
    expect(recap.bestOpening, 'Italian-Game');
    expect(recap.bestOpeningScore, 0.9);
  });

  test('pas d\'ouverture « la plus réussie » si c\'est la favorite', () {
    final recap = build([for (var i = 0; i < 6; i++) g('win', opening: 'Italian-Game')])!;
    expect(recap.favoriteOpening, 'Italian-Game');
    expect(recap.bestOpening, isNull);
  });

  test('heure favorite et jour le plus chargé', () {
    final recap = build([
      g('win', day: 1, hour: 21),
      g('win', day: 2, hour: 21),
      g('win', day: 2, hour: 9),
      g('win', day: 2, hour: 10),
    ])!;
    expect(recap.favoriteHour, 21);
    expect(recap.busiestDay, DateTime.utc(2026, 11, 2));
    expect(recap.busiestDayGames, 3);
  });

  test('adversaire le plus affronté (casse ignorée), au moins deux parties', () {
    final recap = build([
      g('win', opponent: 'Alice'),
      g('loss', opponent: 'alice'),
      g('draw', opponent: 'ALICE'),
      g('win', opponent: 'Bob'),
      g('win', opponent: 'Bob'),
    ])!;
    expect(recap.topOpponent!.name, 'Alice');
    expect((recap.topOpponent!.wins, recap.topOpponent!.draws, recap.topOpponent!.losses), (1, 1, 1));

    expect(build([g('win', opponent: 'a'), g('win', opponent: 'b')])!.topOpponent, isNull);
  });

  test('point faible : ouverture assez jouée la moins réussie', () {
    final recap = build([
      for (var i = 0; i < 8; i++) g(i < 6 ? 'win' : 'loss', opening: 'Sicilian-Defense'),
      for (var i = 0; i < 5; i++) g(i < 1 ? 'win' : 'loss', opening: 'French-Defense'),
      for (var i = 0; i < 5; i++) g(i < 3 ? 'win' : 'loss', opening: 'Italian-Game'),
      // Pire encore, mais pas assez jouée.
      for (var i = 0; i < 3; i++) g('loss', opening: 'Scandinavian-Defense'),
    ])!;
    expect(recap.weakOpening, 'French-Defense');
    expect(recap.weakOpeningGames, 5);
    expect(recap.weakOpeningScore, 0.2);
  });

  test('pas de point faible avec moins de deux ouvertures assez jouées', () {
    final recap = build([for (var i = 0; i < 6; i++) g('loss', opening: 'Italian-Game')])!;
    expect(recap.weakOpening, isNull);
  });

  test("ambiance de l'heure : un créneau par phrase", () {
    expect([for (var h = 0; h < 24; h++) RecapService.hourMood(h).name], [
      for (var h = 0; h < 5; h++) 'nightOwl',
      for (var h = 5; h < 9; h++) 'earlyBird',
      for (var h = 9; h < 12; h++) 'morning',
      for (var h = 12; h < 14; h++) 'lunch',
      for (var h = 14; h < 18; h++) 'afternoon',
      for (var h = 18; h < 22; h++) 'evening',
      for (var h = 22; h < 24; h++) 'nightOwl',
    ]);
  });

  test('ambiance du nombre de parties, aux limites', () {
    expect(RecapService.volumeMood(9), VolumeMood.casual);
    expect(RecapService.volumeMood(10), VolumeMood.regular);
    expect(RecapService.volumeMood(49), VolumeMood.regular);
    expect(RecapService.volumeMood(50), VolumeMood.everyDay);
    expect(RecapService.volumeMood(200), VolumeMood.enthusiast);
    expect(RecapService.volumeMood(500), VolumeMood.nonStop);
    expect(RecapService.perWeek(30, 30), 7);
    expect(RecapService.perDay(240, 30), 8);
  });

  test("ambiance du score, d'après le pourcentage arrondi affiché", () {
    expect(RecapService.scoreMood(0.70), ScoreMood.dominant);
    expect(RecapService.scoreMood(0.696), ScoreMood.dominant);
    expect(RecapService.scoreMood(0.55), ScoreMood.winning);
    expect(RecapService.scoreMood(0.5), ScoreMood.balanced);
    expect(RecapService.scoreMood(0.44), ScoreMood.tough);
    expect(RecapService.scoreMood(0.2), ScoreMood.learning);
  });
}
