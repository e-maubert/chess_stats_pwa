import 'dart:convert';

import 'package:http/http.dart' as http;

/// Évaluation d'une position par un moteur.
class PositionEval {
  /// Avantage en centipions du point de vue des blancs (mat = ±[mateCp]).
  final int cp;

  /// Meilleur coup en notation UCI (ex. `e2e4`, roque noté `e1h1` ou
  /// `e1g1`), null si inconnu.
  final String? bestUci;

  const PositionEval(this.cp, this.bestUci);

  /// Valeur donnée à un mat, et plafond des évaluations.
  static const int mateCp = 1000;
}

/// Trop de demandes envoyées au service d'évaluation : réessayer plus tard.
class EvaluationRateLimited implements Exception {
  const EvaluationRateLimited();
}

/// Source d'évaluations de positions (remplaçable dans les tests).
abstract class PositionEvaluator {
  /// Évaluation de la position [fen] ; null si elle est inconnue. Lève
  /// [EvaluationRateLimited] si le service demande d'attendre.
  Future<PositionEval?> evaluate(String fen);
}

/// Évaluations déjà calculées par Lichess (base « cloud », gratuite, sans
/// compte), une demande à la fois comme le demande leur API. Les réponses
/// sont gardées pour la session.
class CloudEvalService implements PositionEvaluator {
  final http.Client _client;
  final Map<String, PositionEval?> _cache = {};
  Future<void> _queue = Future.value();

  CloudEvalService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<PositionEval?> evaluate(String fen) {
    if (_cache.containsKey(fen)) return Future.value(_cache[fen]);
    // File d'attente : une seule demande en cours.
    final result = _queue.then((_) => _fetch(fen));
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }

  Future<PositionEval?> _fetch(String fen) async {
    if (_cache.containsKey(fen)) return _cache[fen];
    final response = await _client.get(Uri.https('lichess.org', '/api/cloud-eval', {'fen': fen}));
    if (response.statusCode == 429) throw const EvaluationRateLimited();
    final eval = response.statusCode == 200 ? parse(response.body) : null;
    _cache[fen] = eval;
    return eval;
  }

  /// Réponse de `/api/cloud-eval` → évaluation de la première variante.
  static PositionEval? parse(String body) {
    final pvs = json.decode(body)['pvs'] as List<dynamic>?;
    if (pvs == null || pvs.isEmpty) return null;
    final pv = pvs.first as Map<String, dynamic>;
    final mate = pv['mate'] as int?;
    final cp = mate != null
        ? (mate > 0 ? PositionEval.mateCp : -PositionEval.mateCp)
        : ((pv['cp'] as num?)?.toInt() ?? 0).clamp(-PositionEval.mateCp, PositionEval.mateCp);
    final moves = (pv['moves'] as String?)?.split(' ');
    return PositionEval(cp, moves == null || moves.first.isEmpty ? null : moves.first);
  }
}
