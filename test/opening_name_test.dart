import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:chess_stats_pwa/services/opening_name_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String name(String locale, String family) => lookupAppLocalizations(Locale(locale))
      .openingFamilyName(OpeningNameService.key(family), OpeningNameService.fallback(family));

  test('clé et nom de repli', () {
    expect(OpeningNameService.key('Sicilian-Defense'), 'SicilianDefense');
    expect(OpeningNameService.fallback('Kings-Fianchetto'), 'Kings Fianchetto');
  });

  test('noms en français et en anglais', () {
    expect(name('fr', 'Sicilian-Defense'), 'Défense sicilienne');
    expect(name('fr', 'Ruy-Lopez'), 'Partie espagnole');
    expect(name('en', 'Queens-Pawn'), "Queen's Pawn Game");
    expect(name('fr', 'Unknown-Opening'), 'Ouverture inconnue');
  });

  test('famille inconnue : nom anglais lisible', () {
    expect(name('fr', 'Kings-Fianchetto'), 'Kings Fianchetto');
  });
}
