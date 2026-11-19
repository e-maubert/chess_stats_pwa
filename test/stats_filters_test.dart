import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:chess_stats_pwa/viewmodels/stats_filter_viewmodel.dart';
import 'package:chess_stats_pwa/widgets/stats_filter_selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  Future<(TimeClassViewModel, PlayerColorViewModel)> pump(WidgetTester tester, Locale locale) async {
    final timeClass = TimeClassViewModel();
    final color = PlayerColorViewModel();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: timeClass),
        ChangeNotifierProvider.value(value: color),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: Column(children: [TimeClassSelector(), PlayerColorSelector()])),
      ),
    ));
    return (timeClass, color);
  }

  testWidgets('cadence et couleur en français, choix transmis aux filtres communs', (tester) async {
    final (timeClass, color) = await pump(tester, const Locale('fr'));
    expect(find.text('Toutes'), findsOneWidget);
    expect(find.text('Les deux'), findsOneWidget);

    await tester.tap(find.text('Blitz'));
    await tester.tap(find.text('Noirs'));
    await tester.pump();
    expect(timeClass.timeClass, 'blitz');
    expect(color.color, 'black');
  });

  testWidgets('libellés anglais', (tester) async {
    await pump(tester, const Locale('en'));
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Both'), findsOneWidget);
    expect(find.text('White'), findsOneWidget);
  });

  testWidgets('parties classées par défaut, toutes sur demande', (tester) async {
    final rated = RatedFilterViewModel();
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: rated,
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: RatedSelector()),
      ),
    ));
    expect(rated.ratedOnly, isTrue);
    expect(find.text('Parties classées'), findsOneWidget);

    await tester.tap(find.text('Toutes les parties'));
    await tester.pump();
    expect(rated.ratedOnly, isFalse);
  });

  test('par défaut : toutes cadences, les deux couleurs, toutes ouvertures', () {
    expect(TimeClassViewModel().timeClass, isNull);
    expect(PlayerColorViewModel().color, isNull);
    expect(OpeningFilterViewModel().opening, isNull);
  });
}
