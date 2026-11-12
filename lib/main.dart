import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/changelog_service.dart';
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
  runApp(MyApp(initialThemeMode: themeMode, lastSeenVersion: lastSeenVersion));
}

class MyApp extends StatelessWidget {
  final ThemeMode initialThemeMode;
  final String? lastSeenVersion;

  const MyApp({super.key, this.initialThemeMode = ThemeMode.system, this.lastSeenVersion});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
