import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/services/playing_hours_service.dart';
import 'package:chess_stats_pwa/viewmodels/playing_hours_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

CountryGame g(
  String result, {
  String timeClass = 'blitz',
  DateTime? start,
  DateTime? end,
}) =>
    CountryGame(
      country: 'FR',
      opponent: 'x',
      timeClass: timeClass,
      result: result,
      playerColor: 'white',
      opening: 'Italian-Game',
      startTime: start,
      endTime: end,
    );

/// Heure UTC d'une partie : rend les tests indépendants du fuseau du poste.
int? utcHour(CountryGame game) => (game.startTime ?? game.endTime)?.toUtc().hour;

DateTime at(int hour, [int minute = 0]) => DateTime.utc(2026, 11, 4, hour, minute);

List<HourStats> agg(List<CountryGame> games, {String? timeClass}) =>
    PlayingHoursService.aggregate(games, timeClass: timeClass, hourOf: utcHour);

void main() {
  group('startTimeFromPgn', () {
    test('lit UTCDate et UTCTime, en UTC', () {
      const pgn = '[Date "2026.11.04"]\n[UTCDate "2026.11.04"]\n[UTCTime "13:24:28"]\n'
          '[StartTime "13:24:28"]\n\n1. e4 1-0';
      final start = PlayingHoursService.startTimeFromPgn(pgn)!;
      expect(start, DateTime.utc(2026, 11, 4, 13, 24, 28));
      expect(start.isUtc, isTrue);
    });

    test('en-tête manquant : null', () {
      expect(PlayingHoursService.startTimeFromPgn('[UTCDate "2026.11.04"]'), isNull);
      expect(PlayingHoursService.startTimeFromPgn('[UTCTime "13:24:28"]'), isNull);
      expect(PlayingHoursService.startTimeFromPgn(''), isNull);
    });

    test('convertie dans le fuseau local, une partie de 14h02 UTC est à 15h en UTC+1', () {
      final start = PlayingHoursService.startTimeFromPgn(
          '[UTCDate "2026.11.13"]\n[UTCTime "14:02:10"]')!;
      final local = start.toLocal();
      expect(local.isAtSameMomentAs(start), isTrue);
      expect(local.hour, (14 + local.timeZoneOffset.inHours) % 24);
    });
  });

  group('aggregate', () {
    test('24 heures, parties rangées selon leur heure de début', () {
      final hours = agg([
        g('win', start: at(15, 2)),
        g('loss', start: at(15, 59)),
        g('draw', start: at(0, 10)),
      ]);
      expect(hours, hasLength(24));
      expect(hours[15].games, 2);
      expect(hours[15].wins, 1);
      expect(hours[15].losses, 1);
      expect(hours[0].draws, 1);
      expect(hours[14].games, 0);
    });

    test('début inconnu : heure de fin ; ni l\'un ni l\'autre : ignorée', () {
      final hours = agg([
        g('win', end: at(9, 30)),
        g('win', start: at(20), end: at(21)),
        g('win'),
      ]);
      expect(hours[9].games, 1);
      expect(hours[20].games, 1);
      expect(hours[21].games, 0);
      expect(hours.fold<int>(0, (s, h) => s + h.games), 2);
    });

    test('parties par correspondance toujours exclues, filtre de cadence', () {
      final games = [
        g('win', start: at(10)),
        g('win', start: at(10), timeClass: 'bullet'),
        g('win', start: at(10), timeClass: 'daily'),
      ];
      expect(agg(games)[10].games, 2);
      expect(agg(games, timeClass: 'bullet')[10].games, 1);
      expect(agg(games, timeClass: 'daily')[10].games, 0);
    });

    test('heure locale par défaut', () {
      final game = g('win', start: at(13));
      final hours = PlayingHoursService.aggregate([game]);
      expect(hours[at(13).toLocal().hour].games, 1);
    });
  });

  test('score : victoires + ½ nulles', () {
    const h = HourStats(hour: 0, wins: 2, draws: 1, losses: 1);
    expect(h.score, closeTo(0.625, 1e-9));
    expect(const HourStats(hour: 0).score, 0);
  });

  test('seuil de 5 parties pour juger une heure', () {
    expect(const HourStats(hour: 0, wins: 4).judged, isFalse);
    expect(const HourStats(hour: 0, wins: 4, losses: 1).judged, isTrue);
  });

  test('classes de performance, bornes en pour cent arrondi', () {
    expect(PlayingHoursService.band(0.0), PerformanceBand.veryLow);
    expect(PlayingHoursService.band(0.39), PerformanceBand.veryLow);
    expect(PlayingHoursService.band(0.40), PerformanceBand.low);
    expect(PlayingHoursService.band(0.45), PerformanceBand.low);
    expect(PlayingHoursService.band(0.46), PerformanceBand.even);
    expect(PlayingHoursService.band(0.5), PerformanceBand.even);
    expect(PlayingHoursService.band(0.54), PerformanceBand.even);
    expect(PlayingHoursService.band(0.55), PerformanceBand.high);
    expect(PlayingHoursService.band(0.60), PerformanceBand.high);
    expect(PlayingHoursService.band(0.61), PerformanceBand.veryHigh);
    expect(PlayingHoursService.band(1.0), PerformanceBand.veryHigh);
    // 0,4545… s'affiche « 45 % » : rouge clair, pas jaune.
    expect(PlayingHoursService.band(5 / 11), PerformanceBand.low);
  });

  group('bestAndWorst', () {
    test('seules les heures d\'au moins 5 parties comptent', () {
      final result = PlayingHoursService.bestAndWorst(const [
        HourStats(hour: 3, wins: 4), // 100 % mais 4 parties
        HourStats(hour: 14, wins: 4, losses: 1), // 80 %
        HourStats(hour: 22, wins: 1, losses: 5), // 17 %
        HourStats(hour: 20, wins: 3, losses: 3), // 50 %
      ])!;
      expect(result.best.hour, 14);
      expect(result.worst!.hour, 22);
    });

    test('à score égal, l\'heure qui a le plus de parties', () {
      final result = PlayingHoursService.bestAndWorst(const [
        HourStats(hour: 1, wins: 5),
        HourStats(hour: 2, wins: 8),
        HourStats(hour: 3, losses: 5),
        HourStats(hour: 4, losses: 9),
      ])!;
      expect(result.best.hour, 2);
      expect(result.worst!.hour, 4);
    });

    test('une seule heure jugée : pas de moins bonne ; aucune : null', () {
      final one = PlayingHoursService.bestAndWorst(const [HourStats(hour: 8, wins: 5)])!;
      expect(one.best.hour, 8);
      expect(one.worst, isNull);
      expect(PlayingHoursService.bestAndWorst(const [HourStats(hour: 8, wins: 4)]), isNull);
    });
  });

  test('maxGames', () {
    expect(PlayingHoursService.maxGames(const [HourStats(hour: 0, wins: 2), HourStats(hour: 1, losses: 7)]), 7);
    expect(PlayingHoursService.maxGames(const []), 0);
  });

  test('viewmodel : cadence, mode et heure sélectionnée', () {
    final vm = PlayingHoursViewModel([
      g('win', start: at(10)),
      g('win', start: at(10), timeClass: 'bullet'),
    ]);
    expect(vm.mode, PlayingHoursMode.activity);
    expect(vm.hours.fold<int>(0, (s, h) => s + h.games), 2);
    vm.timeClassFilter.select('bullet');
    expect(vm.hours.fold<int>(0, (s, h) => s + h.games), 1);
    vm.setMode(PlayingHoursMode.performance);
    expect(vm.mode, PlayingHoursMode.performance);
    vm.tapHour(10);
    expect(vm.selectedHour, 10);
    vm.tapHour(11);
    expect(vm.selectedHour, 11);
    // Nouveau clic sur la même heure, ou hors des tranches : bulle fermée.
    vm.tapHour(11);
    expect(vm.selectedHour, isNull);
    vm.tapHour(3);
    vm.tapHour(null);
    expect(vm.selectedHour, isNull);
  });

  test('viewmodel : lien vers un créneau, en mode Performance, bulle ouverte', () {
    final vm = PlayingHoursViewModel([g('win', start: at(10))]);
    vm.showHour(14);
    expect(vm.mode, PlayingHoursMode.performance);
    expect(vm.selectedHour, 14);
    // Un second clic sur le même lien laisse la bulle ouverte.
    vm.showHour(14);
    expect(vm.selectedHour, 14);
  });
}
