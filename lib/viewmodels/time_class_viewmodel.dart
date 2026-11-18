import 'package:flutter/foundation.dart';

import '../services/time_class_preference_service.dart';

/// Cadence choisie dans l'en-tête de la page des stats, commune à toutes les
/// cartes (null = toutes les parties).
class TimeClassViewModel extends ChangeNotifier {
  /// Cadences proposées, dans l'ordre du sélecteur.
  static const List<String?> timeClasses = [null, 'bullet', 'blitz', 'rapid'];

  final TimeClassPreferenceService? _preferences;
  String? _timeClass;

  /// [initialTimeClass] : choix enregistré, ou « Toutes » s'il n'y en a pas.
  TimeClassViewModel([String? initialTimeClass, TimeClassPreferenceService? preferences])
      : _timeClass = initialTimeClass,
        _preferences = preferences ?? const TimeClassPreferenceService(allowed: timeClasses);

  /// Filtre non mémorisé (viewmodel de carte créé seul, ex. dans un test).
  TimeClassViewModel.temporary() : _preferences = null;

  String? get timeClass => _timeClass;

  /// Change de cadence et mémorise ce choix.
  Future<void> select(String? timeClass) async {
    if (timeClass == _timeClass) return;
    _timeClass = timeClass;
    notifyListeners();
    await _preferences?.save(timeClass);
  }
}

/// Base des viewmodels de cartes filtrées par la cadence commune : suit
/// [TimeClassViewModel] et se met à jour quand elle change.
abstract class TimeClassFilteredViewModel extends ChangeNotifier {
  final TimeClassViewModel _filter;

  /// Sans [filter] (tests) : un filtre propre, sur « Toutes », non mémorisé.
  TimeClassFilteredViewModel([TimeClassViewModel? filter]) : _filter = filter ?? TimeClassViewModel.temporary() {
    _filter.addListener(_onTimeClassChanged);
  }

  /// Filtre de cadence suivi.
  TimeClassViewModel get timeClassFilter => _filter;

  /// Cadence affichée (null = toutes).
  String? get timeClass => _filter.timeClass;

  void _onTimeClassChanged() {
    onTimeClassChanged();
    notifyListeners();
  }

  /// À surcharger : remise à zéro (pages, cache) quand la cadence change.
  @protected
  void onTimeClassChanged() {}

  @override
  void dispose() {
    _filter.removeListener(_onTimeClassChanged);
    super.dispose();
  }
}
