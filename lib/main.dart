import 'dart:async';

import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/changelog_service.dart';
import 'services/game_repository.dart';
import 'services/theme_preference_service.dart';
import 'theme/app_theme.dart';
import 'viewmodels/changelog_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Thème choisi lors d'une visite précédente, sinon celui du système.
  final themeMode = await ThemePreferenceService().load();
  // Dernière version dont les nouveautés ont été consultées (pastille du
  // pied de page).
  final lastSeenVersion = await ChangelogService().loadLastSeen();
  // Parties stockées localement : nettoyage au lancement, sans attendre.
  final repository = GameRepository.local();
  unawaited(repository.purge());
  unawaited(GameRepository.removeLegacyCache());
  runApp(MyApp(initialThemeMode: themeMode, lastSeenVersion: lastSeenVersion, repository: repository));
}

class MyApp extends StatelessWidget {
  final ThemeMode initialThemeMode;
  final String? lastSeenVersion;

  /// Accès aux parties des joueurs ; par défaut stockage local + chess.com.
  final GameRepository? repository;

  const MyApp({super.key, this.initialThemeMode = ThemeMode.system, this.lastSeenVersion, this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<GameRepository>(create: (_) => repository ?? GameRepository.local()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel(initialThemeMode)),
        ChangeNotifierProvider(create: (_) => ChangelogViewModel(lastSeenVersion)),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, child) => MaterialApp(
          // Pas de `locale` imposée : la langue suit celle du navigateur parmi
          // AppLocalizations.supportedLocales, sinon la première (anglais).
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeViewModel.themeMode,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
