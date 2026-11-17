import 'package:flutter/foundation.dart';
import '../models/country_game.dart';
import '../services/game_phase_stats_service.dart';
import 'country_stats_viewmodel.dart';

class GamePhaseStatsViewModel extends ChangeNotifier {
  /// Mêmes cadences que les autres filtres.
  static const List<String?> timeClasses = CountryStatsViewModel.timeClasses;

  final List<CountryGame> _games;
  String? _timeClass;
  GamePhaseStats? _stats;

  GamePhaseStatsViewModel(List<CountryGame> games) : _games = games;

  String? get timeClass => _timeClass;

  GamePhaseStats get stats => _stats ??= GamePhaseStatsService.aggregate(_games, timeClass: _timeClass);

  void setTimeClass(String? timeClass) {
    if (_timeClass == timeClass) return;
    _timeClass = timeClass;
    _stats = null;
    notifyListeners();
  }
}
