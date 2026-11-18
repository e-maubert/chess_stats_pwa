import 'package:flutter/foundation.dart';

import '../services/filter_preference_service.dart';

/// Filtre de l'en-tête de la page des stats, commun à toutes les cartes :
/// une valeur parmi [options] (null = pas de filtre), mémorisée.
class ChoiceFilterViewModel extends ChangeNotifier {
  final List<String?> options;
  final FilterPreferenceService? _preferences;
  String? _value;

  /// Sans [preferences] : choix non mémorisé (ex. dans un test).
  ChoiceFilterViewModel(this.options, String? initialValue, this._preferences) : _value = initialValue;

  String? get value => _value;

  /// Change de valeur et mémorise ce choix.
  Future<void> select(String? value) async {
    if (value == _value) return;
    _value = value;
    notifyListeners();
    await _preferences?.save(value);
  }
}

/// Cadence choisie (null = toutes les parties).
class TimeClassViewModel extends ChoiceFilterViewModel {
  /// Cadences proposées, dans l'ordre du sélecteur.
  static const List<String?> timeClasses = [null, 'bullet', 'blitz', 'rapid'];

  static const FilterPreferenceService preferences = FilterPreferenceService('stats_time_class', timeClasses);

  /// [initialTimeClass] : choix enregistré, ou « Toutes » s'il n'y en a pas.
  TimeClassViewModel([String? initialTimeClass, FilterPreferenceService? prefs])
      : super(timeClasses, initialTimeClass, prefs ?? preferences);

  /// Filtre non mémorisé (viewmodel de carte créé seul, ex. dans un test).
  TimeClassViewModel.temporary() : super(timeClasses, null, null);

  String? get timeClass => value;
}

/// Famille d'ouvertures choisie (null = toutes ; voir OpeningFilterService
/// pour « Autres ouvertures »). Propre au joueur consulté : ni mémorisée,
/// ni partagée entre joueurs. Les choix proposés dépendent des parties et
/// des autres filtres (OpeningFilterService.options).
class OpeningFilterViewModel extends ChoiceFilterViewModel {
  OpeningFilterViewModel() : super(const [], null, null);

  String? get opening => value;
}

/// Couleur jouée choisie (null = les deux).
class PlayerColorViewModel extends ChoiceFilterViewModel {
  static const String white = 'white';
  static const String black = 'black';

  /// Couleurs proposées, dans l'ordre du sélecteur.
  static const List<String?> colors = [null, white, black];

  static const FilterPreferenceService preferences = FilterPreferenceService('stats_player_color', colors);

  /// [initialColor] : choix enregistré, ou « Les deux » s'il n'y en a pas.
  PlayerColorViewModel([String? initialColor, FilterPreferenceService? prefs])
      : super(colors, initialColor, prefs ?? preferences);

  /// Filtre non mémorisé (viewmodel de carte créé seul, ex. dans un test).
  PlayerColorViewModel.temporary() : super(colors, null, null);

  String? get color => value;
}
