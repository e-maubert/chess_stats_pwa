import 'package:flutter/foundation.dart';

import '../models/country_game.dart';
import '../models/stats_period.dart';
import '../services/opening_improvement_service.dart';
import '../services/position_evaluator.dart';
import '../services/stats_period_service.dart';

/// Résultat pour une couleur : ouverture la plus jouée et coup à corriger
/// (null si aucun : ouverture solide, ou trop peu de parties).
class ColorImprovement {
  final ColorOpening opening;
  final OpeningMistake? mistake;

  const ColorImprovement(this.opening, this.mistake);

  /// Trop peu de parties pour repérer un coup rejoué.
  bool get notEnoughGames => opening.games.length < OpeningImprovementService.minRepeats;
}

/// Carte « Améliorer son ouverture » : analyse, sur la période la plus
/// longue et les parties classées de la cadence la plus jouée, de
/// l'ouverture la plus jouée avec chaque couleur. Les filtres de la page ne
/// s'appliquent pas (encore).
class OpeningImprovementViewModel extends ChangeNotifier {
  final PositionEvaluator _evaluator;

  OpeningImprovementViewModel(this._evaluator);

  /// Période analysée.
  static const StatsPeriod period = StatsPeriod.threeMonths;

  List<CountryGame>? _source;
  int _run = 0;
  bool _disposed = false;

  bool _loading = false;
  bool _failed = false;
  String? _timeClass;
  ColorImprovement? _white;
  ColorImprovement? _black;

  /// Avancement de l'analyse (0 à 1).
  final ValueNotifier<double> progress = ValueNotifier(0);

  /// Analyse en cours, ou pas encore lancée.
  bool get loading => _loading || _source == null;

  /// Analyse interrompue (service d'évaluation indisponible).
  bool get failed => _failed;

  /// Cadence analysée ; null sans partie classée sur la période.
  String? get timeClass => _timeClass;
  ColorImprovement? get white => _white;
  ColorImprovement? get black => _black;

  /// Lance l'analyse de [games] (toutes les parties chargées du joueur), sauf
  /// si ce sont déjà celles analysées.
  void analyze(List<CountryGame> games, DateTime now) {
    if (identical(games, _source) && !_failed) return;
    _source = games;
    _start(games, now);
  }

  /// Relance après un échec.
  void retry(DateTime now) {
    final games = _source;
    if (games != null) _start(games, now);
  }

  Future<void> _start(List<CountryGame> games, DateTime now) async {
    final run = ++_run;
    final inPeriod = StatsPeriodService.filter(games, period, now, ratedOnly: true);
    _timeClass = OpeningImprovementService.mainTimeClass(inPeriod);
    _white = _black = null;
    _failed = false;
    _loading = _timeClass != null;
    progress.value = 0;
    _notify();
    if (_timeClass == null) return;

    final inClass = [
      for (final g in inPeriod)
        if (g.timeClass == _timeClass) g
    ];
    final openings = [
      OpeningImprovementService.mainOpening(inClass, white: true),
      OpeningImprovementService.mainOpening(inClass, white: false),
    ];
    final candidates = [
      for (final o in openings)
        o == null ? const <OpeningCandidate>[] : OpeningImprovementService.candidates(o.games, white: o.white),
    ];
    final total = candidates[0].length + candidates[1].length;
    try {
      final results = <ColorImprovement?>[];
      var done = 0;
      for (final (index, opening) in openings.indexed) {
        if (opening == null) {
          results.add(null);
          continue;
        }
        final mistake = await OpeningImprovementService.findMistake(
          candidates[index],
          white: opening.white,
          evaluator: _evaluator,
          onProgress: (value) {
            if (run == _run && !_disposed && total > 0)
              progress.value = (done + value * candidates[index].length) / total;
          },
        );
        done += candidates[index].length;
        results.add(ColorImprovement(opening, mistake));
      }
      if (run != _run) return;
      _white = results[0];
      _black = results[1];
    } on Object {
      if (run != _run) return;
      _failed = true;
    }
    _loading = false;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    progress.dispose();
    super.dispose();
  }
}
