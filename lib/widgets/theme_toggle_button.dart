import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../viewmodels/theme_viewmodel.dart';

/// Bouton de la barre du haut : soleil en mode sombre (passer en clair),
/// lune en mode clair (passer en sombre).
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return IconButton(
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      tooltip: isDark ? l10n.switchToLightMode : l10n.switchToDarkMode,
      onPressed: () => context.read<ThemeViewModel>().toggle(brightness),
    );
  }
}
