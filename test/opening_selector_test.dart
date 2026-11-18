import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/viewmodels/stats_filter_viewmodel.dart';
import 'package:chess_stats_pwa/widgets/stats_filter_selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

CountryGame g(String opening) => CountryGame(
      country: 'FR',
      opponent: 'x',
      timeClass: 'blitz',
      result: 'win',
      playerColor: 'white',
      opening: opening,
    );

void main() {
  testWidgets('menu des ouvertures : noms traduits, nombres, choix transmis', (tester) async {
    final opening = OpeningFilterViewModel();
    final games = [
      for (var i = 0; i < 3; i++) g('Sicilian-Defense-Najdorf'),
      for (final family in ['French-Defense', 'Ruy-Lopez', 'English-Opening', 'Italian-Game', 'Caro-Kann'])
        g(family),
    ];
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimeClassViewModel.temporary()),
        ChangeNotifierProvider(create: (_) => PlayerColorViewModel.temporary()),
        ChangeNotifierProvider.value(value: opening),
      ],
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: OpeningSelector(games: games)),
      ),
    ));

    expect(find.text('Toutes les ouvertures'), findsOneWidget);
    await tester.tap(find.text('Toutes les ouvertures'));
    await tester.pumpAndSettle();

    expect(find.text('Défense sicilienne (3)'), findsOneWidget);
    expect(find.text('Autres ouvertures (1)'), findsOneWidget);

    await tester.tap(find.text('Défense sicilienne (3)'));
    await tester.pumpAndSettle();
    expect(opening.opening, 'Sicilian-Defense');
  });
}
