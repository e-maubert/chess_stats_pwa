import '../models/country_game.dart';
import '../models/opening_family.dart';
import '../models/opening_family_stats.dart';

class OpeningStatsService {
  /// Nom de la ligne qui regroupe les ouvertures hors du top (libellé
  /// traduit à l'affichage).
  static const String others = '__others__';

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

  /// Garde les [limit] premières familles (déjà triées) et regroupe les
  /// suivantes dans une ligne [others], toujours en dernier. Pas de ligne
  /// [others] s'il n'y a rien à regrouper.
  static List<OpeningFamilyStats> topWithOthers(
    List<OpeningFamilyStats> families, {
    int limit = 5,
  }) {
    if (families.length <= limit) return families;
    final rest = families.skip(limit);
    return [
      ...families.take(limit),
      OpeningFamilyStats(
        name: others,
        wins: rest.fold(0, (sum, f) => sum + f.wins),
        draws: rest.fold(0, (sum, f) => sum + f.draws),
        losses: rest.fold(0, (sum, f) => sum + f.losses),
      ),
    ];
  }
}
