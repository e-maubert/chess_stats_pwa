import '../models/country_game.dart';

/// Résultats des parties commencées dans une heure de la journée.
class HourStats {
  /// Heure locale de début, de 0 à 23 (tranche [hour] h – [hour] + 1 h).
  final int hour;
  final int wins;
  final int draws;
  final int losses;

  const HourStats({required this.hour, this.wins = 0, this.draws = 0, this.losses = 0});

  int get games => wins + draws + losses;

  /// Performance, comme un score de tournoi : (victoires + ½ nulles) /
  /// parties, entre 0 et 1.
  double get score => games > 0 ? (wins + draws / 2) / games : 0;

  /// Assez de parties pour juger la performance de cette heure.
  bool get judged => games >= PlayingHoursService.minGames;

  HourStats _add(String result) => HourStats(
        hour: hour,
        wins: wins + (result == 'win' ? 1 : 0),
        draws: draws + (result == 'draw' ? 1 : 0),
        losses: losses + (result == 'loss' ? 1 : 0),
      );
}

/// Classe de performance d'une heure, de la plus faible à la meilleure.
enum PerformanceBand { veryLow, low, even, high, veryHigh }

/// Heures de jeu : parties de la période réparties par heure locale de début,
/// avec la performance de chaque heure.
class PlayingHoursService {
  /// En dessous, une heure n'a pas assez de parties pour juger sa
  /// performance.
  static const int minGames = 5;

  /// Cadence exclue : l'heure de début d'une partie par correspondance ne
  /// dit rien du moment où l'on joue ses coups.
  static const String excludedTimeClass = 'daily';

  static final RegExp _utcDate = RegExp(r'\[UTCDate "(\d{4})\.(\d{2})\.(\d{2})"\]');
  static final RegExp _utcTime = RegExp(r'\[UTCTime "(\d{2}):(\d{2}):(\d{2})"\]');

  /// Début de la partie d'après les en-têtes PGN `[UTCDate]` et `[UTCTime]`
  /// de chess.com (en UTC), null si l'un des deux manque.
  static DateTime? startTimeFromPgn(String pgn) {
    final date = _utcDate.firstMatch(pgn);
    final time = _utcTime.firstMatch(pgn);
    if (date == null || time == null) return null;
    int n(RegExpMatch m, int group) => int.parse(m.group(group)!);
    return DateTime.utc(n(date, 1), n(date, 2), n(date, 3), n(time, 1), n(time, 2), n(time, 3));
  }

  /// Heure locale (fuseau du navigateur) du début de la partie, ou de sa
  /// fin si le début est inconnu ; null si on ne connaît ni l'un ni l'autre.
  static int? localHour(CountryGame game) => (game.startTime ?? game.endTime)?.toLocal().hour;

  /// Les 24 heures de la journée, dans l'ordre, pour la cadence [timeClass]
  /// (null = toutes, sauf les parties par correspondance). [hourOf] donne
  /// l'heure d'une partie (par défaut [localHour]) ; les parties sans heure
  /// sont ignorées.
  static List<HourStats> aggregate(
    List<CountryGame> games, {
    String? timeClass,
    int? Function(CountryGame)? hourOf,
  }) {
    final hours = List.generate(24, (hour) => HourStats(hour: hour));
    for (final game in games) {
      if (game.timeClass == excludedTimeClass) continue;
      if (timeClass != null && game.timeClass != timeClass) continue;
      final hour = (hourOf ?? localHour)(game);
      if (hour == null) continue;
      hours[hour] = hours[hour]._add(game.result);
    }
    return hours;
  }

  /// Classe de performance d'un [score] entre 0 et 1 : moins de 40 %,
  /// 40 à 46 %, 46 à 54 % (équilibre), 54 à 60 %, plus de 60 %.
  static PerformanceBand band(double score) {
    // Arrondi au pour cent, comme le score affiché : la couleur ne
    // contredit jamais le pourcentage lu.
    final percent = (score * 100).round();
    if (percent < 40) return PerformanceBand.veryLow;
    if (percent < 46) return PerformanceBand.low;
    if (percent <= 54) return PerformanceBand.even;
    if (percent <= 60) return PerformanceBand.high;
    return PerformanceBand.veryHigh;
  }

  /// Meilleure et moins bonne heure parmi celles qui ont assez de parties
  /// (à score égal, celle qui en a le plus). null s'il n'y en a aucune ;
  /// [worst] est null s'il n'y en a qu'une.
  static ({HourStats best, HourStats? worst})? bestAndWorst(List<HourStats> hours) {
    final judged = hours.where((h) => h.judged).toList();
    if (judged.isEmpty) return null;
    int compare(HourStats a, HourStats b) {
      final byScore = a.score.compareTo(b.score);
      return byScore != 0 ? byScore : a.games.compareTo(b.games);
    }

    final best = judged.reduce((a, b) => compare(a, b) >= 0 ? a : b);
    if (judged.length == 1) return (best: best, worst: null);
    // À score égal, la moins bonne est aussi celle qui a le plus de parties.
    final worst = judged.reduce((a, b) {
      final byScore = a.score.compareTo(b.score);
      if (byScore != 0) return byScore < 0 ? a : b;
      return a.games >= b.games ? a : b;
    });
    return (best: best, worst: worst);
  }

  /// Plus grand nombre de parties sur une heure (intensité du bleu).
  static int maxGames(List<HourStats> hours) =>
      hours.fold(0, (max, h) => h.games > max ? h.games : max);
}
