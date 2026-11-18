import '../models/country_game.dart';

/// Un point de la courbe de classement : classement après une partie.
class RatingPoint {
  final DateTime time;
  final int rating;

  const RatingPoint(this.time, this.rating);
}

/// Courbe de classement d'une cadence (au moins un point).
class RatingSeries {
  final String timeClass;
  final List<RatingPoint> points;

  const RatingSeries(this.timeClass, this.points);

  /// Classement après la dernière partie.
  int get current => points.last.rating;

  /// Variation depuis la première partie de la période.
  int get change => RatingHistoryService.change(points);
}

/// Tendance du classement d'une cadence pour des parties filtrées : somme
/// des points gagnés ou perdus et nombre de parties comptées.
class RatingTrend {
  final String timeClass;
  final int points;
  final int games;

  /// Classement actuel de la cadence (après la dernière partie classée,
  /// toutes couleurs), pour situer le niveau ; null sans partie classée.
  final int? current;

  const RatingTrend(this.timeClass, {required this.points, required this.games, this.current});
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

  /// Points de classement gagnés ou perdus en [timeClass] par les parties
  /// retenues par [include] (ex. une couleur).
  ///
  /// chess.com ne donne que le classement après chaque partie : l'écart se
  /// calcule avec la partie classée précédente de la même cadence, parmi
  /// TOUTES les parties (avant filtre, même si elle a été jouée avec l'autre
  /// couleur). La première partie de la période n'a donc pas d'écart et
  /// n'est pas comptée.
  static RatingTrend trend(List<CountryGame> games, String timeClass, bool Function(CountryGame) include) {
    final rated = [
      for (final game in games)
        if (game.rated && game.timeClass == timeClass && game.rating != null && game.endTime != null) game,
    ]..sort((a, b) => a.endTime!.compareTo(b.endTime!));
    var points = 0;
    var count = 0;
    for (var i = 1; i < rated.length; i++) {
      if (!include(rated[i])) continue;
      points += rated[i].rating! - rated[i - 1].rating!;
      count++;
    }
    return RatingTrend(
      timeClass,
      points: points,
      games: count,
      current: rated.isEmpty ? null : rated.last.rating,
    );
  }

  /// Une courbe par cadence de [timeClasses] (dans cet ordre), en ignorant
  /// les cadences sans partie classée.
  static List<RatingSeries> series(List<CountryGame> games, List<String> timeClasses) => [
        for (final timeClass in timeClasses)
          if (history(games, timeClass) case final points when points.isNotEmpty)
            RatingSeries(timeClass, points),
      ];
}
