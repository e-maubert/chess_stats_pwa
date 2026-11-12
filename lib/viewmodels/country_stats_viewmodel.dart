import 'package:flutter/foundation.dart';
import '../models/country_game.dart';
import '../models/country_stats.dart';
import '../services/country_stats_service.dart';
import '../services/pagination_service.dart';

class CountryStatsViewModel extends ChangeNotifier {
  /// Cadences proposées dans le filtre (null = toutes les parties).
  static const List<String?> timeClasses = [null, 'bullet', 'blitz', 'rapid'];

  final List<CountryGame> _games;
  String? _timeClass;
  CountrySortKey _sortKey = CountrySortKey.gamesPlayed;
  bool _descending = true;
  int _page = 0;

  CountryStatsViewModel(List<CountryGame> games) : _games = games;

  String? get timeClass => _timeClass;
  CountrySortKey get sortKey => _sortKey;
  bool get descending => _descending;

  /// Tous les pays (carte du monde), triés selon la colonne choisie.
  List<CountryStats> get countries => CountryStatsService.sort(
        CountryStatsService.aggregate(_games, timeClass: _timeClass),
        _sortKey,
        descending: _descending,
      );

  /// Page affichée du tableau (à partir de 0).
  int get page => PaginationService.clampPage(_page, countries.length);

  /// Pays de la page affichée du tableau.
  List<CountryStats> get pageCountries => PaginationService.pageItems(countries, _page);

  void setPage(int page) {
    final clamped = PaginationService.clampPage(page, countries.length);
    if (clamped == this.page) return;
    _page = clamped;
    notifyListeners();
  }

  /// Changer de cadence ou de tri ramène à la première page.
  void setTimeClass(String? timeClass) {
    if (_timeClass == timeClass) return;
    _timeClass = timeClass;
    _page = 0;
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
    _page = 0;
    notifyListeners();
  }
}
