import '../models/country_game.dart';
import '../models/country_stats.dart';

/// Critères de tri du tableau des statistiques par pays.
enum CountrySortKey { gamesPlayed, winRate, drawRate, lossRate }

class CountryStatsService {
  /// Code utilisé pour les adversaires dont le pays est introuvable.
  static const String unknownCountry = 'Unknown';

  /// Regroupe les parties par pays de l'adversaire.
  /// [timeClass] null = toutes les cadences.
  static List<CountryStats> aggregate(
    List<CountryGame> games, {
    String? timeClass,
  }) {
    final stats = <String, CountryStats>{};
    final opponents = <String, Set<String>>{};

    for (final game in games) {
      if (timeClass != null && game.timeClass != timeClass) continue;

      final stat = stats.putIfAbsent(
        game.country,
        () => CountryStats(name: game.country, gamesPlayed: 0, gamesWon: 0),
      );
      stat.gamesPlayed++;
      switch (game.result) {
        case 'win':
          stat.gamesWon++;
          break;
        case 'loss':
          stat.gamesLost++;
          break;
        case 'draw':
          stat.gamesDrawn++;
          break;
      }
      opponents
          .putIfAbsent(game.country, () => <String>{})
          .add(game.opponent.toLowerCase());
    }

    for (final entry in stats.entries) {
      entry.value.opponentsCount = opponents[entry.key]!.length;
    }
    return stats.values.toList();
  }

  /// Trie les pays selon [key]. À égalité, on départage par nombre de
  /// parties puis par code pays pour garder un ordre stable.
  static List<CountryStats> sort(
    List<CountryStats> countries,
    CountrySortKey key, {
    bool descending = true,
  }) {
    double value(CountryStats c) {
      switch (key) {
        case CountrySortKey.gamesPlayed:
          return c.gamesPlayed.toDouble();
        case CountrySortKey.winRate:
          return c.winRate;
        case CountrySortKey.drawRate:
          return c.drawRate;
        case CountrySortKey.lossRate:
          return c.lossRate;
      }
    }

    final sorted = List<CountryStats>.of(countries);
    sorted.sort((a, b) {
      var cmp = value(a).compareTo(value(b));
      if (descending) cmp = -cmp;
      if (cmp != 0) return cmp;
      cmp = b.gamesPlayed.compareTo(a.gamesPlayed);
      if (cmp != 0) return cmp;
      return a.name.compareTo(b.name);
    });
    return sorted;
  }
}
