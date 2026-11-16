import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:chess_stats_pwa/widgets/time_class_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// La tenue sur une seule ligne se vérifie dans le navigateur : la police des
// tests (un carré par lettre) est bien plus large que la vraie.
void main() {
  Future<void> pump(WidgetTester tester, Locale locale, ValueChanged<String?> onSelected) =>
      tester.pumpWidget(MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TimeClassFilter(
            timeClasses: const [null, 'bullet', 'blitz', 'rapid'],
            selected: null,
            onSelected: onSelected,
          ),
        ),
      ));

  testWidgets('petit titre « Cadence » et bouton « Toutes », sans coche', (tester) async {
    await pump(tester, const Locale('fr'), (_) {});

    expect(find.text('Cadence'), findsOneWidget);
    expect(find.text('Toutes'), findsOneWidget);
    expect(find.text('Rapide'), findsOneWidget);
    for (final chip in tester.widgetList<ChoiceChip>(find.byType(ChoiceChip))) {
      expect(chip.showCheckmark, isFalse);
    }
  });

  testWidgets('libellés anglais', (tester) async {
    await pump(tester, const Locale('en'), (_) {});

    expect(find.text('Time control'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
  });

  testWidgets('choisir une cadence la signale', (tester) async {
    String? chosen = 'none';
    await pump(tester, const Locale('fr'), (timeClass) => chosen = timeClass);

    await tester.tap(find.text('Blitz'));
    expect(chosen, 'blitz');
  });
}
