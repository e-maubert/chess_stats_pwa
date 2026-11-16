import '../models/country_game.dart';

/// Un point de la courbe de classement : classement après une partie.
class RatingPoint {
  final DateTime time;
  final int rating;

  const RatingPoint(this.time, this.rating);
}

/// Évolution du classement sur la période, calculée à partir des parties.
class RatingHistoryService {
  /// Classement après chaque partie classée de la cadence [timeClass],
  /// dans l'ordre chronologique. Les parties sans classement ou sans date
  /// sont ignorées.
  static List<RatingPoint> history(List<CountryGame> games, String timeClass) {
    final points = [
      for (final game in games)
        if (game.rated &&
            game.timeClass == timeClass &&
            game.rating != null &&
            game.endTime != null)
          RatingPoint(game.endTime!, game.rating!),
    ];
    points.sort((a, b) => a.time.compareTo(b.time));
    return points;
  }

  /// Variation depuis la première partie de la période : chess.com ne donne que
  /// le classement après chaque partie, la première partie sert donc de
  /// point de départ. 0 s'il n'y a pas de point.
  static int change(List<RatingPoint> points) =>
      points.isEmpty ? 0 : points.last.rating - points.first.rating;

  /// Cadence parmi [timeClasses] qui a le plus de parties classées
  /// (la première de la liste en cas d'égalité ou s'il n'y en a aucune).
  static String mostPlayed(List<CountryGame> games, List<String> timeClasses) {
    var best = timeClasses.first;
    var bestCount = 0;
    for (final timeClass in timeClasses) {
      final count = history(games, timeClass).length;
      if (count > bestCount) {
        best = timeClass;
        bestCount = count;
      }
    }
    return best;
  }
}
