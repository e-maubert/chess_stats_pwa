import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/models/stats_period.dart';
import 'package:chess_stats_pwa/models/year_month.dart';
import 'package:chess_stats_pwa/services/game_repository.dart';
import 'package:chess_stats_pwa/services/game_store.dart';
import 'package:chess_stats_pwa/services/monthly_games_source.dart';
import 'package:chess_stats_pwa/services/stats_period_service.dart';
import 'package:chess_stats_pwa/viewmodels/player_games_viewmodel.dart';
import 'package:chess_stats_pwa/viewmodels/stats_period_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:shared_preferences/shared_preferences.dart';

CountryGame _game(DateTime? end, {bool rated = true}) => CountryGame(
      country: 'FR',
      opponent: 'bob',
      timeClass: 'blitz',
      result: 'win',
      playerColor: 'white',
      opening: 'Sicilian-Defense',
      endTime: end,
      rated: rated,
      url: 'https://chess.com/game/${end?.millisecondsSinceEpoch}',
    );

class _NoSource implements MonthlyGamesSource {
  @override
  Future<Map<YearMonth, List<CountryGame>>> fetchMonths(String username, List<YearMonth> months) async =>
      {for (final month in months) month: const <CountryGame>[]};
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('StatsPeriodService', () {
    final now = DateTime.utc(2026, 11, 16, 12);
    final games = [
      _game(DateTime.utc(2026, 11, 16, 11)), // aujourd'hui
      _game(DateTime.utc(2026, 10, 17, 13)), // il y a 29 jours
      _game(DateTime.utc(2026, 10, 16, 11)), // il y a 31 jours
      _game(DateTime.utc(2026, 8, 19)), // il y a 89 jours
      _game(DateTime.utc(2026, 8, 17)), // il y a 91 jours
      _game(null),
    ];

    test('« 1 mois » = 30 derniers jours, « 3 mois » = 90 derniers jours', () {
      expect(StatsPeriodService.filter(games, StatsPeriod.oneMonth, now), games.sublist(0, 2));
      expect(StatsPeriodService.filter(games, StatsPeriod.threeMonths, now), games.sublist(0, 4));
    });

    test('le 1er du mois, « 1 mois » contient les parties des 30 jours précédents', () {
      final firstOfMonth = DateTime.utc(2026, 12, 1, 8);
      final november = [_game(DateTime.utc(2026, 11, 2, 9)), _game(DateTime.utc(2026, 11, 30, 22))];
      expect(StatsPeriodService.filter(november, StatsPeriod.oneMonth, firstOfMonth), november);
    });

    test('parties classées seulement, sur demande', () {
      final mixed = [_game(DateTime.utc(2026, 11, 15)), _game(DateTime.utc(2026, 11, 14), rated: false)];
      expect(StatsPeriodService.filter(mixed, StatsPeriod.oneMonth, now), mixed);
      expect(StatsPeriodService.filter(mixed, StatsPeriod.oneMonth, now, ratedOnly: true), [mixed.first]);
    });

    test('preferRated : les classées, ou toutes s\'il n\'y en a aucune', () {
      final rated = _game(DateTime.utc(2026, 11, 15));
      final unrated = _game(DateTime.utc(2026, 11, 14), rated: false);
      expect(StatsPeriodService.preferRated([rated, unrated]), [rated]);
      expect(StatsPeriodService.preferRated([unrated]), [unrated]);
    });

    test('début de la période', () {
      expect(StatsPeriodService.start(StatsPeriod.oneMonth, now), DateTime.utc(2026, 10, 17, 12));
    });
  });

  test('période : « 1 mois » par défaut, changement notifié', () {
    final viewModel = StatsPeriodViewModel();
    expect(viewModel.period, StatsPeriod.oneMonth);
    var notified = 0;
    viewModel.addListener(() => notified++);
    viewModel.select(StatsPeriod.threeMonths);
    viewModel.select(StatsPeriod.threeMonths);
    expect(viewModel.period, StatsPeriod.threeMonths);
    expect(notified, 1);
  });

  group('PlayerGamesViewModel.gamesIn', () {
    test('même liste tant que parties et période ne changent pas', () {
      final now = DateTime.utc(2026, 11, 16, 12);
      final repository = GameRepository(
        store: GameStore(newDatabaseFactoryMemory()),
        source: _NoSource(),
        now: () => now,
      );
      final games = [_game(DateTime.utc(2026, 11, 10)), _game(DateTime.utc(2026, 9, 10))];
      final viewModel = PlayerGamesViewModel(repository, 'alice', initialGames: games, upToDate: true);

      final oneMonth = viewModel.gamesIn(StatsPeriod.oneMonth);
      expect(oneMonth, hasLength(1));
      expect(identical(viewModel.gamesIn(StatsPeriod.oneMonth), oneMonth), isTrue);
      expect(viewModel.gamesIn(StatsPeriod.threeMonths), hasLength(2));
    });

    test('parties classées seulement : autre liste, mise en cache elle aussi', () {
      final now = DateTime.utc(2026, 11, 16, 12);
      final repository = GameRepository(
        store: GameStore(newDatabaseFactoryMemory()),
        source: _NoSource(),
        now: () => now,
      );
      final games = [_game(DateTime.utc(2026, 11, 10)), _game(DateTime.utc(2026, 11, 9), rated: false)];
      final viewModel = PlayerGamesViewModel(repository, 'alice', initialGames: games, upToDate: true);

      final rated = viewModel.gamesIn(StatsPeriod.oneMonth, ratedOnly: true);
      expect(rated, [games.first]);
      expect(identical(viewModel.gamesIn(StatsPeriod.oneMonth, ratedOnly: true), rated), isTrue);
      expect(viewModel.gamesIn(StatsPeriod.oneMonth), hasLength(2));
    });
  });
}
