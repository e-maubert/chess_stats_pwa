import 'package:chess_stats_pwa/main.dart';
import 'package:chess_stats_pwa/services/theme_preference_service.dart';
import 'package:chess_stats_pwa/theme/app_theme.dart';
import 'package:chess_stats_pwa/viewmodels/theme_viewmodel.dart';
import 'package:chess_stats_pwa/widgets/theme_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('ThemePreferenceService', () {
    test('sans choix enregistré : thème du système', () async {
      expect(await ThemePreferenceService().load(), ThemeMode.system);
    });

    test('mémorise clair et sombre', () async {
      final service = ThemePreferenceService();
      await service.save(ThemeMode.dark);
      expect(await service.load(), ThemeMode.dark);
      await service.save(ThemeMode.light);
      expect(await service.load(), ThemeMode.light);
    });
  });

  group('ThemeViewModel', () {
    test('depuis le thème système : passe à l\'opposé de ce qui est affiché', () async {
      final fromLight = ThemeViewModel(ThemeMode.system);
      await fromLight.toggle(Brightness.light);
      expect(fromLight.themeMode, ThemeMode.dark);

      final fromDark = ThemeViewModel(ThemeMode.system);
      await fromDark.toggle(Brightness.dark);
      expect(fromDark.themeMode, ThemeMode.light);
    });

    test('notifie et enregistre le choix', () async {
      final viewModel = ThemeViewModel(ThemeMode.light);
      var notified = 0;
      viewModel.addListener(() => notified++);
      await viewModel.toggle(Brightness.light);
      expect(notified, 1);
      expect(await ThemePreferenceService().load(), ThemeMode.dark);
    });
  });

  group('app', () {
    Brightness brightnessOf(WidgetTester tester) =>
        Theme.of(tester.element(find.byType(ThemeToggleButton))).brightness;

    testWidgets('suit le thème du système au premier lancement', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(brightnessOf(tester), Brightness.dark);
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
      // Fond gris neutre #191919, pas le noir bleuté par défaut.
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      final background = scaffold.backgroundColor ??
          Theme.of(tester.element(find.byType(Scaffold))).scaffoldBackgroundColor;
      expect(background, AppTheme.darkBackground);
      expect(AppTheme.darkBackground, const Color(0xFF191919));
    });

    testWidgets('le bouton bascule le thème', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(brightnessOf(tester), Brightness.light);

      await tester.tap(find.byType(ThemeToggleButton));
      await tester.pumpAndSettle();
      expect(brightnessOf(tester), Brightness.dark);
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
    });

    testWidgets('choix enregistré prioritaire sur le système', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await tester.pumpWidget(const MyApp(initialThemeMode: ThemeMode.light));
      await tester.pumpAndSettle();
      expect(brightnessOf(tester), Brightness.light);
    });
  });
}
