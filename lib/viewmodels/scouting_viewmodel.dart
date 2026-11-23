import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/country_game.dart';
import '../models/game_phase_summary.dart';
import '../services/game_phase_service.dart';
import '../services/game_repository.dart';
import '../services/game_storage_policy.dart';
import '../services/scouting_service.dart';

/// Page « Comment battre ce joueur » : affiche tout de suite le rapport sur
/// les parties reçues, puis les met à jour en arrière-plan si elles
/// viennent du stockage local (comme le bilan du mois). Les phases des
/// parties analysées (diapos phase et gestion du temps) sont calculées
/// ensuite, par tranches, et enregistrées.
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

  /// Phases calculées (identité de la partie → résumé ; null si ses coups
  /// sont illisibles).
  final Map<String, GamePhaseSummary?> _phases = {};
  bool _analyzing = false;

  /// Avancement du calcul des phases, de 0 à 1.
  final ValueNotifier<double> phaseProgress = ValueNotifier(0);

  /// Parties analysées avec leurs phases ; null pendant le calcul (lancé au
  /// premier appel).
  List<CountryGame>? get analyzedWithPhases {
    final report = this.report;
    if (report == null) return null;
    final games = GamePhaseService.withPhases(report.analyzed, _phases);
    if (games == null) scheduleMicrotask(_analyzePhases);
    return games;
  }

  /// Phase de fin de partie et gestion du temps ; null pendant le calcul
  /// des phases ou s'il y a trop peu de parties.
  PhaseInsight? get phaseInsight {
    final games = analyzedWithPhases;
    return games == null ? null : ScoutingService.phases(games);
  }

  TimeInsight? get timeInsight {
    final games = analyzedWithPhases;
    return games == null ? null : ScoutingService.time(games);
  }

  bool get phasesReady => analyzedWithPhases != null;

  /// Rejoue les parties analysées par tranches de 12 ms (l'affichage reste
  /// fluide), puis enregistre les phases trouvées.
  Future<void> _analyzePhases() async {
    if (_analyzing || _disposed) return;
    _analyzing = true;
    try {
      while (!_disposed) {
        final report = this.report;
        if (report == null) break;
        final pending = GamePhaseService.pending(report.analyzed, _phases);
        if (pending.isEmpty) break;
        final found = <String, GamePhaseSummary?>{};
        final watch = Stopwatch()..start();
        for (final (index, game) in pending.indexed) {
          GamePhaseSummary? summary;
          try {
            summary = GamePhaseService.summarize(game);
          } catch (error) {
            debugPrint('Phases non calculées pour ${game.url} : $error');
          }
          found[GameStoragePolicy.identity(game)] = summary;
          if (watch.elapsed >= const Duration(milliseconds: 12)) {
            phaseProgress.value = (index + 1) / pending.length;
            await Future<void>.delayed(Duration.zero);
            if (_disposed) return;
            watch.reset();
          }
        }
        _phases.addAll(found);
        phaseProgress.value = 1;
        if (!_disposed) notifyListeners();
        await _repository.savePhases(username, found);
      }
    } finally {
      _analyzing = false;
    }
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
    phaseProgress.dispose();
    super.dispose();
  }
}
