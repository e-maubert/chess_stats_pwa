import 'package:flutter/foundation.dart';
import '../models/country_game.dart';
import '../services/time_management_service.dart';
import 'country_stats_viewmodel.dart';

class TimeManagementViewModel extends ChangeNotifier {
  /// Mêmes cadences que les autres filtres.
  static const List<String?> timeClasses = CountryStatsViewModel.timeClasses;

  final List<CountryGame> _games;
  String? _timeClass;

  TimeManagementViewModel(List<CountryGame> games) : _games = games;

  String? get timeClass => _timeClass;

  TimeManagementStats get stats =>
      TimeManagementService.aggregate(_games, timeClass: _timeClass);

  void setTimeClass(String? timeClass) {
    if (_timeClass == timeClass) return;
    _timeClass = timeClass;
    notifyListeners();
  }
}
