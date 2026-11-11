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

  /// Bleu du logo (case bleue de l'échiquier, design/logo.svg).
  static const Color logoBlue = Color(0xFF3F6DB3);

  // Carte des pays : teintes du bleu du logo, de la plus claire (pays peu
  // joué) à la plus foncée et intense (pays le plus joué). Mêmes teintes
  // dans les deux thèmes : un bleu intense signifie toujours beaucoup de
  // parties, et la légende ne change pas.
  static const Color _mapLow = Color(0xFFB4C8EA);
  static const Color _mapHigh = Color(0xFF1C3A70);

  /// Couleur d'un pays joué, [intensity] entre 0 et 1. La teinte médiane
  /// est celle du logo.
  static Color mapCountryColor(double intensity) => intensity <= 0.5
      ? Color.lerp(_mapLow, logoBlue, intensity * 2)!
      : Color.lerp(logoBlue, _mapHigh, (intensity - 0.5) * 2)!;

  /// Pays contre lesquels aucune partie n'a été jouée : gris neutre. En
  /// sombre, assez clair pour que les bleus les plus foncés s'en détachent.
  static Color mapEmptyCountry(BuildContext context) =>
      _isDark(context) ? const Color(0xFF5A5A5A) : const Color(0xFFDCDCDC);

  /// Mer (fond de la carte). En sombre, un peu plus clair que la page pour
  /// que les pays bleu foncé restent lisibles.
  static Color mapBackground(BuildContext context) => _isDark(context)
      ? const Color(0xFF333333)
      : Theme.of(context).colorScheme.surfaceContainerLow;

  /// Contour du pays sélectionné : en clair, gris moyen à 40 % du blanc
  /// vers le noir (#999999), le noir et le gris foncé étant trop durs ; en
  /// sombre, couleur du texte.
  static Color mapSelectedBorder(BuildContext context) => _isDark(context)
      ? Theme.of(context).colorScheme.onSurface
      : const Color(0xFF999999);

  /// Marqueurs des 3 pays les plus rencontrés : or, argent, bronze. Teintes
  /// soutenues pour que l'icône et le chiffre blancs restent lisibles.
  static const List<Color> podiumColors = [
    Color(0xFFA67C00), // or
    Color(0xFF6B7682), // argent
    Color(0xFF8C5A2B), // bronze
  ];
}
