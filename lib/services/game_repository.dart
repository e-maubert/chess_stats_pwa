import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/country_game.dart';
import '../models/game_phase_summary.dart';
import '../models/year_month.dart';
import 'chess_api_service.dart';
import 'game_database_factory.dart';
import 'game_storage_policy.dart';
import 'game_store.dart';
import 'monthly_games_source.dart';

/// Point d'accès unique aux parties d'un joueur : « parties du joueur X
/// pour le mois M ». Relit le stockage local et ne télécharge (via
/// [MonthlyGamesSource]) que les mois manquants ou pas encore clos.
///
/// Le stockage n'est qu'un cache : s'il est vide, effacé par le navigateur
/// ou inaccessible, tout est téléchargé de nouveau, sans erreur.
class GameRepository {
  final GameStore _store;
  final MonthlyGamesSource _source;
  final DateTime Function() _now;

  GameRepository({required GameStore store, required MonthlyGamesSource source, DateTime Function()? now})
      : _store = store,
        _source = source,
        _now = now ?? DateTime.now;

  /// Stockage IndexedDB du navigateur et API chess.com.
  factory GameRepository.local() => GameRepository(store: GameStore(gameDatabaseFactory), source: ChessApiService());

  DateTime get now => _now();

  /// Parties de [player] pour le mois [month], téléchargées si besoin.
  Future<List<CountryGame>> gamesForMonth(String player, YearMonth month) async =>
      (await _ensureMonths(player, [month]))[month]!;

  /// Parties stockées de [player] sur les mois de la plus longue période,
  /// sans appel réseau ; null si aucune n'est stockée.
  Future<List<CountryGame>?> storedGames(String player) async {
    final needed = GameStoragePolicy.monthsNeeded(_now()).toSet();
    final months = (await _safe(() => _store.months(player), <StoredMonth>[]))
        .where((stored) => needed.contains(stored.month))
        .toList();
    if (months.isEmpty) return null;
    return GameStoragePolicy.merge(const [], [for (final stored in months) ...stored.games]);
  }

  /// Met à jour [player] : télécharge les mois de la plus longue période
  /// absents du stockage ou pas encore clos, et renvoie toutes ses parties
  /// sur ces mois.
  Future<List<CountryGame>> updateGames(String player) async {
    final months = await _ensureMonths(player, GameStoragePolicy.monthsNeeded(_now()));
    return GameStoragePolicy.merge(const [], [for (final games in months.values) ...games]);
  }

  /// Note l'ouverture des stats de [username] (seule action qui compte
  /// comme une consultation pour la purge).
  Future<void> markViewed(String username) =>
      _safe(() => _store.savePlayer(StoredPlayer(username: username, lastViewedAt: _now().toUtc())), null);

  /// Enregistre les phases calculées des parties de [player] (identité de
  /// la partie → résumé) : chaque partie concernée les garde et perd ses
  /// coups, devenus inutiles. Les mois sans changement ne sont pas réécrits.
  Future<void> savePhases(String player, Map<String, GamePhaseSummary?> phases) => _safe(() async {
        if (phases.isEmpty) return;
        for (final stored in await _store.months(player)) {
          var changed = false;
          final games = [
            for (final game in stored.games)
              if (game.phases == null && phases[GameStoragePolicy.identity(game)] != null)
                (() {
                  changed = true;
                  return game.withPhases(phases[GameStoragePolicy.identity(game)]!);
                })()
              else
                game,
          ];
          if (changed) {
            await _store.saveMonth(player, StoredMonth(month: stored.month, fetchedAt: stored.fetchedAt, games: games));
          }
        }
      }, null);

  /// Joueurs consultés encore présents dans le stockage, du plus récent au
  /// plus ancien (sans ceux que la purge supprimera).
  Future<List<StoredPlayer>> viewedPlayers() => _safe(() async {
        final now = _now();
        return [
          for (final player in await _store.players())
            if (!GameStoragePolicy.isPlayerExpired(player.lastViewedAt, now)) player,
        ];
      }, const <StoredPlayer>[]);

  /// Retire [username] des joueurs consultés et supprime ses parties
  /// stockées.
  Future<void> removePlayer(String username) => _safe(() => _store.deletePlayer(username), null);

  /// Nettoyage au lancement : supprime les joueurs non consultés depuis
  /// plus d'un mois, et les mois au-delà de la durée de conservation.
  Future<void> purge() => _safe(() async {
        final now = _now();
        final kept = <String>{};
        for (final player in await _store.players()) {
          if (GameStoragePolicy.isPlayerExpired(player.lastViewedAt, now)) {
            await _store.deletePlayer(player.id);
          } else {
            kept.add(player.id);
          }
        }
        await _store.deleteMonths(oldest: GameStoragePolicy.oldestRetainedMonth(now), keptPlayers: kept);
      }, null);

  /// Supprime l'ancien cache (stats du mois dans SharedPreferences,
  /// clés `chess_stats_vN_…`), remplacé par ce stockage.
  static Future<void> removeLegacyCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final key in prefs.getKeys().where((key) => key.startsWith('chess_stats_v')).toList()) {
        await prefs.remove(key);
      }
    } catch (error) {
      debugPrint('Ancien cache non supprimé : $error');
    }
  }

  Future<Map<YearMonth, List<CountryGame>>> _ensureMonths(String player, List<YearMonth> wanted) async {
    final now = _now();
    final stored = {
      for (final month in await _safe(() => _store.months(player), <StoredMonth>[])) month.month: month,
    };
    final missing = [
      for (final month in wanted)
        if (stored[month] == null || !GameStoragePolicy.isClosed(month, stored[month]!.fetchedAt)) month,
    ];
    final fetched = missing.isEmpty
        ? const <YearMonth, List<CountryGame>>{}
        : await _source.fetchMonths(player, missing);

    final result = <YearMonth, List<CountryGame>>{};
    for (final month in wanted) {
      final fresh = fetched[month];
      if (fresh == null) {
        result[month] = stored[month]!.games;
        continue;
      }
      final games = GameStoragePolicy.merge(stored[month]?.games ?? const [], fresh);
      result[month] = games;
      await _safe(
        () => _store.saveMonth(player, StoredMonth(month: month, fetchedAt: now.toUtc(), games: games)),
        null,
      );
    }
    return result;
  }

  /// Exécute un accès au stockage ; en cas d'erreur (IndexedDB indisponible,
  /// navigation privée…), renvoie [fallback] au lieu d'échouer.
  Future<T> _safe<T>(Future<T> Function() action, T fallback) async {
    try {
      return await action();
    } catch (error) {
      debugPrint('Stockage local indisponible : $error');
      return fallback;
    }
  }
}
