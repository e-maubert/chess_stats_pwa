import 'package:sembast/sembast.dart';

import 'position_evaluator.dart';

/// Évaluations de positions gardées dans le stockage local (IndexedDB dans
/// le navigateur), d'une visite à l'autre et pour tous les joueurs
/// consultés : les positions d'ouverture reviennent sans cesse.
///
/// Cache durable, pas source de vérité : le navigateur peut l'effacer, et
/// une erreur de stockage (navigation privée…) revient à ne rien avoir
/// gardé.
class EvalStore {
  /// Version de la forme des données ; à incrémenter si elle change (les
  /// évaluations gardées sont alors effacées).
  static const int schemaVersion = 1;
  static const String defaultName = 'chess_stats_evals.db';

  final DatabaseFactory _factory;
  final String name;
  Future<Database>? _database;

  final _evals = stringMapStoreFactory.store('evals');

  EvalStore(this._factory, {this.name = defaultName});

  Future<Database> get _db => _database ??= _factory.openDatabase(
        name,
        version: schemaVersion,
        onVersionChanged: (db, oldVersion, newVersion) async {
          if (oldVersion != 0 && oldVersion != newVersion) await _evals.drop(db);
        },
      );

  /// Évaluation gardée de la position [fen], null si aucune.
  Future<PositionEval?> get(String fen) async {
    try {
      final record = await _evals.record(fen).get(await _db);
      if (record == null) return null;
      return PositionEval(record['cp'] as int, record['best'] as String?);
    } catch (_) {
      return null;
    }
  }

  /// Garde l'évaluation [eval] de la position [fen].
  Future<void> put(String fen, PositionEval eval) async {
    try {
      await _evals.record(fen).put(await _db, {'cp': eval.cp, 'best': eval.bestUci});
    } catch (_) {
      // Stockage indisponible : l'évaluation sera redemandée.
    }
  }
}
