import '../models/country_game.dart';
import '../models/opening_family.dart';
import '../models/opening_family_stats.dart';

/// Colonnes de tri du tableau des ouvertures.
enum OpeningSortKey { gamesPlayed, winRate, drawRate, lossRate }

class OpeningStatsService {
  /// Victoires / nulles / défaites par famille d'ouvertures, de la plus jouée
  /// à la moins jouée (à égalité : ordre alphabétique).
  /// [timeClass] null = toutes les cadences ; [playerColor] ('white' ou
  /// 'black') null = les deux couleurs.
  static List<OpeningFamilyStats> aggregate(
    List<CountryGame> games, {
    String? timeClass,
    String? playerColor,
  }) {
    final wins = <String, int>{};
    final draws = <String, int>{};
    final losses = <String, int>{};
    final names = <String>{};

    for (final game in games) {
      if (timeClass != null && game.timeClass != timeClass) continue;
      if (playerColor != null && game.playerColor != playerColor) continue;
      final family = OpeningFamily.getFamilyName(game.opening);
      names.add(family);
      switch (game.result) {
        case 'win':
          wins[family] = (wins[family] ?? 0) + 1;
          break;
        case 'draw':
          draws[family] = (draws[family] ?? 0) + 1;
          break;
        case 'loss':
          losses[family] = (losses[family] ?? 0) + 1;
          break;
      }
    }

    return names
        .map((name) => OpeningFamilyStats(
              name: name,
              wins: wins[name] ?? 0,
              draws: draws[name] ?? 0,
              losses: losses[name] ?? 0,
            ))
        .where((stats) => stats.totalGames > 0)
        .toList()
      ..sort((a, b) {
        final byGames = b.totalGames.compareTo(a.totalGames);
        return byGames != 0 ? byGames : a.name.compareTo(b.name);
      });
  }

  /// Trie les familles selon [key]. À égalité : la plus jouée d'abord, puis
  /// ordre alphabétique (quel que soit le sens du tri).
  static List<OpeningFamilyStats> sort(
    List<OpeningFamilyStats> families,
    OpeningSortKey key, {
    bool descending = true,
  }) {
    double value(OpeningFamilyStats f) {
      switch (key) {
        case OpeningSortKey.gamesPlayed:
          return f.totalGames.toDouble();
        case OpeningSortKey.winRate:
          return f.winRate;
        case OpeningSortKey.drawRate:
          return f.drawRate;
        case OpeningSortKey.lossRate:
          return f.lossRate;
      }
    }

    return List<OpeningFamilyStats>.of(families)
      ..sort((a, b) {
        var cmp = value(a).compareTo(value(b));
        if (descending) cmp = -cmp;
        if (cmp != 0) return cmp;
        cmp = b.totalGames.compareTo(a.totalGames);
        if (cmp != 0) return cmp;
        return a.name.compareTo(b.name);
      });
  }
}
