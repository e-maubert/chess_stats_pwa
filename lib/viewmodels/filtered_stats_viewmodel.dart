import 'package:flutter/foundation.dart';

import '../models/country_game.dart';
import 'stats_filter_viewmodel.dart';

/// Base des viewmodels de cartes : suit les filtres communs de l'en-tête
/// (cadence, couleur) et se met à jour quand ils changent.
///
/// La cadence est passée aux services ([timeClass]) ; la couleur est
/// appliquée ici ([filteredGames]).
abstract class FilteredStatsViewModel extends ChangeNotifier {
  /// Toutes les parties de la période.
  final List<CountryGame> games;
  final TimeClassViewModel _timeClassFilter;
  final PlayerColorViewModel _colorFilter;
  List<CountryGame>? _filteredGames;

  /// Sans filtre (tests) : un filtre propre, sans sélection, non mémorisé.
  FilteredStatsViewModel(this.games, {TimeClassViewModel? timeClassFilter, PlayerColorViewModel? colorFilter})
      : _timeClassFilter = timeClassFilter ?? TimeClassViewModel.temporary(),
        _colorFilter = colorFilter ?? PlayerColorViewModel.temporary() {
    _timeClassFilter.addListener(_onFiltersChanged);
    _colorFilter.addListener(_onFiltersChanged);
  }

  TimeClassViewModel get timeClassFilter => _timeClassFilter;
  PlayerColorViewModel get colorFilter => _colorFilter;

  /// Cadence affichée (null = toutes).
  String? get timeClass => _timeClassFilter.timeClass;

  /// Couleur affichée (null = les deux).
  String? get color => _colorFilter.color;

  /// Parties de la couleur choisie (toutes si aucune), toutes cadences.
  List<CountryGame> get filteredGames {
    final color = this.color;
    return _filteredGames ??=
        color == null ? games : games.where((game) => game.playerColor == color).toList();
  }

  void _onFiltersChanged() {
    _filteredGames = null;
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
    super.dispose();
  }
}
