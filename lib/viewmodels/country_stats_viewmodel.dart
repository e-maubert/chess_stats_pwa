import 'package:flutter/foundation.dart';
import '../models/country_game.dart';
import '../models/country_stats.dart';
import '../services/country_stats_service.dart';

class CountryStatsViewModel extends ChangeNotifier {
  /// Cadences proposées dans le filtre (null = toutes les parties).
  static const List<String?> timeClasses = [null, 'bullet', 'blitz', 'rapid'];

  final List<CountryGame> _games;
  String? _timeClass;
  CountrySortKey _sortKey = CountrySortKey.gamesPlayed;
  bool _descending = true;

  CountryStatsViewModel(List<CountryGame> games) : _games = games;

  String? get timeClass => _timeClass;
  CountrySortKey get sortKey => _sortKey;
  bool get descending => _descending;

  List<CountryStats> get countries => CountryStatsService.sort(
        CountryStatsService.aggregate(_games, timeClass: _timeClass),
        _sortKey,
        descending: _descending,
      );

  void setTimeClass(String? timeClass) {
    if (_timeClass == timeClass) return;
    _timeClass = timeClass;
    notifyListeners();
  }

  /// Un clic sur la colonne déjà triée inverse l'ordre ; sinon on trie
  /// la nouvelle colonne par ordre décroissant.
  void sortBy(CountrySortKey key) {
    if (_sortKey == key) {
      _descending = !_descending;
    } else {
      _sortKey = key;
      _descending = true;
    }
    notifyListeners();
  }
}
