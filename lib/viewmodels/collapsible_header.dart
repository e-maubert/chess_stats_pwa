/// Filtres de l'en-tête repliables sur mobile : cachés quand on fait
/// défiler les stats vers le bas, réaffichés dès qu'on remonte ou qu'on
/// revient en haut de la page.
class CollapsibleHeader {
  /// Visibilité des filtres après un défilement de [scrollDelta] pixels
  /// (positif = vers le bas de la page), la page étant défilée de [pixels]
  /// depuis le haut.
  static bool visibleAfterScroll({
    required bool visible,
    required double scrollDelta,
    required double pixels,
  }) {
    if (pixels <= 0) return true;
    if (scrollDelta > 0) return false;
    if (scrollDelta < 0) return true;
    return visible;
  }
}
