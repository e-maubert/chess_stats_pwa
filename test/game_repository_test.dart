import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/models/year_month.dart';
import 'package:chess_stats_pwa/services/game_repository.dart';
import 'package:chess_stats_pwa/services/game_storage_policy.dart';
import 'package:chess_stats_pwa/services/game_store.dart';
import 'package:chess_stats_pwa/services/monthly_games_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

CountryGame _game(String url, DateTime end) => CountryGame(
      country: 'FR',
      opponent: 'bob',
      timeClass: 'blitz',
      result: 'win',
      playerColor: 'white',
      opening: 'Sicilian-Defense',
      endTime: end,
      url: url,
    );

/// Source factice : une partie par mois (le 15), plus les parties ajoutées
/// dans [extra] ; note chaque mois demandé.
class _FakeSource implements MonthlyGamesSource {
  final requests = <String>[];
  final extra = <YearMonth, List<CountryGame>>{};

  @override
  Future<Map<YearMonth, List<CountryGame>>> fetchMonths(String username, List<YearMonth> months) async {
    return {
      for (final month in months)
        month: [
          _game('https://chess.com/$username/${month.key}', DateTime.utc(month.year, month.month, 15)),
          ...?extra[month],
        ],
    }..keys.forEach((month) => requests.add('$username ${month.key}'));
  }
}

class _BrokenStore extends GameStore {
  _BrokenStore() : super(newDatabaseFactoryMemory());

  @override
  Future<List<StoredMonth>> months(String player) => throw StateError('IndexedDB indisponible');

  @override
  Future<void> saveMonth(String player, StoredMonth month) => throw StateError('IndexedDB indisponible');
}

void main() {
  group('GameStoragePolicy', () {
    test('mois couvrant les 90 et 30 derniers jours', () {
      expect(GameStoragePolicy.monthsCovering(DateTime.utc(2026, 11, 16), 90).map((m) => m.key),
          ['2026-08', '2026-09', '2026-10', '2026-11']);
      expect(GameStoragePolicy.monthsCovering(DateTime.utc(2026, 11, 1), 30).map((m) => m.key),
          ['2026-10', '2026-11']);
      // Jamais plus de 4 archives téléchargées pour 90 jours, même le 1er mai
      // (90 jours remontent alors au 31 janvier).
      for (var day = 0; day < 365; day++) {
        final now = DateTime.utc(2026, 1, 1).add(Duration(days: day));
        expect(GameStoragePolicy.monthsNeeded(now).length, lessThanOrEqualTo(4));
        expect(GameStoragePolicy.monthsNeeded(now).last, YearMonth.of(now));
      }
      expect(GameStoragePolicy.monthsNeeded(DateTime.utc(2026, 5, 1)).map((m) => m.key),
          ['2026-02', '2026-03', '2026-04', '2026-05']);
    });

    test('durée de conservation calculée depuis la plus longue période', () {
      expect(GameStoragePolicy.retainedMonthCount(), 4);
      expect(GameStoragePolicy.retainedMonthCount(180), 7);
      expect(GameStoragePolicy.oldestRetainedMonth(DateTime.utc(2026, 11, 16)), const YearMonth(2026, 8));
    });

    test('un mois est clos s\'il a été téléchargé après sa fin (UTC) + marge', () {
      const november = YearMonth(2026, 11);
      expect(GameStoragePolicy.isClosed(november, DateTime.utc(2026, 11, 30, 23)), isFalse);
      expect(GameStoragePolicy.isClosed(november, DateTime.utc(2026, 12, 1, 1)), isFalse);
      expect(GameStoragePolicy.isClosed(november, DateTime.utc(2026, 12, 1, 2)), isTrue);
    });

    test('fusion sans doublon, par URL', () {
      final a = _game('a', DateTime.utc(2026, 11, 1));
      final b = _game('b', DateTime.utc(2026, 11, 2));
      final merged = GameStoragePolicy.merge([a, b], [b, _game('c', DateTime.utc(2026, 11, 3))]);
      expect(merged.map((g) => g.url), ['a', 'b', 'c']);
    });
  });

  group('GameRepository', () {
    late DateTime now;
    late _FakeSource source;
    late GameStore store;
    late GameRepository repository;

    setUp(() {
      now = DateTime.utc(2026, 11, 16, 12);
      source = _FakeSource();
      store = GameStore(newDatabaseFactoryMemory());
      repository = GameRepository(store: store, source: source, now: () => now);
    });

    test('premier chargement : les 4 mois des 90 derniers jours, puis seulement le mois en cours', () async {
      expect(await repository.storedGames('Alice'), isNull);

      final games = await repository.updateGames('Alice');
      expect(source.requests, ['Alice 2026-08', 'Alice 2026-09', 'Alice 2026-10', 'Alice 2026-11']);
      expect(games, hasLength(4));

      source.requests.clear();
      expect(await repository.storedGames('alice'), hasLength(4));
      await repository.updateGames('alice');
      expect(source.requests, ['alice 2026-11']);
    });

    test('un mois téléchargé avant sa fin est téléchargé de nouveau une fois terminé, puis plus', () async {
      await repository.updateGames('alice');
      source.requests.clear();

      // 1er décembre, 3 h UTC : novembre est terminé mais a été téléchargé
      // avant sa fin => téléchargé une dernière fois, avec décembre.
      now = DateTime.utc(2026, 12, 1, 3);
      await repository.updateGames('alice');
      expect(source.requests, ['alice 2026-11', 'alice 2026-12']);

      source.requests.clear();
      now = DateTime.utc(2026, 12, 2);
      await repository.updateGames('alice');
      expect(source.requests, ['alice 2026-12']);
    });

    test('aucune partie en double après une mise à jour du mois en cours', () async {
      await repository.updateGames('alice');
      const november = YearMonth(2026, 11);
      source.extra[november] = [_game('nouvelle', DateTime.utc(2026, 11, 16))];
      final games = await repository.updateGames('alice');
      expect(games.map((g) => g.url).toSet().length, games.length);
      expect(games, hasLength(5));
      expect(await repository.gamesForMonth('alice', november), hasLength(2));
    });

    test('plusieurs joueurs stockés sans s\'écraser', () async {
      await repository.updateGames('alice');
      await repository.updateGames('bob');
      final alice = await repository.storedGames('alice');
      final bob = await repository.storedGames('bob');
      expect(alice!.every((g) => g.url!.contains('/alice/')), isTrue);
      expect(bob!.every((g) => g.url!.contains('/bob/')), isTrue);
    });

    test('purge : mois au-delà de la conservation supprimés', () async {
      await repository.markViewed('alice');
      await repository.updateGames('alice');
      // Deux mois plus tard : août et septembre sortent des 4 mois gardés.
      now = DateTime.utc(2027, 1, 10);
      await repository.markViewed('alice');
      await repository.purge();
      expect((await store.months('alice')).map((m) => m.month.key), ['2026-10', '2026-11']);
    });

    test('purge : joueur non consulté depuis plus d\'un mois entièrement supprimé', () async {
      await repository.markViewed('alice');
      await repository.updateGames('alice');
      now = DateTime.utc(2026, 12, 10);
      await repository.markViewed('bob');
      await repository.updateGames('bob');

      // Alice : vue il y a 31 jours ; Bob : il y a 7 jours.
      now = DateTime.utc(2026, 12, 17, 13);
      await repository.purge();
      expect(await store.player('alice'), isNull);
      expect(await store.months('alice'), isEmpty);
      expect(await store.player('bob'), isNotNull);
      expect(await store.months('bob'), isNotEmpty);
    });

    test('purge : parties d\'un joueur jamais ouvert supprimées', () async {
      await repository.updateGames('alice');
      await repository.purge();
      expect(await store.months('alice'), isEmpty);
    });

    test('stockage effacé : tout est téléchargé de nouveau', () async {
      await repository.updateGames('alice');
      final emptied = GameRepository(store: GameStore(newDatabaseFactoryMemory()), source: source, now: () => now);
      source.requests.clear();
      expect(await emptied.storedGames('alice'), isNull);
      expect(await emptied.updateGames('alice'), hasLength(4));
      expect(source.requests, hasLength(4));
    });

    test('stockage indisponible : parties téléchargées sans erreur', () async {
      final broken = GameRepository(store: _BrokenStore(), source: source, now: () => now);
      expect(await broken.storedGames('alice'), isNull);
      expect(await broken.updateGames('alice'), hasLength(4));
      await broken.purge();
    });
  });
}
