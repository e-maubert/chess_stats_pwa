import 'package:flutter/foundation.dart';

import '../models/country_game.dart';
import '../models/year_month.dart';
import '../services/game_repository.dart';

/// Parties du joueur affiché : celles du stockage local d'abord (affichage
/// immédiat), puis mises à jour en arrière-plan.
class PlayerGamesViewModel extends ChangeNotifier {
  final GameRepository _repository;
  final String username;

  List<CountryGame>? _games;
  bool _updating = false;
  bool _updateFailed = false;
  bool _disposed = false;

  /// [initialGames] : parties déjà chargées par l'écran de recherche ;
  /// [upToDate] : elles viennent d'être téléchargées, inutile de les mettre
  /// à jour tout de suite.
  PlayerGamesViewModel(this._repository, this.username, {List<CountryGame>? initialGames, bool upToDate = false})
      : _games = initialGames {
    _open(upToDate);
  }

  /// null tant que rien n'est chargé.
  List<CountryGame>? get games => _games;
  bool get isUpdating => _updating;

  /// La dernière mise à jour a échoué (les parties affichées, s'il y en a,
  /// sont celles du stockage).
  bool get updateFailed => _updateFailed;

  /// Parties du mois calendaire en cours (UTC), celles affichées.
  List<CountryGame> get displayedGames {
    final month = YearMonth.of(_repository.now);
    return [
      for (final game in _games ?? const <CountryGame>[])
        if (game.endTime != null && YearMonth.of(game.endTime!) == month) game,
    ];
  }

  Future<void> _open(bool upToDate) async {
    await _repository.markViewed(username);
    if (_games == null) {
      _games = await _repository.storedGames(username);
      _notify();
    }
    if (!upToDate) await update();
  }

  /// Télécharge les mois pas encore clos et met l'affichage à jour.
  Future<void> update() async {
    _updating = true;
    _updateFailed = false;
    _notify();
    try {
      _games = await _repository.updateGames(username);
    } catch (error) {
      debugPrint('Mise à jour impossible : $error');
      _updateFailed = true;
    } finally {
      _updating = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
