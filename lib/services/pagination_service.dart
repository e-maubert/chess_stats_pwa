/// Découpage d'une liste en pages (tableaux des ouvertures et des pays).
class PaginationService {
  /// Nombre de lignes par page.
  static const int pageSize = 10;

  /// Nombre de pages (au moins 1, même pour une liste vide).
  static int pageCount(int totalItems, {int size = pageSize}) => totalItems <= 0 ? 1 : (totalItems + size - 1) ~/ size;

  /// [page] (à partir de 0) ramené entre la première et la dernière page.
  static int clampPage(int page, int totalItems, {int size = pageSize}) =>
      page.clamp(0, pageCount(totalItems, size: size) - 1);

  /// Éléments de la page [page] (à partir de 0) ; dernière page si [page]
  /// dépasse.
  static List<T> pageItems<T>(List<T> items, int page, {int size = pageSize}) {
    final start = clampPage(page, items.length, size: size) * size;
    final end = (start + size).clamp(0, items.length);
    return items.sublist(start, end);
  }

  /// Rang (à partir de 1) du premier élément de la page [page].
  static int firstRank(int page, int totalItems, {int size = pageSize}) =>
      clampPage(page, totalItems, size: size) * size + 1;
}
