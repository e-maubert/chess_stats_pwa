import '../services/rating_history_service.dart';
import 'filtered_stats_viewmodel.dart';

/// Carte du classement.
///
/// Sans filtre de couleur : courbe(s) de classement, celle de la cadence
/// choisie ou une par cadence jouée sur « Toutes » (les classements de
/// cadences différentes ne se comparent pas, on ne les mélange donc pas).
///
/// Avec un filtre de couleur : pas de courbe (le classement ne dépend pas de
/// la couleur, ce serait la même courbe avec des trous) mais la tendance,
/// points gagnés ou perdus avec cette couleur, par cadence.
class RatingHistoryViewModel extends FilteredStatsViewModel {
  /// Cadences qui ont un classement, dans l'ordre d'affichage.
  static const List<String> timeClasses = ['bullet', 'blitz', 'rapid'];

  late List<RatingSeries> _series;
  late List<RatingTrend> _trends;

  RatingHistoryViewModel(super.games, {super.timeClassFilter, super.colorFilter}) {
    _compute();
  }

  /// Vrai : afficher [trends] plutôt que [series].
  bool get showsTrend => color != null;

  /// Courbes affichées ; vide s'il n'y a aucune partie classée.
  List<RatingSeries> get series => _series;

  /// Tendances des cadences affichées qui ont au moins une partie comptée ;
  /// vide s'il n'y en a pas assez.
  List<RatingTrend> get trends => _trends;

  List<String> get _shownTimeClasses {
    final timeClass = this.timeClass;
    return timeClass == null ? timeClasses : timeClasses.where((t) => t == timeClass).toList();
  }

  void _compute() {
    final shown = _shownTimeClasses;
    final color = this.color;
    _series = RatingHistoryService.series(games, shown);
    _trends = color == null
        ? const []
        : [
            for (final timeClass in shown)
              if (RatingHistoryService.trend(games, timeClass, (game) => game.playerColor == color)
                  case final trend when trend.games > 0)
                trend,
          ];
  }

  @override
  void onFiltersChanged() => _compute();
}
