import '../models/color_stats.dart';
import '../services/color_stats_service.dart';
import 'filtered_stats_viewmodel.dart';
import 'stats_filter_viewmodel.dart';

/// Une jauge de la carte « Statistiques de victoire » : [color] 'white',
/// 'black', ou null pour l'ensemble des parties.
typedef WinStatsRow = ({String? color, ColorStats stats});

class ColorStatsViewModel extends FilteredStatsViewModel {
  ColorStatsViewModel(super.games, {super.timeClassFilter, super.colorFilter, super.openingFilter});

  ({ColorStats white, ColorStats black}) get stats =>
      ColorStatsService.aggregate(filteredGames, timeClass: timeClass);

  /// Sans filtre de couleur : ensemble, blancs, noirs (les deux couleurs se
  /// jouent différemment, on les garde côte à côte). Avec : la seule couleur
  /// choisie.
  List<WinStatsRow> get rows {
    final stats = this.stats;
    return switch (color) {
      PlayerColorViewModel.white => [(color: PlayerColorViewModel.white, stats: stats.white)],
      PlayerColorViewModel.black => [(color: PlayerColorViewModel.black, stats: stats.black)],
      _ => [
          (color: null, stats: ColorStatsService.combine(stats.white, stats.black)),
          (color: PlayerColorViewModel.white, stats: stats.white),
          (color: PlayerColorViewModel.black, stats: stats.black),
        ],
    };
  }
}
