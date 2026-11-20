import 'package:chess_stats_pwa/viewmodels/collapsible_header.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  bool next(bool visible, double scrollDelta, double pixels) =>
      CollapsibleHeader.visibleAfterScroll(visible: visible, scrollDelta: scrollDelta, pixels: pixels);

  test('défilement vers le bas : filtres cachés', () {
    expect(next(true, 30, 120), isFalse);
  });

  test('remontée : filtres réaffichés', () {
    expect(next(false, -10, 800), isTrue);
  });

  test('en haut de la page : toujours affichés', () {
    expect(next(false, 30, 0), isTrue);
    expect(next(false, -5, -20), isTrue);
  });

  test('sans déplacement : état inchangé', () {
    expect(next(false, 0, 500), isFalse);
    expect(next(true, 0, 500), isTrue);
  });
}
