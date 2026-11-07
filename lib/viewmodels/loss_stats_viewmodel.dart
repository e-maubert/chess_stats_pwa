import 'package:flutter/foundation.dart';
import '../models/country_game.dart';
import '../models/loss_stats.dart';
import '../services/loss_stats_service.dart';
import 'country_stats_viewmodel.dart';

class LossStatsViewModel extends ChangeNotifier {
  /// Mêmes cadences que le filtre des statistiques par pays.
  static const List<String?> timeClasses = CountryStatsViewModel.timeClasses;

  final List<CountryGame> _games;
  String? _timeClass;

  LossStatsViewModel(List<CountryGame> games) : _games = games;

  String? get timeClass => _timeClass;

  LossStats get stats => LossStatsService.aggregate(_games, timeClass: _timeClass);

  void setTimeClass(String? timeClass) {
    if (_timeClass == timeClass) return;
    _timeClass = timeClass;
    notifyListeners();
  }
}
