import 'package:flutter/foundation.dart';
import '../models/country_game.dart';
import '../models/opening_family_stats.dart';
import '../services/opening_stats_service.dart';
import 'country_stats_viewmodel.dart';

class OpeningStatsViewModel extends ChangeNotifier {
  /// Mêmes cadences que le filtre des statistiques par pays.
  static const List<String?> timeClasses = CountryStatsViewModel.timeClasses;

  /// Nombre d'ouvertures affichées par couleur avant la ligne « Autres ».
  static const int topCount = 5;

  final List<CountryGame> _games;
  String? _timeClass;

  OpeningStatsViewModel(List<CountryGame> games) : _games = games;

  String? get timeClass => _timeClass;

  /// Ouvertures jouées avec les blancs : top [topCount] + « Autres ».
  List<OpeningFamilyStats> get white => _forColor('white');

  /// Ouvertures jouées avec les noirs : top [topCount] + « Autres ».
  List<OpeningFamilyStats> get black => _forColor('black');

  List<OpeningFamilyStats> _forColor(String color) => OpeningStatsService.topWithOthers(
        OpeningStatsService.aggregate(_games, timeClass: _timeClass, playerColor: color),
        limit: topCount,
      );

  void setTimeClass(String? timeClass) {
    if (_timeClass == timeClass) return;
    _timeClass = timeClass;
    notifyListeners();
  }
}
