import 'package:flutter/foundation.dart';

/// Filtre de l'en-tête de la page des stats, commun à toutes les cartes :
/// une valeur parmi [options] (null = pas de filtre).
///
/// Les filtres ne sont pas mémorisés : ils sont créés avec la page des
/// stats (StatsScreen), donc remis à leur valeur par défaut pour chaque
/// joueur consulté.
class ChoiceFilterViewModel extends ChangeNotifier {
  final List<String?> options;
  String? _value;

  ChoiceFilterViewModel(this.options) : _value = null;

  String? get value => _value;

  void select(String? value) {
    if (value == _value) return;
    _value = value;
    notifyListeners();
  }
}

/// Cadence choisie (null = toutes les parties, par défaut).
class TimeClassViewModel extends ChoiceFilterViewModel {
  /// Cadences proposées, dans l'ordre du sélecteur.
  static const List<String?> timeClasses = [null, 'bullet', 'blitz', 'rapid'];

  TimeClassViewModel() : super(timeClasses);

  String? get timeClass => value;
}

/// Famille d'ouvertures choisie (null = toutes, par défaut ; voir
/// OpeningFilterService pour « Autres ouvertures »). Les choix proposés
/// dépendent des parties et des autres filtres (OpeningFilterService.options).
class OpeningFilterViewModel extends ChoiceFilterViewModel {
  OpeningFilterViewModel() : super(const []);

  String? get opening => value;
}

/// Couleur jouée choisie (null = les deux, par défaut).
class PlayerColorViewModel extends ChoiceFilterViewModel {
  static const String white = 'white';
  static const String black = 'black';

  /// Couleurs proposées, dans l'ordre du sélecteur.
  static const List<String?> colors = [null, white, black];

  PlayerColorViewModel() : super(colors);

  String? get color => value;
}

/// Parties prises en compte : classées seulement (par défaut, les parties
/// non classées servant souvent d'entraînement) ou toutes.
class RatedFilterViewModel extends ChangeNotifier {
  bool _ratedOnly = true;

  bool get ratedOnly => _ratedOnly;

  void select(bool ratedOnly) {
    if (ratedOnly == _ratedOnly) return;
    _ratedOnly = ratedOnly;
    notifyListeners();
  }
}
