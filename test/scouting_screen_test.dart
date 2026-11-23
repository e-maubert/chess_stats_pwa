import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/models/year_month.dart';
import 'package:chess_stats_pwa/screens/scouting_screen.dart';
import 'package:chess_stats_pwa/services/game_repository.dart';
import 'package:chess_stats_pwa/services/game_store.dart';
import 'package:chess_stats_pwa/services/monthly_games_source.dart';
import 'package:chess_stats_pwa/widgets/form_piece.dart';
import 'package:chess_stats_pwa/widgets/result_badges.dart';
import 'package:chess_stats_pwa/widgets/result_bar.dart';
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

final _now = DateTime.utc(2026, 11, 23, 12);

List<CountryGame> _games(int count,
        {required String result, String color = 'white', String opening = 'Italian-Game', List<String>? moves}) =>
    [
      for (var i = 0; i < count; i++)
        CountryGame(
          opponent: 'x$i',
          timeClass: 'blitz',
          result: result,
          playerColor: color,
          opening: opening,
          rating: 1500,
          openingMoves: moves,
          endTime: _now.subtract(Duration(hours: i + 1)),
        ),
    ];

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
      home: ScoutingScreen(username: 'hikaru', games: games, upToDate: true),
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

  testWidgets('cadence, forme, ouvertures par couleur puis plan de jeu', (tester) async {
    await _pump(tester, [
      ..._games(12, result: 'win', moves: ['d4', 'd5']),
      ..._games(8, result: 'loss', opening: 'Queens-Pawn-Opening', moves: ['d4', 'e6']),
      ..._games(3, result: 'win', color: 'black', opening: 'French-Defense', moves: ['e4', 'e6']),
      ..._games(3, result: 'loss', color: 'black', opening: 'French-Defense', moves: ['e4', 'e6']),
    ]);

    // 1. Cadence analysée, dès la présentation.
    expect(find.text('Comment battre hikaru'), findsOneWidget);
    expect(find.text('en blitz'), findsOneWidget);
    expect(find.textContaining('26 parties de Blitz'), findsOneWidget);
    expect(find.text('Aucune autre cadence jouée sur la période.'), findsOneWidget);

    await _next(tester);
    expect(find.text('Sa forme du moment'), findsOneWidget);
    expect(find.byType(FormPiece), findsOneWidget);
    expect(find.byType(ResultBadges), findsOneWidget);
    expect(find.textContaining('de victoires sur ses 20 dernières parties'), findsOneWidget);

    await _next(tester);
    expect(find.text('Quand ton adversaire a les blancs'), findsOneWidget);
    expect(find.byType(ResultBar), findsNWidgets(2));
    expect(find.textContaining('12 parties · 100'), findsOneWidget);
    expect(find.textContaining('Premier coup : 1.d4 (Partie du pion dame) dans 100'), findsOneWidget);
    expect(find.textContaining('Contre 1.d4, réponds 1…e6 (Défense Horwitz) :'), findsOneWidget);

    await _next(tester);
    expect(find.text('Quand ton adversaire a les noirs'), findsOneWidget);
    expect(find.textContaining('Aucun premier coup ne ressort'), findsOneWidget);

    await _next(tester);
    expect(find.text('Ton plan de jeu'), findsOneWidget);
    expect(find.textContaining('Avec les noirs — Contre 1.d4, réponds 1…e6'), findsOneWidget);
    expect(find.text('Voir ses statistiques'), findsOneWidget);
  });

  testWidgets('sans partie : message et accès aux stats', (tester) async {
    await _pump(tester, const []);
    expect(find.text('Pas assez de parties pour analyser ce joueur'), findsOneWidget);
    expect(find.text('Voir ses statistiques'), findsOneWidget);
  });
}
