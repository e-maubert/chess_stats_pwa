import 'package:flutter/material.dart';

/// Thèmes clair et sombre de l'app, à partir de la même couleur de base.
class AppTheme {
  static const Color _seed = Colors.blue;

  /// Titre de la barre du haut centré sur toutes les pages et toutes les
  /// plateformes (par défaut, Flutter ne le centre que sur iOS / macOS).
  static const AppBarTheme _appBarTheme = AppBarTheme(centerTitle: true);

  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: _seed),
    appBarTheme: _appBarTheme,
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
    appBarTheme: _appBarTheme,
    useMaterial3: true,
  );

  static bool _isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  // Textes colorés (variation de classement, écart de temps) : teintes
  // foncées sur fond clair, claires sur fond sombre, pour rester lisibles.
  static Color positiveText(BuildContext context) =>
      _isDark(context) ? Colors.green.shade300 : Colors.green.shade700;

  static Color negativeText(BuildContext context) =>
      _isDark(context) ? Colors.red.shade300 : Colors.red.shade700;

  /// Couleur de la courbe de classement d'une cadence, lisible sur les deux
  /// thèmes.
  static Color timeClassColor(BuildContext context, String timeClass) {
    final dark = _isDark(context);
    return switch (timeClass) {
      'bullet' => dark ? Colors.orange.shade300 : Colors.orange.shade800,
      'blitz' => dark ? Colors.lightBlue.shade300 : Colors.blue.shade700,
      _ => dark ? Colors.purple.shade200 : Colors.purple.shade500,
    };
  }

  /// Pastilles victoires / nulles / défaites : fond plein et texte blanc,
  /// lisibles sur n'importe quel fond (diapositives colorées du bilan).
  static final Color winBadge = Colors.green.shade700;
  static final Color drawBadge = Colors.blueGrey.shade600;
  static final Color lossBadge = Colors.red.shade700;

  /// Couleur de chaque niveau de forme (FormLevel, du pire au meilleur) :
  /// rouge, orange, gris-bleu, vert, puis or « légendaire ». Pièce dessinée
  /// sur un disque clair : lisible dans les deux thèmes.
  static final List<Color> _formColors = [
    Colors.red.shade600,
    Colors.orange.shade600,
    Colors.blueGrey.shade300,
    Colors.green.shade500,
    const Color(0xFFE0B23A),
  ];

  static Color formColor(int levelIndex) => _formColors[levelIndex];

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

  // Carte « Performance » : rouge foncé (0 %) → jaune (50 %, équilibre) →
  // vert foncé (100 %), d'après la palette RdYlGn de ColorBrewer. La clarté
  // varie avec la teinte : plus on s'éloigne de 50 %, plus c'est foncé, ce
  // qui reste lisible quand le rouge et le vert se confondent (daltonisme).
  // Mêmes teintes dans les deux thèmes, comme le bleu de l'autre carte.
  static const List<Color> _performanceStops = [
    Color(0xFFA50026), // 0 %
    Color(0xFFF46D43), // 25 %
    Color(0xFFFEE08B), // 50 %
    Color(0xFF66BD63), // 75 %
    Color(0xFF006837), // 100 %
  ];

  /// Couleur d'un pays selon sa performance [score], entre 0 et 1.
  static Color performanceColor(double score) {
    final position = score.clamp(0.0, 1.0) * (_performanceStops.length - 1);
    final index = position.floor().clamp(0, _performanceStops.length - 2);
    return Color.lerp(_performanceStops[index], _performanceStops[index + 1], position - index)!;
  }

  /// Couleur d'une classe de performance du cadran des heures de jeu,
  /// [index] de 0 (la plus faible) à 4 (la meilleure) : mêmes teintes que la
  /// carte Performance, jaune pour l'équilibre.
  static Color performanceBandColor(int index) => _performanceStops[index];

  /// Pays joués mais trop peu pour juger la performance : gris distinct de
  /// celui des pays jamais rencontrés (plus foncé en clair, plus clair en
  /// sombre).
  static Color mapNotEnoughGames(BuildContext context) =>
      _isDark(context) ? const Color(0xFF8C8C8C) : const Color(0xFFAFAFAF);

  /// Marqueurs des points forts (flèche vers le haut) et des points faibles
  /// (flèche vers le bas) : teintes soutenues pour que l'icône et le
  /// chiffre blancs restent lisibles.
  static const Color strengthMarker = Color(0xFF1B7A3A);
  static const Color weaknessMarker = Color(0xFFB3261E);

  /// Marqueurs des 3 pays les plus rencontrés : or, argent, bronze. Teintes
  /// soutenues pour que l'icône et le chiffre blancs restent lisibles.
  static const List<Color> podiumColors = [
    Color(0xFFA67C00), // or
    Color(0xFF6B7682), // argent
    Color(0xFF8C5A2B), // bronze
  ];
}
