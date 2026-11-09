import '../models/country_game.dart';
import '../models/opening_family.dart';
import '../models/opening_family_stats.dart';

class OpeningStatsService {
  /// Victoires / nulles / défaites par famille d'ouvertures, de la plus jouée
  /// à la moins jouée (à égalité : ordre alphabétique).
  /// [timeClass] null = toutes les cadences.
  static List<OpeningFamilyStats> aggregate(List<CountryGame> games, {String? timeClass}) {
    final wins = <String, int>{};
    final draws = <String, int>{};
    final losses = <String, int>{};
    final names = <String>{};

    for (final game in games) {
      if (timeClass != null && game.timeClass != timeClass) continue;
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
}
