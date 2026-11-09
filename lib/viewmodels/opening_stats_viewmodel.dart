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
  OpeningSortKey _sortKey = OpeningSortKey.gamesPlayed;
  bool _descending = true;

  OpeningStatsViewModel(List<CountryGame> games) : _games = games;

  String? get timeClass => _timeClass;
  OpeningSortKey get sortKey => _sortKey;
  bool get descending => _descending;

  /// Ouvertures jouées avec les blancs, triées selon la colonne choisie.
  List<OpeningFamilyStats> get white => _forColor('white');

  /// Ouvertures jouées avec les noirs, triées selon la colonne choisie.
  List<OpeningFamilyStats> get black => _forColor('black');

  List<OpeningFamilyStats> _forColor(String color) => OpeningStatsService.sort(
        OpeningStatsService.aggregate(_games, timeClass: _timeClass, playerColor: color),
        _sortKey,
        descending: _descending,
      );

  void setTimeClass(String? timeClass) {
    if (_timeClass == timeClass) return;
    _timeClass = timeClass;
    notifyListeners();
  }

  /// Un clic sur la colonne déjà triée inverse l'ordre ; sinon on trie
  /// la nouvelle colonne par ordre décroissant. Le tri s'applique aux deux
  /// tableaux (blancs et noirs).
  void sortBy(OpeningSortKey key) {
    if (_sortKey == key) {
      _descending = !_descending;
    } else {
      _sortKey = key;
      _descending = true;
    }
    notifyListeners();
  }
}
