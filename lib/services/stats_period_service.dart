import '../models/country_game.dart';
import '../models/stats_period.dart';

/// Parties d'une période glissante : les [StatsPeriod.days] derniers jours.
class StatsPeriodService {
  /// Début de la période à la date [now].
  static DateTime start(StatsPeriod period, DateTime now) => now.subtract(Duration(days: period.days));

  /// Parties terminées depuis le début de la période (celles sans date de
  /// fin sont écartées), et seulement les parties classées si [ratedOnly].
  /// Les services d'agrégation reçoivent cette liste.
  static List<CountryGame> filter(List<CountryGame> games, StatsPeriod period, DateTime now, {bool ratedOnly = false}) {
    final from = start(period, now);
    return [
      for (final game in games)
        if (game.endTime != null && !game.endTime!.isBefore(from) && (!ratedOnly || game.rated)) game,
    ];
  }

  /// Parties classées de [games] ; toutes s'il n'y en a aucune de classée
  /// (joueur qui ne fait que des parties non classées).
  static List<CountryGame> preferRated(List<CountryGame> games) {
    final rated = games.where((g) => g.rated).toList();
    return rated.isEmpty ? games : rated;
  }
}
