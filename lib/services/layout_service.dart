/// Mise en page de la page des statistiques selon la largeur de l'écran :
/// une colonne sur mobile / tablette, deux sur grand écran.
class LayoutService {
  /// Largeur à partir de laquelle les cartes passent sur deux colonnes.
  static const double twoColumnMinWidth = 1000;

  /// Largeur maximale du contenu : au-delà, il reste centré pour ne pas
  /// étirer les cartes sur les très grands écrans.
  static const double maxContentWidth = 1400;

  /// Largeur maximale de l'écran de recherche (champ et bouton).
  static const double maxSearchWidth = 480;

  static int columnCount(double width) => width >= twoColumnMinWidth ? 2 : 1;

  /// Répartit [items] sur [columns] colonnes en conservant l'ordre de
  /// lecture, de gauche à droite puis de haut en bas : avec 2 colonnes,
  /// le 1er à gauche, le 2e à droite, le 3e à gauche...
  static List<List<T>> splitIntoColumns<T>(List<T> items, int columns) {
    assert(columns > 0);
    final result = List.generate(columns, (_) => <T>[]);
    for (var i = 0; i < items.length; i++) {
      result[i % columns].add(items[i]);
    }
    return result;
  }
}
