import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:chess_stats_pwa/models/opening_family.dart';
import 'package:chess_stats_pwa/services/eco_service.dart';
import 'package:chess_stats_pwa/services/opening_name_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('familles ECO : plus de « pion dame » pour les défenses indiennes', () {
    expect(EcoService.familyOf('B43'), 'Sicilian-Defense');
    expect(EcoService.familyOf('C65'), 'Ruy-Lopez');
    expect(EcoService.familyOf('E32'), 'Nimzo-Indian');
    expect(EcoService.familyOf('E97'), 'Kings-Indian');
    expect(EcoService.familyOf('D85'), 'Grunfeld-Defense');
    expect(EcoService.familyOf('A45'), 'Indian-Game');
    expect(EcoService.familyOf('D15'), 'Slav-Defense');
    expect(EcoService.familyOf('A07'), 'Kings-Indian-Attack');
    expect(EcoService.familyOf('D02'), 'Queens-Pawn');
    // Bornes des plages.
    expect(EcoService.familyOf('B19'), 'Caro-Kann');
    expect(EcoService.familyOf('B20'), 'Sicilian-Defense');
    expect(EcoService.familyOf('E99'), 'Kings-Indian');
  });

  test('code invalide : ouverture inconnue', () {
    expect(EcoService.familyOf('F00'), EcoService.unknown);
    expect(EcoService.familyOf(''), EcoService.unknown);
  });

  test('chaque code A00 à E99 a une famille traduite en français', () {
    final fr = lookupAppLocalizations(const Locale('fr'));
    for (final letter in ['A', 'B', 'C', 'D', 'E']) {
      for (var n = 0; n < 100; n++) {
        final code = '$letter${n.toString().padLeft(2, '0')}';
        final family = EcoService.familyOf(code);
        expect(family, isNot(EcoService.unknown), reason: code);
        expect(OpeningFamily.getFamilyName(family), family, reason: '$code : famille tronquée');
        expect(
          fr.openingFamilyName(OpeningNameService.key(family), OpeningNameService.fallback(family)),
          isNot(OpeningNameService.fallback(family)),
          reason: '$family ($code) non traduite',
        );
      }
    }
  });

  test("l'attaque indienne du roi reste distincte de l'indienne du roi", () {
    expect(OpeningFamily.getFamilyName('Kings-Indian-Attack-Double-Fianchetto'), 'Kings-Indian-Attack');
    expect(OpeningFamily.getFamilyName('Kings-Indian-Defense-Normal'), 'Kings-Indian');
  });
}
