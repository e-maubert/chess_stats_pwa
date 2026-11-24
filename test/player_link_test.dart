import 'package:chess_stats_pwa/main.dart';
import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/models/year_month.dart';
import 'package:chess_stats_pwa/screens/home_screen.dart';
import 'package:chess_stats_pwa/screens/recap_screen.dart';
import 'package:chess_stats_pwa/screens/scouting_screen.dart';
import 'package:chess_stats_pwa/screens/stats_screen.dart';
import 'package:chess_stats_pwa/services/game_repository.dart';
import 'package:chess_stats_pwa/services/game_store.dart';
import 'package:chess_stats_pwa/services/monthly_games_source.dart';
import 'package:chess_stats_pwa/services/player_link_service.dart';
import 'package:chess_stats_pwa/services/recap_seen_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _now = DateTime.utc(2026, 11, 19, 12);

class _Source implements MonthlyGamesSource {
  @override
  Future<Map<YearMonth, List<CountryGame>>> fetchMonths(String username, List<YearMonth> months) async {
    if (username == 'inconnu') throw Exception('joueur introuvable');
    return {
      for (final month in months)
        month: [
          CountryGame(
            opponent: 'bob',
            timeClass: 'blitz',
            result: 'win',
            playerColor: 'white',
            opening: 'Italian-Game',
            endTime: _now.subtract(const Duration(days: 1)),
            url: 'https://chess.com/$username/${month.key}',
          ),
        ],
    };
  }
}

void main() {
  group('PlayerLinkService', () {
    test('joueur et page tirés de l\'adresse, pseudo en minuscules', () {
      expect(PlayerLinkService.fromPath('/Hikaru'), (username: 'hikaru', page: PlayerPage.stats));
      expect(PlayerLinkService.fromPath('/tarantino_girl/'), (username: 'tarantino_girl', page: PlayerPage.stats));
      expect(PlayerLinkService.fromPath('/Hikaru/recap'), (username: 'hikaru', page: PlayerPage.recap));
      expect(PlayerLinkService.fromPath('/hikaru/Scout/'), (username: 'hikaru', page: PlayerPage.scout));
      expect(PlayerLinkService.fromPath('/'), isNull);
      expect(PlayerLinkService.fromPath('/a/b'), isNull);
      expect(PlayerLinkService.fromPath('/hikaru/inconnue'), isNull);
      expect(PlayerLinkService.fromPath('/hikaru/recap/x'), isNull);
      expect(PlayerLinkService.fromPath('/manifest.json'), isNull);
      expect(PlayerLinkService.fromPath(null), isNull);
    });

    test('lien complet sur le site ouvert', () {
      final base = Uri.parse('https://chess-stats-test.netlify.app/hikaru?x=1#y');
      expect(PlayerLinkService.link(' MagnusCarlsen ', base: base).toString(),
          'https://chess-stats-test.netlify.app/magnuscarlsen');
      expect(PlayerLinkService.link('bob', base: Uri.parse('http://localhost:8080/')).toString(),
          'http://localhost:8080/bob');
      expect(PlayerLinkService.link('Bob', page: PlayerPage.recap, base: base).toString(),
          'https://chess-stats-test.netlify.app/bob/recap');
      expect(PlayerLinkService.link('bob', page: PlayerPage.scout, base: base).toString(),
          'https://chess-stats-test.netlify.app/bob/scout');
    });
  });

  group('Ouverture d\'un lien', () {
    late GameRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = GameRepository(store: GameStore(newDatabaseFactoryMemory()), source: _Source(), now: () => _now);
    });

    Future<void> open(WidgetTester tester, String path) async {
      tester.platformDispatcher.localesTestValue = [const Locale('fr', 'FR')];
      tester.platformDispatcher.defaultRouteNameTestValue = path;
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);
      await tester.pumpWidget(MyApp(repository: repository));
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();
    }

    testWidgets('/<pseudo> : stats sans bilan, partage, puis retour à l\'accueil', (tester) async {
      await open(tester, '/Hikaru');
      expect(find.byType(RecapScreen), findsNothing);
      expect(find.byType(StatsScreen), findsOneWidget);
      expect(find.byTooltip('Partager'), findsOneWidget);

      // Hors navigateur, pas de menu de partage : lien copié.
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
        return null;
      });
      await tester.tap(find.byTooltip('Partager'));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
      await tester.pump();
      expect(copied, endsWith('/hikaru'));
      expect(find.text('Lien copié'), findsOneWidget);

      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('/<pseudo>/recap : bilan au-dessus des stats, compté comme vu', (tester) async {
      await open(tester, '/hikaru/recap');
      expect(find.byType(RecapScreen), findsOneWidget);
      expect(await RecapSeenService().hasSeen('hikaru'), isTrue);

      await tester.tap(find.text('Passer'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(RecapScreen), findsNothing);
      expect(find.byType(StatsScreen), findsOneWidget);
    });

    testWidgets('/<pseudo>/scout : comment le battre au-dessus des stats', (tester) async {
      await open(tester, '/hikaru/scout');
      expect(find.byType(ScoutingScreen), findsOneWidget);
      expect(await RecapSeenService().hasSeen('hikaru'), isFalse);

      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ScoutingScreen), findsNothing);
      expect(find.byType(StatsScreen), findsOneWidget);
    });

    testWidgets('joueur introuvable : accueil, pseudo pré-rempli et message', (tester) async {
      await open(tester, '/inconnu');
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('inconnu'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
