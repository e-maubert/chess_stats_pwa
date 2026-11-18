import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:chess_stats_pwa/services/opening_name_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String name(String locale, String family) => lookupAppLocalizations(Locale(locale))
      .openingFamilyName(OpeningNameService.key(family), OpeningNameService.fallback(family));

  // Familles produites par la table des codes ECO (ChessApiService) : chacune
  // doit avoir sa traduction, sinon le nom anglais brut s'afficherait.
  const tableFamilies = [
    'Queens-Pawn', 'Queens-Gambit', 'Sicilian-Defense', 'Ruy-Lopez', 'English-Opening',
    'French-Defense', 'Dutch-Defense', 'Kings-Gambit', 'Caro-Kann', 'Vienna-Game',
    'Two-Knights', 'Giuoco-Piano', 'Alekhines-Defense', 'Reti-Opening', 'Pirc-Defense',
    'Kings-Pawn', 'Four-Knights', 'Petrov-Defense', 'Kings-Knights', 'Kings-Indian',
    'Center-Game', 'Bishops-Opening', 'Birds-Opening', 'Scotch-Game', 'Scandinavian-Defense',
    'Robatsch-Defense', 'Reti-Accepted', 'Philidor-Defense', 'Nimzowitsch-Larsen',
    'Anderssen-Opening', 'Unknown-Opening',
  ];

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

  // En anglais, la traduction peut être égale au nom de repli (« Sicilian
  // Defense ») : seul le français permet de voir s'il en manque une.
  test('toutes les familles de la table ECO sont traduites', () {
    for (final family in tableFamilies) {
      expect(name('fr', family), isNot(OpeningNameService.fallback(family)), reason: '$family non traduite');
    }
  });

  test('famille inconnue : nom anglais lisible', () {
    expect(name('fr', 'Kings-Fianchetto'), 'Kings Fianchetto');
  });
}
