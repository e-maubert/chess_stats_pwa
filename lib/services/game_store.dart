import 'package:sembast/sembast.dart';

import '../models/country_game.dart';
import '../models/year_month.dart';

/// Parties d'un joueur pour un mois, telles que stockées.
class StoredMonth {
  final YearMonth month;

  /// Date du téléchargement : décide si le mois est clos
  /// (GameStoragePolicy.isClosed).
  final DateTime fetchedAt;
  final List<CountryGame> games;

  const StoredMonth({required this.month, required this.fetchedAt, required this.games});
}

/// Joueur consulté : pseudo tel qu'affiché et dernière ouverture de ses
/// stats.
class StoredPlayer {
  final String username;
  final DateTime lastViewedAt;

  const StoredPlayer({required this.username, required this.lastViewedAt});

  /// Clé du joueur dans le stockage : pseudo en minuscules.
  String get id => username.toLowerCase();
}

/// Stockage local (IndexedDB dans le navigateur, via sembast) des parties
/// déjà transformées, rangées par (joueur, mois), et des joueurs consultés.
///
/// C'est un cache durable, pas la source de vérité : le navigateur peut
/// l'effacer à tout moment.
class GameStore {
  /// Version de la forme des données. À incrémenter si elle change : les
  /// données d'une ancienne version sont alors effacées à l'ouverture
  /// (même principe que le préfixe `chess_stats_vN_` de l'ancien cache).
  /// 2 : coups (`moves`) et phases (`phases`) des parties.
  static const int schemaVersion = 2;
  static const String defaultName = 'chess_stats_games.db';

  final DatabaseFactory _factory;
  final String name;
  Future<Database>? _database;

  final _months = stringMapStoreFactory.store('months');
  final _players = stringMapStoreFactory.store('players');

  GameStore(this._factory, {this.name = defaultName});

  Future<Database> get _db => _database ??= _factory.openDatabase(
        name,
        version: schemaVersion,
        onVersionChanged: (db, oldVersion, newVersion) async {
          if (oldVersion != 0 && oldVersion != newVersion) {
            await _months.drop(db);
            await _players.drop(db);
          }
        },
      );

  static String _monthKey(String player, YearMonth month) => '${player.toLowerCase()}|${month.key}';

  /// Mois stockés de [player], du plus ancien au plus récent.
  Future<List<StoredMonth>> months(String player) async {
    final records = await _months.find(
      await _db,
      finder: Finder(filter: Filter.equals('player', player.toLowerCase()), sortOrders: [SortOrder('month')]),
    );
    return [for (final record in records) _decodeMonth(record.value)];
  }

  Future<void> saveMonth(String player, StoredMonth month) async {
    await _months.record(_monthKey(player, month.month)).put(await _db, {
      'player': player.toLowerCase(),
      'month': month.month.key,
      'fetchedAt': month.fetchedAt.millisecondsSinceEpoch,
      'games': [for (final game in month.games) game.toJson()],
    });
  }

  Future<StoredPlayer?> player(String player) async {
    final value = await _players.record(player.toLowerCase()).get(await _db);
    return value == null ? null : _decodePlayer(value);
  }

  /// Joueurs consultés, du plus récent au plus ancien.
  Future<List<StoredPlayer>> players() async {
    final records = await _players.find(
      await _db,
      finder: Finder(sortOrders: [SortOrder('lastViewedAt', false)]),
    );
    return [for (final record in records) _decodePlayer(record.value)];
  }

  Future<void> savePlayer(StoredPlayer player) async {
    await _players.record(player.id).put(await _db, {
      'username': player.username,
      'lastViewedAt': player.lastViewedAt.millisecondsSinceEpoch,
    });
  }

  /// Supprime le joueur et toutes ses parties stockées.
  Future<void> deletePlayer(String player) async {
    final db = await _db;
    await db.transaction((txn) async {
      await _players.record(player.toLowerCase()).delete(txn);
      await _months.delete(txn, finder: Finder(filter: Filter.equals('player', player.toLowerCase())));
    });
  }

  /// Supprime, pour tous les joueurs, les mois antérieurs à [oldest] ; et
  /// les mois des joueurs absents de [keptPlayers] (pseudos en minuscules).
  Future<void> deleteMonths({required YearMonth oldest, required Set<String> keptPlayers}) async {
    final db = await _db;
    await _months.delete(
      db,
      finder: Finder(
        filter: Filter.or([
          Filter.lessThan('month', oldest.key),
          Filter.custom((record) => !keptPlayers.contains(record['player'])),
        ]),
      ),
    );
  }

  /// Ferme la base (tests).
  Future<void> close() async {
    final database = _database;
    _database = null;
    if (database != null) await (await database).close();
  }

  static StoredMonth _decodeMonth(Map<String, Object?> value) => StoredMonth(
        month: YearMonth.parse(value['month'] as String),
        fetchedAt: DateTime.fromMillisecondsSinceEpoch(value['fetchedAt'] as int, isUtc: true),
        games: [
          for (final game in value['games'] as List)
            CountryGame.fromJson(Map<String, dynamic>.from(game as Map)),
        ],
      );

  static StoredPlayer _decodePlayer(Map<String, Object?> value) => StoredPlayer(
        username: value['username'] as String,
        lastViewedAt: DateTime.fromMillisecondsSinceEpoch(value['lastViewedAt'] as int, isUtc: true),
      );
}
