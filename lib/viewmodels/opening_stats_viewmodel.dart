import 'package:flutter/foundation.dart';
import '../models/country_game.dart';
import '../models/opening_family_stats.dart';
import '../services/opening_stats_service.dart';
import '../services/pagination_service.dart';
import 'country_stats_viewmodel.dart';

class OpeningStatsViewModel extends ChangeNotifier {
  /// Mêmes cadences que le filtre des statistiques par pays.
  static const List<String?> timeClasses = CountryStatsViewModel.timeClasses;

  static const String colorWhite = 'white';
  static const String colorBlack = 'black';

  final List<CountryGame> _games;
  String? _timeClass;
  OpeningSortKey _sortKey = OpeningSortKey.gamesPlayed;
  bool _descending = true;

  /// Page affichée de chaque tableau (blancs, noirs), à partir de 0.
  final Map<String, int> _pages = {colorWhite: 0, colorBlack: 0};

  OpeningStatsViewModel(List<CountryGame> games) : _games = games;

  String? get timeClass => _timeClass;
  OpeningSortKey get sortKey => _sortKey;
  bool get descending => _descending;

  /// Ouvertures jouées avec les blancs, triées selon la colonne choisie.
  List<OpeningFamilyStats> get white => families(colorWhite);

  /// Ouvertures jouées avec les noirs, triées selon la colonne choisie.
  List<OpeningFamilyStats> get black => families(colorBlack);

  /// Ouvertures jouées avec [color] ([colorWhite] ou [colorBlack]), triées
  /// selon la colonne choisie.
  List<OpeningFamilyStats> families(String color) => OpeningStatsService.sort(
        OpeningStatsService.aggregate(_games, timeClass: _timeClass, playerColor: color),
        _sortKey,
        descending: _descending,
      );

  /// Page affichée du tableau de [color] (à partir de 0).
  int page(String color) => PaginationService.clampPage(_pages[color]!, families(color).length);

  /// Ouvertures de la page affichée du tableau de [color].
  List<OpeningFamilyStats> pageFamilies(String color) => PaginationService.pageItems(families(color), _pages[color]!);

  void setPage(String color, int page) {
    final clamped = PaginationService.clampPage(page, families(color).length);
    if (clamped == this.page(color)) return;
    _pages[color] = clamped;
    notifyListeners();
  }

  void _resetPages() => _pages.updateAll((_, __) => 0);

  /// Changer de cadence ou de tri ramène les deux tableaux à leur première
  /// page.
  void setTimeClass(String? timeClass) {
    if (_timeClass == timeClass) return;
    _timeClass = timeClass;
    _resetPages();
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
    _resetPages();
    notifyListeners();
  }
}
