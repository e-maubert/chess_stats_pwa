import 'package:flutter/foundation.dart';

import '../models/stats_period.dart';
import '../services/period_preference_service.dart';

/// Période des statistiques choisie dans l'en-tête de la page des stats.
class StatsPeriodViewModel extends ChangeNotifier {
  final PeriodPreferenceService _preferences;
  StatsPeriod _period;

  /// [initialPeriod] : choix enregistré, ou « 1 mois » s'il n'y en a pas.
  StatsPeriodViewModel(StatsPeriod initialPeriod, {PeriodPreferenceService? preferences})
      : _period = initialPeriod,
        _preferences = preferences ?? PeriodPreferenceService();

  StatsPeriod get period => _period;

  /// Change de période et mémorise ce choix.
  Future<void> select(StatsPeriod period) async {
    if (period == _period) return;
    _period = period;
    notifyListeners();
    await _preferences.save(period);
  }
}
