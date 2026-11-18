import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:chess_stats_pwa/viewmodels/stats_filter_viewmodel.dart';
import 'package:chess_stats_pwa/widgets/stats_filter_selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

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

  test('cadence et couleur choisies sont mémorisées, « Toutes » / « Les deux » compris', () async {
    expect(await TimeClassViewModel.preferences.load(), isNull);
    expect(await PlayerColorViewModel.preferences.load(), isNull);

    final timeClass = TimeClassViewModel();
    final color = PlayerColorViewModel();
    await timeClass.select('rapid');
    await color.select('white');
    expect(await TimeClassViewModel.preferences.load(), 'rapid');
    expect(await PlayerColorViewModel.preferences.load(), 'white');

    await color.select(null);
    expect(await PlayerColorViewModel.preferences.load(), isNull);
  });

  test('une valeur enregistrée inconnue retombe sur « Toutes »', () async {
    SharedPreferences.setMockInitialValues({'stats_time_class': 'daily', 'stats_player_color': 'red'});
    expect(await TimeClassViewModel.preferences.load(), isNull);
    expect(await PlayerColorViewModel.preferences.load(), isNull);
  });
}
