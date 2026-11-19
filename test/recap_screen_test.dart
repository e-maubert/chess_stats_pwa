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

CountryGame _game(String result, int daysAgo, {String opponent = 'x'}) => CountryGame(
      opponent: opponent,
      timeClass: 'blitz',
      result: result,
      playerColor: 'white',
      opening: 'Italian-Game',
      lossCause: result == 'loss' ? 'timeout' : null,
      rating: 1500,
      endTime: _now.subtract(Duration(days: daysAgo)),
    );

Future<void> _pump(WidgetTester tester, List<CountryGame> games) async {
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
      home: RecapScreen(username: 'hikaru', games: games, upToDate: true),
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
      // Hors des 30 derniers jours : ignorée.
      _game('loss', 40),
    ]);

    expect(find.text('hikaru, voici tes 30 derniers jours'), findsOneWidget);
    await _next(tester);
    expect(find.text('Parties jouées'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('2 V · 1 N · 1 D'), findsOneWidget);
    await _next(tester);
    expect(find.text('Ta cadence préférée'), findsOneWidget);
    await _next(tester);
    expect(find.text('Plus longue série de victoires'), findsOneWidget);

    // Dernière diapositive : point faible, puis l'invitation aux stats.
    final slides = tester.widget<StorySlides>(find.byType(StorySlides)).slides;
    expect(slides[slides.length - 2].label, 'Ton point faible');
    expect(slides.last.value, 'Envie d\'aller plus loin ?');
  });

  testWidgets('sans partie récente : une seule diapositive vers les stats', (tester) async {
    await _pump(tester, [_game('win', 45)]);

    expect(find.text('Aucune partie ces 30 derniers jours'), findsOneWidget);
    expect(find.text('Voir toutes les stats'), findsOneWidget);
    expect(tester.widget<StorySlides>(find.byType(StorySlides)).slides, hasLength(1));
  });
}
