import 'package:flutter/material.dart';

/// Thèmes clair et sombre de l'app, à partir de la même couleur de base.
class AppTheme {
  static const Color _seed = Colors.blue;

  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: _seed),
    useMaterial3: true,
  );

  /// Fond du mode sombre : gris très foncé neutre plutôt que le noir bleuté
  /// généré à partir de la couleur de base (ni noir pur, trop contrasté
  /// avec le texte blanc).
  static const Color darkBackground = Color(0xFF191919);

  // Surfaces, textes et bordures du mode sombre en gris neutres (sans
  // teinte bleue) ; le bleu reste réservé aux accents (puces, courbe...).
  static final ThemeData dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark).copyWith(
      surface: darkBackground,
      surfaceDim: darkBackground,
      surfaceBright: const Color(0xFF3A3A3A),
      surfaceContainerLowest: const Color(0xFF141414),
      surfaceContainerLow: const Color(0xFF1E1E1E),
      surfaceContainer: const Color(0xFF232323),
      surfaceContainerHigh: const Color(0xFF2B2B2B),
      surfaceContainerHighest: const Color(0xFF353535),
      onSurface: const Color(0xFFE6E6E6),
      onSurfaceVariant: const Color(0xFFC6C6C6),
      outline: const Color(0xFF8F8F8F),
      outlineVariant: const Color(0xFF444444),
    ),
    useMaterial3: true,
  );

  static bool _isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  // Textes colorés (variation de classement, écart de temps) : teintes
  // foncées sur fond clair, claires sur fond sombre, pour rester lisibles.
  static Color positiveText(BuildContext context) =>
      _isDark(context) ? Colors.green.shade300 : Colors.green.shade700;

  static Color negativeText(BuildContext context) =>
      _isDark(context) ? Colors.red.shade300 : Colors.red.shade700;

  static Color warningText(BuildContext context) =>
      _isDark(context) ? Colors.amber.shade300 : Colors.amber.shade800;
}
