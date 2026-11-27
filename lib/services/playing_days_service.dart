import '../models/country_game.dart';
import 'playing_hours_service.dart';

/// Victoires, nulles et défaites d'un ensemble de parties.
class ResultCounts {
  final int wins;
  final int draws;
  final int losses;

  const ResultCounts({this.wins = 0, this.draws = 0, this.losses = 0});

  int get games => wins + draws + losses;

  /// Performance, comme un score de tournoi : (victoires + ½ nulles) /
  /// parties, entre 0 et 1.
  double get score => games > 0 ? (wins + draws / 2) / games : 0;

  /// Assez de parties pour juger la performance (même seuil que les heures
  /// de jeu).
  bool get judged => games >= PlayingHoursService.minGames;

  ResultCounts operator +(ResultCounts other) =>
      ResultCounts(wins: wins + other.wins, draws: draws + other.draws, losses: losses + other.losses);

  ResultCounts add(String result) => ResultCounts(
        wins: wins + (result == 'win' ? 1 : 0),
        draws: draws + (result == 'draw' ? 1 : 0),
        losses: losses + (result == 'loss' ? 1 : 0),
      );
}

/// Résultats des parties commencées un jour donné (date locale).
class DayStats {
  /// Jour, à minuit (heure locale).
  final DateTime date;
  final ResultCounts results;

  const DayStats(this.date, [this.results = const ResultCounts()]);

  int get games => results.games;
}

/// Résultats de tous les jours de la période tombant un même jour de la
/// semaine (tous les lundis…).
class WeekdayStats {
  /// [DateTime.monday] (1) à [DateTime.sunday] (7).
  final int weekday;

  /// Nombre de ces jours dans la période (joués ou non).
  final int days;
  final ResultCounts results;

  const WeekdayStats({required this.weekday, required this.days, this.results = const ResultCounts()});

  int get games => results.games;

  /// Parties en moyenne par jour : total de la ligne / nombre de ces jours
  /// dans la période.
  double get averageGames => days > 0 ? games / days : 0;
}

/// Grille façon GitHub : une colonne par semaine, une ligne par jour de la
/// semaine, plus le total de chaque ligne.
class PlayingDaysGrid {
  /// Premier jour (à minuit) de chaque colonne.
  final List<DateTime> weekStarts;

  /// Premier jour de la semaine ([DateTime.monday]… [DateTime.sunday]) : la
  /// ligne 0.
  final int firstWeekday;

  /// Premier et dernier jour de la période (à minuit, inclus).
  final DateTime from;
  final DateTime to;

  /// Jours de la période, dans l'ordre.
  final List<DayStats> days;

  /// Les 7 lignes, dans l'ordre d'affichage (à partir de [firstWeekday]).
  final List<WeekdayStats> weekdays;

  const PlayingDaysGrid({
    required this.weekStarts,
    required this.firstWeekday,
    required this.from,
    required this.to,
    required this.days,
    required this.weekdays,
  });

  /// Case de la colonne [week] et de la ligne [row] ; null hors de la
  /// période (début de la première semaine, fin de la dernière).
  DayStats? cell(int week, int row) {
    final date = PlayingDaysService.addDays(weekStarts[week], row);
    if (date.isBefore(from) || date.isAfter(to)) return null;
    return days[PlayingDaysService.daysBetween(from, date)];
  }

  int get totalGames => days.fold(0, (sum, d) => sum + d.games);

  /// Plus grand nombre de parties sur un jour (intensité du bleu, aussi
  /// pour les moyennes de la colonne finale).
  int get maxGames => days.fold(0, (max, d) => d.games > max ? d.games : max);
}

/// Jours de jeu : parties de la période réparties par date locale de début,
/// et par jour de la semaine.
class PlayingDaysService {
  /// Date (à minuit, heure locale) du début de la partie, ou de sa fin si le
  /// début est inconnu. Le jour change à minuit pile.
  static DateTime? localDay(CountryGame game) {
    final time = (game.startTime ?? game.endTime)?.toLocal();
    return time == null ? null : DateTime(time.year, time.month, time.day);
  }

  /// [date] + [days] jours, à minuit (sans décalage aux changements d'heure).
  static DateTime addDays(DateTime date, int days) => DateTime(date.year, date.month, date.day + days);

  /// Nombre de jours de [from] à [to] (dates à minuit).
  static int daysBetween(DateTime from, DateTime to) =>
      DateTime.utc(to.year, to.month, to.day).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

  /// Grille de [from] à [to] (dates, incluses), semaines commençant le
  /// [firstWeekday], pour la cadence [timeClass] (null = toutes, sauf les
  /// parties par correspondance, comme les heures de jeu). [dayOf] donne la
  /// date d'une partie (par défaut [localDay]) ; les parties hors de la
  /// période ou sans date sont ignorées.
  static PlayingDaysGrid build(
    List<CountryGame> games, {
    required DateTime from,
    required DateTime to,
    required int firstWeekday,
    String? timeClass,
    DateTime? Function(CountryGame)? dayOf,
  }) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    final length = daysBetween(from, to) + 1;
    final counts = List.filled(length, const ResultCounts());
    for (final game in games) {
      if (game.timeClass == PlayingHoursService.excludedTimeClass) continue;
      if (timeClass != null && game.timeClass != timeClass) continue;
      final day = (dayOf ?? localDay)(game);
      if (day == null) continue;
      final index = daysBetween(from, day);
      if (index < 0 || index >= length) continue;
      counts[index] = counts[index].add(game.result);
    }
    final days = [for (var i = 0; i < length; i++) DayStats(addDays(from, i), counts[i])];

    final first = addDays(from, -((from.weekday - firstWeekday) % 7));
    final weekStarts = [for (var d = first; !d.isAfter(to); d = addDays(d, 7)) d];

    final weekdays = [
      for (var row = 0; row < 7; row++)
        () {
          final weekday = (firstWeekday - 1 + row) % 7 + 1;
          final matching = days.where((d) => d.date.weekday == weekday);
          return WeekdayStats(
            weekday: weekday,
            days: matching.length,
            results: matching.fold(const ResultCounts(), (sum, d) => sum + d.results),
          );
        }(),
    ];

    return PlayingDaysGrid(
      weekStarts: weekStarts,
      firstWeekday: firstWeekday,
      from: from,
      to: to,
      days: days,
      weekdays: weekdays,
    );
  }

  /// Meilleur et moins bon jour de la semaine, parmi ceux qui ont assez de
  /// parties (à score égal, celui qui en a le plus). null s'il y en a moins
  /// de deux ou si l'écart n'est pas net (même classe de performance).
  static ({WeekdayStats best, WeekdayStats worst})? standout(List<WeekdayStats> weekdays) {
    final judged = weekdays.where((w) => w.results.judged).toList();
    if (judged.length < 2) return null;
    int compare(WeekdayStats a, WeekdayStats b) {
      final byScore = a.results.score.compareTo(b.results.score);
      return byScore != 0 ? byScore : a.games.compareTo(b.games);
    }

    final best = judged.reduce((a, b) => compare(a, b) >= 0 ? a : b);
    final worst = judged.reduce((a, b) {
      final byScore = a.results.score.compareTo(b.results.score);
      if (byScore != 0) return byScore < 0 ? a : b;
      return a.games >= b.games ? a : b;
    });
    if (!_clearGap(best.results, worst.results)) return null;
    return (best: best, worst: worst);
  }

  /// Week-end (samedi et dimanche) et semaine (lundi à vendredi) ; null si
  /// l'un des deux n'a pas assez de parties ou si l'écart n'est pas net.
  static ({ResultCounts weekend, ResultCounts week})? weekendVsWeek(List<WeekdayStats> weekdays) {
    var weekend = const ResultCounts();
    var week = const ResultCounts();
    for (final w in weekdays) {
      if (w.weekday == DateTime.saturday || w.weekday == DateTime.sunday) {
        weekend += w.results;
      } else {
        week += w.results;
      }
    }
    if (!weekend.judged || !week.judged || !_clearGap(weekend, week)) return null;
    return (weekend: weekend, week: week);
  }

  /// Écart net : les deux scores ne sont pas dans la même classe de
  /// performance (couleur).
  static bool _clearGap(ResultCounts a, ResultCounts b) =>
      PlayingHoursService.band(a.score) != PlayingHoursService.band(b.score);
}
