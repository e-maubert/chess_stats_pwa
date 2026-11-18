import '../models/country_game.dart';
import '../services/rating_history_service.dart';
import 'time_class_viewmodel.dart';

/// Courbe(s) de classement : celle de la cadence choisie, ou une par cadence
/// jouée sur « Toutes » (les classements de cadences différentes ne se
/// comparent pas, on ne les mélange donc pas).
class RatingHistoryViewModel extends TimeClassFilteredViewModel {
  /// Cadences qui ont un classement, dans l'ordre d'affichage.
  static const List<String> timeClasses = ['bullet', 'blitz', 'rapid'];

  final List<CountryGame> _games;
  late List<RatingSeries> _series = _compute();

  RatingHistoryViewModel(List<CountryGame> games, [super.filter]) : _games = games;

  /// Courbes affichées ; vide s'il n'y a aucune partie classée.
  List<RatingSeries> get series => _series;

  List<RatingSeries> _compute() {
    final timeClass = this.timeClass;
    return RatingHistoryService.series(
      _games,
      timeClass == null ? timeClasses : timeClasses.where((t) => t == timeClass).toList(),
    );
  }

  @override
  void onTimeClassChanged() => _series = _compute();
}
