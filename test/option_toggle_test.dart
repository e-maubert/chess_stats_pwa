import 'package:chess_stats_pwa/widgets/option_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(String selected, ValueChanged<String> onChanged) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: OptionToggle<String>(
              options: const ['1 mois', '3 mois', '6 mois'],
              selected: selected,
              labelOf: (option) => option,
              onChanged: onChanged,
            ),
          ),
        ),
      );

  testWidgets('affiche toutes les options et signale celle qui est touchée', (tester) async {
    String? tapped;
    await tester.pumpWidget(host('1 mois', (option) => tapped = option));

    expect(find.text('1 mois'), findsOneWidget);
    expect(find.text('3 mois'), findsOneWidget);
    expect(find.text('6 mois'), findsOneWidget);

    await tester.tap(find.text('6 mois'));
    expect(tapped, '6 mois');
  });

  testWidgets('les options ont toutes la même largeur', (tester) async {
    await tester.pumpWidget(host('3 mois', (_) {}));

    final widths = [
      for (final label in ['1 mois', '3 mois', '6 mois'])
        tester.getSize(find.ancestor(of: find.text(label), matching: find.byType(InkWell))).width,
    ];
    expect(widths.toSet().length, 1);
  });

  testWidgets('la pastille se place sous l\'option choisie', (tester) async {
    await tester.pumpWidget(host('3 mois', (_) {}));
    await tester.pumpAndSettle();

    final pill = tester.getRect(find.byType(FractionallySizedBox));
    final option = tester.getRect(find.ancestor(of: find.text('3 mois'), matching: find.byType(InkWell)));
    expect(pill.center.dx, closeTo(option.center.dx, 0.5));
  });
}
