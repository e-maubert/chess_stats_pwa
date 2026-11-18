import 'package:flutter/foundation.dart';

import '../models/country_game.dart';
import '../services/opening_filter_service.dart';
import 'stats_filter_viewmodel.dart';

/// Base des viewmodels de cartes : suit les filtres communs de l'en-tête
/// (cadence, couleur, ouverture) et se met à jour quand ils changent.
///
/// La cadence est passée aux services ([timeClass]) ; la couleur et
/// l'ouverture sont appliquées ici ([filteredGames], [matchesFilters]).
abstract class FilteredStatsViewModel extends ChangeNotifier {
  /// Toutes les parties de la période.
  final List<CountryGame> games;
  final TimeClassViewModel _timeClassFilter;
  final PlayerColorViewModel _colorFilter;
  final OpeningFilterViewModel _openingFilter;
  List<CountryGame>? _filteredGames;
  Set<String>? _otherFamilies;

  /// Sans filtre (tests) : un filtre propre, sans sélection, non mémorisé.
  FilteredStatsViewModel(
    this.games, {
    TimeClassViewModel? timeClassFilter,
    PlayerColorViewModel? colorFilter,
    OpeningFilterViewModel? openingFilter,
  })  : _timeClassFilter = timeClassFilter ?? TimeClassViewModel.temporary(),
        _colorFilter = colorFilter ?? PlayerColorViewModel.temporary(),
        _openingFilter = openingFilter ?? OpeningFilterViewModel() {
    _timeClassFilter.addListener(_onFiltersChanged);
    _colorFilter.addListener(_onFiltersChanged);
    _openingFilter.addListener(_onFiltersChanged);
  }

  TimeClassViewModel get timeClassFilter => _timeClassFilter;
  PlayerColorViewModel get colorFilter => _colorFilter;
  OpeningFilterViewModel get openingFilter => _openingFilter;

  /// Cadence affichée (null = toutes).
  String? get timeClass => _timeClassFilter.timeClass;

  /// Couleur affichée (null = les deux).
  String? get color => _colorFilter.color;

  /// Ouverture affichée (null = toutes).
  String? get opening => _openingFilter.opening;

  /// Vrai si [game] correspond à la couleur et à l'ouverture choisies (la
  /// cadence est laissée aux services).
  bool matchesFilters(CountryGame game) {
    final color = this.color;
    if (color != null && game.playerColor != color) return false;
    return OpeningFilterService.matches(game, opening, _others);
  }

  /// Familles d'« Autres ouvertures » pour les filtres actuels (comme dans
  /// le menu de l'en-tête).
  Set<String> get _others => _otherFamilies ??= OpeningFilterService.otherFamilies(
        OpeningFilterService.options(games, timeClass: timeClass, color: color),
      );

  /// Parties de la couleur et de l'ouverture choisies, toutes cadences.
  List<CountryGame> get filteredGames => _filteredGames ??=
      color == null && opening == null ? games : games.where(matchesFilters).toList();

  void _onFiltersChanged() {
    _filteredGames = null;
    _otherFamilies = null;
    onFiltersChanged();
    notifyListeners();
  }

  /// À surcharger : remise à zéro (pages, cache) quand un filtre change.
  @protected
  void onFiltersChanged() {}

  @override
  void dispose() {
    _timeClassFilter.removeListener(_onFiltersChanged);
    _colorFilter.removeListener(_onFiltersChanged);
    _openingFilter.removeListener(_onFiltersChanged);
    super.dispose();
  }
}
