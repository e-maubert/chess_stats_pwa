import 'package:flutter/foundation.dart';
import '../models/color_stats.dart';
import '../models/country_game.dart';
import '../services/color_stats_service.dart';
import 'country_stats_viewmodel.dart';

class ColorStatsViewModel extends ChangeNotifier {
  /// Mêmes cadences que le filtre des statistiques par pays.
  static const List<String?> timeClasses = CountryStatsViewModel.timeClasses;

  final List<CountryGame> _games;
  String? _timeClass;

  ColorStatsViewModel(List<CountryGame> games) : _games = games;

  String? get timeClass => _timeClass;

  ({ColorStats white, ColorStats black}) get stats =>
      ColorStatsService.aggregate(_games, timeClass: _timeClass);

  void setTimeClass(String? timeClass) {
    if (_timeClass == timeClass) return;
    _timeClass = timeClass;
    notifyListeners();
  }
}
