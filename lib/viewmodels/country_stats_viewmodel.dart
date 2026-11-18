import '../models/country_map_mode.dart';
import '../models/country_stats.dart';
import '../services/country_stats_service.dart';
import '../services/pagination_service.dart';
import 'filtered_stats_viewmodel.dart';

class CountryStatsViewModel extends FilteredStatsViewModel {
  CountrySortKey _sortKey = CountrySortKey.gamesPlayed;
  bool _descending = true;
  int _page = 0;
  CountryMapMode _mapMode = CountryMapMode.gamesPlayed;

  CountryStatsViewModel(super.games, {super.timeClassFilter, super.colorFilter, super.openingFilter});

  /// Carte affichée : parties jouées ou performance. Ne change ni le
  /// tableau ni sa page.
  CountryMapMode get mapMode => _mapMode;

  void setMapMode(CountryMapMode mode) {
    if (_mapMode == mode) return;
    _mapMode = mode;
    notifyListeners();
  }

  CountrySortKey get sortKey => _sortKey;
  bool get descending => _descending;

  /// Tous les pays (carte du monde), triés selon la colonne choisie.
  List<CountryStats> get countries => CountryStatsService.sort(
        CountryStatsService.aggregate(filteredGames, timeClass: timeClass),
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
  @override
  void onFiltersChanged() => _page = 0;

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
