import 'package:flutter/foundation.dart';
import '../models/country_game.dart';
import '../services/playing_hours_service.dart';
import 'country_stats_viewmodel.dart';

/// Ce qu'affiche le cadran des heures de jeu.
enum PlayingHoursMode {
  /// Nombre de parties par heure (bleu plus ou moins intense).
  activity,

  /// Performance par heure, du rouge au vert en passant par le jaune.
  performance,
}

class PlayingHoursViewModel extends ChangeNotifier {
  /// Mêmes cadences que les autres filtres.
  static const List<String?> timeClasses = CountryStatsViewModel.timeClasses;

  final List<CountryGame> _games;
  String? _timeClass;
  PlayingHoursMode _mode = PlayingHoursMode.activity;
  int? _selectedHour;

  PlayingHoursViewModel(List<CountryGame> games) : _games = games;

  String? get timeClass => _timeClass;
  PlayingHoursMode get mode => _mode;

  /// Heure dont la bulle de détail est affichée, null si aucune.
  int? get selectedHour => _selectedHour;

  List<HourStats> get hours => PlayingHoursService.aggregate(_games, timeClass: _timeClass);

  void setTimeClass(String? timeClass) {
    if (_timeClass == timeClass) return;
    _timeClass = timeClass;
    notifyListeners();
  }

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
