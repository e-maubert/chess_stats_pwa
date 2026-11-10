import 'package:flutter/material.dart';

/// Thèmes clair et sombre de l'app, à partir de la même couleur de base.
class AppTheme {
  static const Color _seed = Colors.blue;

  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: _seed),
    useMaterial3: true,
  );

  static final ThemeData dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark),
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
