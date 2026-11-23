import 'package:flutter/foundation.dart';

import '../models/stats_period.dart';

/// Période des statistiques choisie dans l'en-tête de la page des stats.
/// Non mémorisée : « 1 mois » pour chaque joueur consulté (voir
/// ChoiceFilterViewModel).
class StatsPeriodViewModel extends ChangeNotifier {
  /// Période affichée à l'ouverture de la page d'un joueur.
  static const StatsPeriod defaultPeriod = StatsPeriod.oneMonth;

  StatsPeriod _period = defaultPeriod;

  StatsPeriod get period => _period;

  void select(StatsPeriod period) {
    if (period == _period) return;
    _period = period;
    notifyListeners();
  }

  /// Retour à la période par défaut.
  void reset() => select(defaultPeriod);

  /// Période modifiée par rapport à celle par défaut.
  bool get isActive => _period != defaultPeriod;
}
