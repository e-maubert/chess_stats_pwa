import 'package:flutter/foundation.dart';
import '../models/country_game.dart';
import '../models/opening_family_stats.dart';
import '../services/opening_stats_service.dart';
import 'country_stats_viewmodel.dart';

class OpeningStatsViewModel extends ChangeNotifier {
  /// Mêmes cadences que le filtre des statistiques par pays.
  static const List<String?> timeClasses = CountryStatsViewModel.timeClasses;

  final List<CountryGame> _games;
  String? _timeClass;

  OpeningStatsViewModel(List<CountryGame> games) : _games = games;

  String? get timeClass => _timeClass;

  List<OpeningFamilyStats> get families =>
      OpeningStatsService.aggregate(_games, timeClass: _timeClass);

  void setTimeClass(String? timeClass) {
    if (_timeClass == timeClass) return;
    _timeClass = timeClass;
    notifyListeners();
  }
}
