import 'package:flutter/foundation.dart';

import '../models/country_game.dart';
import '../models/stats_period.dart';
import '../services/game_repository.dart';
import '../services/stats_period_service.dart';

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

  /// Parties de la [period] (les N derniers jours), celles affichées. Même
  /// liste tant que les parties et la période ne changent pas : les cartes
  /// gardent leurs filtres (elles repartent de zéro quand la liste change).
  List<CountryGame> gamesIn(StatsPeriod period) {
    if (_displayedSource != _games || _displayedPeriod != period || _displayed == null) {
      _displayedSource = _games;
      _displayedPeriod = period;
      _displayed = StatsPeriodService.filter(_games ?? const [], period, _repository.now);
    }
    return _displayed!;
  }

  List<CountryGame>? _displayedSource;
  StatsPeriod? _displayedPeriod;
  List<CountryGame>? _displayed;

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
