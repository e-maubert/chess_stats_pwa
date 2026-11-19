import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/models/year_month.dart';
import 'package:chess_stats_pwa/screens/recap_screen.dart';
import 'package:chess_stats_pwa/services/game_repository.dart';
import 'package:chess_stats_pwa/services/game_store.dart';
import 'package:chess_stats_pwa/services/monthly_games_source.dart';
import 'package:chess_stats_pwa/widgets/story_slides.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _EmptySource implements MonthlyGamesSource {
  @override
  Future<Map<YearMonth, List<CountryGame>>> fetchMonths(String username, List<YearMonth> months) async =>
      {for (final month in months) month: const []};
}

final _now = DateTime.utc(2026, 11, 19, 12);

CountryGame _game(String result, int daysAgo, {String opponent = 'x', bool rated = true}) => CountryGame(
      opponent: opponent,
      timeClass: 'blitz',
      result: result,
      playerColor: 'white',
      opening: 'Italian-Game',
      lossCause: result == 'loss' ? 'timeout' : null,
      rating: 1500,
      rated: rated,
      endTime: _now.subtract(Duration(days: daysAgo)),
    );

Future<void> _pump(WidgetTester tester, List<CountryGame> games, {Widget? home}) async {
  final repository = GameRepository(
    store: GameStore(newDatabaseFactoryMemory()),
    source: _EmptySource(),
    now: () => _now,
  );
  await tester.pumpWidget(Provider.value(
    value: repository,
    child: MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home ?? RecapScreen(username: 'hikaru', games: games, upToDate: true),
    ),
  ));
  await tester.pumpAndSettle();
}

Future<void> _next(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Suivant'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('diapositives du général au détail, sur les 30 derniers jours', (tester) async {
    await _pump(tester, [
      _game('win', 1, opponent: 'Bob'),
      _game('win', 2, opponent: 'Bob'),
      _game('loss', 3),
      _game('draw', 4),
      // Hors des 30 derniers jours, ou non classée : ignorée.
      _game('loss', 40),
      _game('loss', 5, rated: false),
    ]);

    expect(find.text('hikaru, voici tes 30 derniers jours'), findsOneWidget);
    await _next(tester);
    expect(find.text('Parties jouées'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Tranquille : une partie de temps en temps.'), findsOneWidget);
    await _next(tester);
    expect(find.text('Tes résultats'), findsOneWidget);
    expect(find.textContaining(RegExp(r'^50\s%$')), findsOneWidget);
    expect(find.text('de parties gagnées'), findsOneWidget);
    expect(find.text('2 victoires'), findsOneWidget);
    expect(find.text('1 nulle'), findsOneWidget);
    expect(find.text('1 défaite'), findsOneWidget);
    expect(find.text('Plus de victoires que de défaites : bien joué !'), findsOneWidget);
    await _next(tester);
    expect(find.text('Ta cadence préférée'), findsOneWidget);
    await _next(tester);
    expect(find.text('Plus longue série de victoires'), findsOneWidget);

    // Un seul adversaire affronté plusieurs fois (Bob) ; pas assez de
    // parties par ouverture pour un point faible. Puis l'invitation aux
    // stats.
    final slides = tester.widget<StorySlides>(find.byType(StorySlides)).slides;
    expect(slides.map((s) => s.label), contains('Ton adversaire le plus fréquent'));
    expect(slides.map((s) => s.label), isNot(contains("L'ouverture qui te résiste")));
    expect(slides.last.value, 'Envie d\'aller plus loin ?');
  });

  testWidgets('seulement des parties non classées : bilan sur toutes', (tester) async {
    await _pump(tester, [_game('win', 1, rated: false), _game('loss', 2, rated: false)]);
    await _next(tester);
    expect(find.text('Parties jouées'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('sans partie récente : une seule diapositive vers les stats', (tester) async {
    await _pump(tester, [_game('win', 45)]);

    expect(find.text('Aucune partie ces 30 derniers jours'), findsOneWidget);
    expect(find.text('Voir toutes les stats'), findsOneWidget);
    expect(tester.widget<StorySlides>(find.byType(StorySlides)).slides, hasLength(1));
  });

  testWidgets('appuis rapides : chacun avance d\'une diapositive', (tester) async {
    await _pump(tester, [_game('win', 1), _game('win', 2)]);

    await tester.tap(find.byTooltip('Suivant'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byTooltip('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Tes résultats'), findsOneWidget);
  });

  testWidgets('bilan revu depuis les stats : « Passer » y ramène', (tester) async {
    await _pump(
      tester,
      const [],
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecapScreen(username: 'hikaru', games: [_game('win', 1)], upToDate: true, replay: true),
            ),
          ),
          child: const Text('page des stats'),
        ),
      ),
    );
    await tester.tap(find.text('page des stats'));
    await tester.pumpAndSettle();
    expect(find.byType(RecapScreen), findsOneWidget);

    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();
    expect(find.byType(RecapScreen), findsNothing);
    expect(find.text('page des stats'), findsOneWidget);
  });
}
