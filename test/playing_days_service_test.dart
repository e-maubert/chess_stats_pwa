import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/services/playing_days_service.dart';
import 'package:chess_stats_pwa/viewmodels/playing_days_viewmodel.dart';
import 'package:chess_stats_pwa/viewmodels/playing_hours_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

CountryGame g(String result, DateTime start, {String timeClass = 'blitz', String color = 'white'}) => CountryGame(
      country: 'FR',
      opponent: 'x',
      timeClass: timeClass,
      result: result,
      playerColor: color,
      opening: 'Italian-Game',
      startTime: start,
    );

/// Date UTC d'une partie : rend les tests indépendants du fuseau du poste.
DateTime? utcDay(CountryGame game) {
  final t = game.startTime!;
  return DateTime(t.year, t.month, t.day);
}

// Lundi 2 novembre 2026 → dimanche 29 novembre 2026 (4 semaines pleines).
final from = DateTime(2026, 11, 2);
final to = DateTime(2026, 11, 29);

PlayingDaysGrid build(List<CountryGame> games, {int firstWeekday = DateTime.monday, String? timeClass}) =>
    PlayingDaysService.build(games,
        from: from, to: to, firstWeekday: firstWeekday, timeClass: timeClass, dayOf: utcDay);

/// [n] parties de résultat [result] le [day] novembre 2026.
List<CountryGame> many(int n, String result, int day) =>
    List.generate(n, (i) => g(result, DateTime.utc(2026, 11, day, 10, i)));

void main() {
  group('build', () {
    test('une colonne par semaine, une case par jour de la période', () {
      final grid = build([]);
      expect(grid.weekStarts.length, 4);
      expect(grid.days.length, 28);
      expect(grid.cell(0, 0)!.date, DateTime(2026, 11, 2));
      expect(grid.cell(3, 6)!.date, DateTime(2026, 11, 29));
    });

    test('semaine commençant le dimanche : cases hors période vides', () {
      final grid = build([], firstWeekday: DateTime.sunday);
      // Dim. 1er nov. (hors période) → la grille commence la veille du 2.
      expect(grid.weekStarts.first, DateTime(2026, 11, 1));
      expect(grid.weekStarts.length, 5);
      expect(grid.cell(0, 0), isNull);
      expect(grid.cell(0, 1)!.date, DateTime(2026, 11, 2));
      expect(grid.cell(4, 0)!.date, DateTime(2026, 11, 29));
      expect(grid.cell(4, 1), isNull);
      expect(grid.weekdays.map((w) => w.weekday), [7, 1, 2, 3, 4, 5, 6]);
    });

    test('parties rangées par date, hors période et correspondance ignorées', () {
      final grid = build([
        g('win', DateTime.utc(2026, 11, 4, 0, 5)),
        g('loss', DateTime.utc(2026, 11, 4, 23, 55)),
        g('draw', DateTime.utc(2026, 11, 5, 0, 0)),
        g('win', DateTime.utc(2026, 11, 1, 12)), // avant la période
        g('win', DateTime.utc(2026, 11, 30, 12)), // après
        g('win', DateTime.utc(2026, 11, 4, 12), timeClass: 'daily'),
      ]);
      final wednesday = grid.cell(0, 2)!;
      expect(wednesday.date, DateTime(2026, 11, 4));
      expect(wednesday.results.wins, 1);
      expect(wednesday.results.losses, 1);
      expect(grid.cell(0, 3)!.results.draws, 1);
      expect(grid.totalGames, 3);
      expect(grid.maxGames, 2);
    });

    test('filtre de cadence', () {
      final grid = build([
        g('win', DateTime.utc(2026, 11, 4, 12)),
        g('win', DateTime.utc(2026, 11, 4, 13), timeClass: 'bullet'),
      ], timeClass: 'bullet');
      expect(grid.totalGames, 1);
    });

    test('colonne finale : total et moyenne de chaque ligne', () {
      final grid = build([
        ...many(3, 'win', 4), // mercredi
        ...many(1, 'loss', 11), // mercredi
      ]);
      final wednesday = grid.weekdays[2];
      expect(wednesday.weekday, DateTime.wednesday);
      expect(wednesday.days, 4);
      expect(wednesday.games, 4);
      expect(wednesday.averageGames, 1.0);
      expect(wednesday.results.score, 0.75);
      expect(grid.weekdays[0].games, 0);
    });
  });

  group('standout', () {
    test('meilleur et moins bon jour quand l\'écart est net', () {
      final grid = build([
        ...many(6, 'win', 4), // mercredi 100 %
        ...many(6, 'loss', 2), // lundi 0 %
        ...many(3, 'win', 3), ...many(3, 'loss', 3), // mardi 50 %
      ]);
      final result = PlayingDaysService.standout(grid.weekdays)!;
      expect(result.best.weekday, DateTime.wednesday);
      expect(result.worst.weekday, DateTime.monday);
    });

    test('même classe de performance : rien à signaler', () {
      // Mercredi 50 % (46-54 %), lundi 56 % (54-60 %) : classes différentes.
      final grid = build([
        ...many(5, 'win', 4), ...many(5, 'loss', 4),
        ...many(5, 'win', 2), ...many(4, 'loss', 2),
      ]);
      expect(PlayingDaysService.standout(grid.weekdays), isNotNull);

      final same = build([
        ...many(5, 'win', 4), ...many(5, 'loss', 4), // 50 %
        ...many(5, 'win', 2), ...many(5, 'loss', 2), // 50 %
      ]);
      expect(PlayingDaysService.standout(same.weekdays), isNull);
    });

    test('jours avec trop peu de parties ignorés', () {
      final grid = build([
        ...many(4, 'win', 4),
        ...many(6, 'loss', 2),
      ]);
      expect(PlayingDaysService.standout(grid.weekdays), isNull);
    });
  });

  group('weekendVsWeek', () {
    test('mieux le week-end', () {
      final grid = build([
        ...many(5, 'win', 7), // samedi
        ...many(1, 'loss', 8), // dimanche
        ...many(3, 'win', 2), ...many(3, 'loss', 3), // semaine 50 %
      ]);
      final result = PlayingDaysService.weekendVsWeek(grid.weekdays)!;
      expect(result.weekend.games, 6);
      expect(result.weekend.wins, 5);
      expect(result.week.score, 0.5);
    });

    test('pas d\'écart net ou pas assez de parties : null', () {
      final even = build([...many(3, 'win', 7), ...many(3, 'loss', 8), ...many(3, 'win', 2), ...many(3, 'loss', 3)]);
      expect(PlayingDaysService.weekendVsWeek(even.weekdays), isNull);
      final few = build([...many(4, 'win', 7), ...many(6, 'loss', 2)]);
      expect(PlayingDaysService.weekendVsWeek(few.weekdays), isNull);
    });
  });

  group('viewmodel', () {
    PlayingDaysViewModel vm(List<CountryGame> games) =>
        PlayingDaysViewModel(games, from: from, to: to, firstWeekday: DateTime.monday);

    test('clic : ouvre puis referme la bulle', () {
      final model = vm([]);
      model.tap((week: 1, row: 2));
      expect(model.selected, (week: 1, row: 2));
      model.tap((week: 1, row: 2));
      expect(model.selected, isNull);
    });

    test('lien du meilleur jour : colonne finale en mode Performance', () {
      final model = vm([]);
      model.showWeekday(3);
      expect(model.mode, PlayingHoursMode.performance);
      expect(model.isTotalColumn(model.selected!), isTrue);
      expect(model.selected!.row, 3);
    });

    test('filtre de couleur : grille recalculée, bulle fermée', () {
      final model = vm([
        g('win', DateTime.utc(2026, 11, 4, 12)),
        g('win', DateTime.utc(2026, 11, 4, 13), color: 'black'),
      ]);
      model.tap((week: 0, row: 2));
      expect(model.grid.totalGames, greaterThan(0));
      model.colorFilter.select('black');
      expect(model.selected, isNull);
      expect(model.grid.totalGames, 1);
    });
  });
}
