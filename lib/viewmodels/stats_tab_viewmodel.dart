import 'package:flutter/foundation.dart';

/// Onglets de la page d'un joueur.
enum StatsTab { stats, improvement }

/// Onglet affiché (stats ou axes d'amélioration), non mémorisé.
class StatsTabViewModel extends ChangeNotifier {
  StatsTab _tab = StatsTab.stats;

  StatsTab get tab => _tab;

  void select(StatsTab tab) {
    if (tab == _tab) return;
    _tab = tab;
    notifyListeners();
  }
}
