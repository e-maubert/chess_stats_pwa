import 'package:flutter/foundation.dart';

import '../models/country_game.dart';
import '../models/stats_period.dart';
import '../services/game_repository.dart';
import '../services/recap_service.dart';
import '../services/stats_period_service.dart';

/// Page du bilan, entre la recherche et les stats : affiche tout de suite
/// les parties reçues de la recherche, puis les met à jour en arrière-plan
/// si elles viennent du stockage local.
class RecapViewModel extends ChangeNotifier {
  /// Période du bilan : le dernier mois (30 jours), la plus parlante.
  static const StatsPeriod period = StatsPeriod.oneMonth;

  final GameRepository _repository;
  final String username;

  List<CountryGame> _games;
  bool _upToDate;
  bool _disposed = false;

  RecapViewModel(this._repository, this.username, {required List<CountryGame> games, bool upToDate = false})
      : _games = games,
        _upToDate = upToDate {
    _repository.markViewed(username);
    if (!upToDate) _update();
  }

  /// Toutes les parties du joueur (transmises ensuite à la page des stats).
  List<CountryGame> get games => _games;

  /// Les parties ont été téléchargées : la page des stats n'a pas besoin de
  /// les mettre à jour en s'ouvrant.
  bool get upToDate => _upToDate;

  PlayerRecap? _recap;
  List<CountryGame>? _recapSource;

  /// Bilan des parties classées des [period] derniers jours (toutes s'il
  /// n'y en a aucune de classée) ; null sans partie.
  PlayerRecap? get recap {
    if (!identical(_recapSource, _games)) {
      _recapSource = _games;
      _recap = RecapService.build(
        StatsPeriodService.preferRated(StatsPeriodService.filter(_games, period, _repository.now)),
      );
    }
    return _recap;
  }

  Future<void> _update() async {
    try {
      _games = await _repository.updateGames(username);
      _upToDate = true;
      if (!_disposed) notifyListeners();
    } catch (error) {
      // Le bilan reste celui des parties stockées ; la page des stats
      // retentera la mise à jour.
      debugPrint('Mise à jour du bilan impossible : $error');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
