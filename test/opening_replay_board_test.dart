import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:chess_stats_pwa/widgets/chess_board_view.dart';
import 'package:chess_stats_pwa/widgets/opening_replay_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const line = ['e4', 'e5', 'Nf3'];
const fen = 'rnbqkbnr/pppp1ppp/8/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2';

Widget app({List<String> moves = line}) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SizedBox(
          width: 320,
          child: OpeningReplayBoard(
            line: moves,
            fen: fen,
            flipped: true,
            arrows: const [BoardArrow('b8', 'c6', Colors.green)],
          ),
        ),
      ),
    );

ChessBoardView board(WidgetTester tester) => tester.widget<ChessBoardView>(find.byType(ChessBoardView));

void main() {
  testWidgets('montre d\'abord la position à corriger, avec ses flèches', (tester) async {
    await tester.pumpWidget(app());
    expect(find.text('Position to improve'), findsOneWidget);
    expect(board(tester).fen, fen);
    expect(board(tester).arrows, isNotEmpty);
  });

  testWidgets('début, coup suivant animé, coup précédent', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.byTooltip('Starting position'));
    await tester.pump();
    expect(find.text('Starting position'), findsWidgets);
    expect(board(tester).arrows, isEmpty);

    await tester.tap(find.byTooltip('Next move'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // En plein glissement : position avant le coup, pion e2 vers e4.
    expect(board(tester).slides, [(from: 'e2', to: 'e4')]);
    expect(board(tester).progress, inExclusiveRange(0, 1));
    await tester.pump(OpeningReplayBoard.slideDuration);
    expect(find.text('1.e4'), findsOneWidget);
    expect(board(tester).highlight, (from: 'e2', to: 'e4'));

    await tester.tap(find.byTooltip('Previous move'));
    await tester.pump();
    expect(find.text('Starting position'), findsWidgets);
  });

  testWidgets('Rejouer : de la position de départ jusqu\'à la position à corriger', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.byTooltip('Replay the opening'));
    await tester.pump();
    expect(find.text('Starting position'), findsWidgets);
    expect(find.byTooltip('Pause'), findsOneWidget);

    // 3 coups d'environ 1 s, plus la pause sur la position de départ.
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Position to improve'), findsOneWidget);
    expect(board(tester).fen, fen);
    expect(find.byTooltip('Replay the opening'), findsOneWidget);
  });

  testWidgets('erreur dès le premier coup : échiquier sans commandes', (tester) async {
    await tester.pumpWidget(app(moves: const []));
    expect(find.byTooltip('Replay the opening'), findsNothing);
    expect(find.byType(ChessBoardView), findsOneWidget);
  });
}
