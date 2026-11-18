import '../services/playing_hours_service.dart';
import 'filtered_stats_viewmodel.dart';

/// Ce qu'affiche le cadran des heures de jeu.
enum PlayingHoursMode {
  /// Nombre de parties par heure (bleu plus ou moins intense).
  activity,

  /// Performance par heure, du rouge au vert en passant par le jaune.
  performance,
}

class PlayingHoursViewModel extends FilteredStatsViewModel {
  PlayingHoursMode _mode = PlayingHoursMode.activity;
  int? _selectedHour;

  PlayingHoursViewModel(super.games, {super.timeClassFilter, super.colorFilter});

  PlayingHoursMode get mode => _mode;

  /// Heure dont la bulle de détail est affichée, null si aucune.
  int? get selectedHour => _selectedHour;

  List<HourStats> get hours => PlayingHoursService.aggregate(filteredGames, timeClass: timeClass);

  void setMode(PlayingHoursMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  /// Lien « meilleur / moins bon créneau » : montre [hour] sur le cadran en
  /// mode Performance, bulle ouverte (jamais refermée par ce lien).
  void showHour(int hour) {
    _mode = PlayingHoursMode.performance;
    _selectedHour = hour;
    notifyListeners();
  }

  /// Clic sur le cadran : ouvre la bulle de l'heure [hour], ou la ferme si
  /// c'est déjà celle-ci ou si le clic est hors des tranches ([hour] null),
  /// comme sur la carte des pays.
  void tapHour(int? hour) {
    _selectedHour = hour == _selectedHour ? null : hour;
    notifyListeners();
  }
}
