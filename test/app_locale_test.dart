import 'package:chess_stats_pwa/main.dart';
import 'package:chess_stats_pwa/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lance l'app avec un navigateur simulé dans la langue [browser] et renvoie
/// la langue retenue et le titre de l'écran d'accueil.
Future<({String language, String title})> launch(WidgetTester tester, Locale browser) async {
  tester.platformDispatcher.localesTestValue = [browser];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);

  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();

  final context = tester.element(find.byType(HomeScreen));
  return (
    language: Localizations.localeOf(context).languageCode,
    title: AppLocalizations.of(context)!.appTitle,
  );
}

void main() {
  testWidgets('navigateur en français : app en français', (tester) async {
    final app = await launch(tester, const Locale('fr', 'FR'));
    expect(app.language, 'fr');
    expect(app.title, "Statistiques d'échecs");
    expect(find.text('Rechercher'), findsOneWidget);
  });

  testWidgets('navigateur en anglais : app en anglais', (tester) async {
    final app = await launch(tester, const Locale('en', 'US'));
    expect(app.language, 'en');
    expect(app.title, 'Chess Stats');
    expect(find.text('Search'), findsOneWidget);
  });

  testWidgets('autre langue : app en anglais', (tester) async {
    final app = await launch(tester, const Locale('de', 'DE'));
    expect(app.language, 'en');
  });
}
