import 'dart:ui';

/// Regroupement des marqueurs de la carte qui se chevauchent à l'écran,
/// comme sur les cartes en ligne : recalculé à chaque zoom, les groupes se
/// séparent quand on zoome.
class MarkerClusterService {
  /// Regroupe [positions] (positions à l'écran, dans l'ordre de priorité,
  /// le n°1 d'abord) dont les étiquettes de [size] se chevaucheraient.
  /// Chaque groupe est la liste des indices de ses marqueurs, du plus
  /// prioritaire au moins prioritaire ; un marqueur rejoint le premier
  /// groupe qui chevauche l'un de ses membres, et deux groupes reliés par
  /// ce nouveau membre fusionnent.
  static List<List<int>> cluster(List<Offset> positions, Size size) {
    bool overlap(Offset a, Offset b) => (a.dx - b.dx).abs() < size.width && (a.dy - b.dy).abs() < size.height;

    final groups = <List<int>>[];
    for (var i = 0; i < positions.length; i++) {
      final touching = [
        for (final group in groups)
          if (group.any((j) => overlap(positions[i], positions[j]))) group,
      ];
      if (touching.isEmpty) {
        groups.add([i]);
        continue;
      }
      final merged = [for (final group in touching) ...group, i]..sort();
      groups.removeWhere(touching.contains);
      groups.add(merged);
    }
    groups.sort((a, b) => a.first.compareTo(b.first));
    return groups;
  }

  /// Centre d'un groupe : moyenne des positions de ses marqueurs.
  static Offset center(List<Offset> positions, List<int> group) {
    var sum = Offset.zero;
    for (final i in group) {
      sum += positions[i];
    }
    return sum / group.length.toDouble();
  }
}
