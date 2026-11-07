import 'package:chess_stats_pwa/main.dart';
import 'package:chess_stats_pwa/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      "la localisation .arb suit la langue de l'app (fr), pas celle du navigateur",
      (tester) async {
    // Navigateur simulé en anglais.
    tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(HomeScreen));
    expect(Localizations.localeOf(context).languageCode, 'fr');
    expect(AppLocalizations.of(context)!.countryStats, 'Statistiques par pays');
  });
}
