import 'package:flutter/foundation.dart';

import '../models/country_game.dart';
import '../services/game_repository.dart';
import '../services/scouting_service.dart';

/// Page « Comment battre ce joueur » : affiche tout de suite le rapport sur
/// les parties reçues, puis les met à jour en arrière-plan si elles
/// viennent du stockage local (comme le bilan du mois).
class ScoutingViewModel extends ChangeNotifier {
  final GameRepository _repository;
  final String username;

  List<CountryGame> _games;
  bool _upToDate;
  bool _disposed = false;

  ScoutingViewModel(this._repository, this.username, {required List<CountryGame> games, bool upToDate = false})
      : _games = games,
        _upToDate = upToDate {
    _repository.markViewed(username);
    if (!upToDate) _update();
  }

  List<CountryGame> get games => _games;

  bool get upToDate => _upToDate;

  ScoutingReport? _report;
  List<CountryGame>? _reportSource;

  /// Rapport sur les parties actuelles ; null sans partie exploitable.
  ScoutingReport? get report {
    if (!identical(_reportSource, _games)) {
      _reportSource = _games;
      _report = ScoutingService.build(_games, _repository.now);
    }
    return _report;
  }

  Future<void> _update() async {
    try {
      _games = await _repository.updateGames(username);
      _upToDate = true;
      if (!_disposed) notifyListeners();
    } catch (error) {
      debugPrint('Mise à jour des parties impossible : $error');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
