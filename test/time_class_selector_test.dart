import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:chess_stats_pwa/services/time_class_preference_service.dart';
import 'package:chess_stats_pwa/viewmodels/time_class_viewmodel.dart';
import 'package:chess_stats_pwa/widgets/time_class_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<TimeClassViewModel> pump(WidgetTester tester, Locale locale) async {
    final viewModel = TimeClassViewModel();
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: viewModel,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: TimeClassSelector()),
      ),
    ));
    return viewModel;
  }

  testWidgets('cadences en français, choix transmis au filtre commun', (tester) async {
    final viewModel = await pump(tester, const Locale('fr'));
    expect(find.text('Toutes'), findsOneWidget);
    expect(find.text('Rapide'), findsOneWidget);

    await tester.tap(find.text('Blitz'));
    await tester.pump();
    expect(viewModel.timeClass, 'blitz');
  });

  testWidgets('libellés anglais', (tester) async {
    await pump(tester, const Locale('en'));
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Rapid'), findsOneWidget);
  });

  test('la cadence choisie est mémorisée, « Toutes » comprise', () async {
    const preferences = TimeClassPreferenceService(allowed: TimeClassViewModel.timeClasses);
    expect(await preferences.load(), isNull);

    final viewModel = TimeClassViewModel(null, preferences);
    await viewModel.select('rapid');
    expect(await preferences.load(), 'rapid');
    await viewModel.select(null);
    expect(await preferences.load(), isNull);
  });

  test('une valeur enregistrée inconnue retombe sur « Toutes »', () async {
    SharedPreferences.setMockInitialValues({'stats_time_class': 'daily'});
    expect(await const TimeClassPreferenceService().load(), isNull);
  });
}
