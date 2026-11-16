import 'package:chess_stats_pwa/main.dart';
import 'package:chess_stats_pwa/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('page de recherche : titre sous le logo, consigne en sous-titre, exemple dans le champ', (tester) async {
    tester.platformDispatcher.localesTestValue = [const Locale('fr', 'FR')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final logo = tester.getRect(find.byType(AppLogo));
    final title = tester.getRect(find.text('Chess Stats'));
    final subtitle = tester.getRect(find.text("Entrez votre nom d'utilisateur Chess.com"));
    expect(find.text('Chess Stats'), findsOneWidget);
    expect(title.top, greaterThanOrEqualTo(logo.bottom));
    expect(subtitle.top, greaterThanOrEqualTo(title.bottom));

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration?.hintText, 'ex : Hikaru');
  });
}
