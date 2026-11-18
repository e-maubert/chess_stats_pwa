import '../models/color_stats.dart';
import '../models/country_game.dart';

class ColorStatsService {
  /// Victoires / défaites / nulles avec les blancs et avec les noirs.
  /// [timeClass] null = toutes les cadences.
  static ({ColorStats white, ColorStats black}) aggregate(
    List<CountryGame> games, {
    String? timeClass,
  }) {
    ColorStats count(String color) {
      var wins = 0;
      var losses = 0;
      var draws = 0;
      for (final game in games) {
        if (game.playerColor != color) continue;
        if (timeClass != null && game.timeClass != timeClass) continue;
        switch (game.result) {
          case 'win':
            wins++;
            break;
          case 'loss':
            losses++;
            break;
          case 'draw':
            draws++;
            break;
        }
      }
      return ColorStats(wins: wins, losses: losses, draws: draws);
    }

    return (white: count('white'), black: count('black'));
  }

  /// Somme de deux bilans (ex. blancs + noirs = toutes les parties).
  static ColorStats combine(ColorStats a, ColorStats b) => ColorStats(
        wins: a.wins + b.wins,
        losses: a.losses + b.losses,
        draws: a.draws + b.draws,
      );
}
