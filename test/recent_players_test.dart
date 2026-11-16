import 'package:chess_stats_pwa/main.dart';
import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/models/year_month.dart';
import 'package:chess_stats_pwa/services/game_repository.dart';
import 'package:chess_stats_pwa/services/game_store.dart';
import 'package:chess_stats_pwa/services/monthly_games_source.dart';
import 'package:chess_stats_pwa/viewmodels/recent_players_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _OneGameSource implements MonthlyGamesSource {
  @override
  Future<Map<YearMonth, List<CountryGame>>> fetchMonths(String username, List<YearMonth> months) async => {
        for (final month in months)
          month: [
            CountryGame(
              country: 'FR',
              opponent: 'bob',
              timeClass: 'blitz',
              result: 'win',
              playerColor: 'white',
              opening: 'Sicilian-Defense',
              endTime: DateTime.utc(month.year, month.month, 2),
              url: 'https://chess.com/$username/${month.key}',
            ),
          ],
      };
}

void main() {
  late DateTime now;
  late GameStore store;
  late GameRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    now = DateTime.utc(2026, 11, 16, 12);
    store = GameStore(newDatabaseFactoryMemory());
    repository = GameRepository(store: store, source: _OneGameSource(), now: () => now);
  });

  Future<void> view(String username, DateTime at) async {
    now = at;
    await repository.updateGames(username);
    await repository.markViewed(username);
  }

  group('Joueurs déjà consultés', () {
    test('du plus récent au plus ancien, sans ceux non consultés depuis plus d\'un mois', () async {
      await view('Ancien', DateTime.utc(2026, 10, 1));
      await view('Hikaru', DateTime.utc(2026, 11, 10));
      await view('MagnusCarlsen', DateTime.utc(2026, 11, 15));
      now = DateTime.utc(2026, 11, 16);
      expect((await repository.viewedPlayers()).map((p) => p.username), ['MagnusCarlsen', 'Hikaru']);

      // Après la purge, le joueur expiré n'existe plus du tout.
      await repository.purge();
      expect(await store.player('ancien'), isNull);
    });

    test('filtre pendant la saisie, sans tenir compte des majuscules', () {
      final players = [
        StoredPlayer(username: 'MagnusCarlsen', lastViewedAt: now),
        StoredPlayer(username: 'Hikaru', lastViewedAt: now),
      ];
      expect(RecentPlayersViewModel.filter(players, ''), players);
      expect(RecentPlayersViewModel.filter(players, ' hik').map((p) => p.username), ['Hikaru']);
      expect(RecentPlayersViewModel.filter(players, 'CAR').map((p) => p.username), ['MagnusCarlsen']);
      expect(RecentPlayersViewModel.filter(players, 'zzz'), isEmpty);
    });

    test('retirer un joueur supprime aussi ses parties stockées', () async {
      await view('Hikaru', now);
      await view('Alice', now);
      final viewModel = RecentPlayersViewModel(repository);
      await viewModel.load();
      await viewModel.remove(viewModel.players.firstWhere((p) => p.username == 'Hikaru'));

      expect(viewModel.players.map((p) => p.username), ['Alice']);
      expect(await store.player('hikaru'), isNull);
      expect(await store.months('hikaru'), isEmpty);
      expect(await repository.storedGames('hikaru'), isNull);
      expect(await store.months('alice'), isNotEmpty);
    });
  });

  group('Champ de recherche', () {
    Future<void> launch(WidgetTester tester) async {
      tester.platformDispatcher.localesTestValue = [const Locale('fr', 'FR')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await tester.pumpWidget(MyApp(repository: repository));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();
    }

    testWidgets('sans joueur consulté : aucune liste', (tester) async {
      await launch(tester);
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('clic : joueurs consultés ; saisie : liste filtrée ; croix : joueur retiré', (tester) async {
      await tester.runAsync(() async {
        await view('Hikaru', DateTime.utc(2026, 11, 10));
        await view('MagnusCarlsen', DateTime.utc(2026, 11, 15));
      });
      await launch(tester);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect(tiles.map((tile) => (tile.title as Text).data), ['MagnusCarlsen', 'Hikaru']);

      await tester.enterText(find.byType(TextField), 'hik');
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Hikaru'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'MagnusCarlsen'), findsNothing);

      await tester.runAsync(() async {
        await tester.tap(find.byTooltip('Retirer Hikaru de la liste'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNothing);
      expect(await tester.runAsync(() => store.player('hikaru')), isNull);
    });
  });
}
