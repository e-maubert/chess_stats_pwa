import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/theme_preference_service.dart';
import 'theme/app_theme.dart';
import 'viewmodels/theme_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Thème choisi lors d'une visite précédente, sinon celui du système.
  final themeMode = await ThemePreferenceService().load();
  runApp(MyApp(initialThemeMode: themeMode));
}

class MyApp extends StatelessWidget {
  final ThemeMode initialThemeMode;

  const MyApp({super.key, this.initialThemeMode = ThemeMode.system});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeViewModel(initialThemeMode),
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
