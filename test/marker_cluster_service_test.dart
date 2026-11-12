import 'dart:ui';

import 'package:chess_stats_pwa/services/marker_cluster_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const size = Size(60, 34);

  test('marqueurs éloignés : un groupe chacun, dans l\'ordre', () {
    final groups = MarkerClusterService.cluster(const [Offset(0, 0), Offset(200, 0), Offset(0, 200)], size);
    expect(groups, [
      [0],
      [1],
      [2],
    ]);
  });

  test('marqueurs qui se chevauchent : regroupés', () {
    // Royaume-Uni, France, Pologne : proches ; Brésil : loin.
    final groups = MarkerClusterService.cluster(
      const [Offset(100, 50), Offset(110, 70), Offset(300, 300), Offset(150, 60)],
      size,
    );
    expect(groups, [
      [0, 1, 3],
      [2],
    ]);
  });

  test('un marqueur qui relie deux groupes les fusionne', () {
    final groups = MarkerClusterService.cluster(const [Offset(0, 0), Offset(100, 0), Offset(50, 0)], size);
    expect(groups, [
      [0, 1, 2],
    ]);
  });

  test('assez loin en hauteur ou en largeur : pas de regroupement', () {
    expect(MarkerClusterService.cluster(const [Offset(0, 0), Offset(0, 34)], size).length, 2);
    expect(MarkerClusterService.cluster(const [Offset(0, 0), Offset(60, 0)], size).length, 2);
    expect(MarkerClusterService.cluster(const [Offset(0, 0), Offset(59, 33)], size).length, 1);
  });

  test('centre d\'un groupe', () {
    const positions = [Offset(0, 0), Offset(100, 40), Offset(20, 20)];
    expect(MarkerClusterService.center(positions, [0, 2]), const Offset(10, 10));
  });
}
