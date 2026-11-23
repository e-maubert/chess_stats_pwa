import 'package:chess_stats_pwa/main.dart';
import 'package:chess_stats_pwa/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lance l'app avec un navigateur simulé dans la langue [browser] et renvoie
/// la langue retenue, le titre de l'écran d'accueil et les traductions.
Future<({String language, String title, AppLocalizations l10n})> launch(WidgetTester tester, Locale browser) async {
  tester.platformDispatcher.localesTestValue = [browser];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);

  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();

  final context = tester.element(find.byType(HomeScreen));
  return (
    language: Localizations.localeOf(context).languageCode,
    title: AppLocalizations.of(context)!.appTitle,
    l10n: AppLocalizations.of(context)!,
  );
}

void main() {
  testWidgets('navigateur en français : app en français', (tester) async {
    final app = await launch(tester, const Locale('fr', 'FR'));
    expect(app.language, 'fr');
    // Le nom de l'appli ne se traduit pas.
    expect(app.title, 'Chess Stats');
    expect(app.l10n.statsTitle('hikaru'), 'Chess Stats : hikaru');
    expect(find.text('Afficher les statistiques'), findsOneWidget);
    expect(find.text('Comment battre ce joueur'), findsOneWidget);
  });

  testWidgets('navigateur en anglais : app en anglais', (tester) async {
    final app = await launch(tester, const Locale('en', 'US'));
    expect(app.language, 'en');
    expect(app.title, 'Chess Stats');
    expect(app.l10n.statsTitle('hikaru'), 'Chess Stats: hikaru');
    expect(find.text('Show stats'), findsOneWidget);
    expect(find.text('How to beat this player'), findsOneWidget);
  });

  testWidgets('autre langue : app en anglais', (tester) async {
    final app = await launch(tester, const Locale('de', 'DE'));
    expect(app.language, 'en');
  });
}
