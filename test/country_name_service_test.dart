import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:chess_stats_pwa/services/country_name_service.dart';
import 'package:chess_stats_pwa/services/country_stats_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fr = lookupAppLocalizations(const Locale('fr'));
  final en = lookupAppLocalizations(const Locale('en'));
  String name(AppLocalizations l10n, String code) => CountryNameService.countryName(l10n, code);

  test('pays auparavant affichés en code brut', () {
    expect(name(fr, 'TR'), 'Turquie');
    expect(name(en, 'TR'), 'Turkey');
    expect(name(fr, 'ES'), 'Espagne');
    expect(name(fr, 'RU'), 'Russie');
    expect(name(fr, 'CI'), "Côte d'Ivoire");
  });

  test('pays déjà traduits avant : inchangés', () {
    expect(name(fr, 'FR'), 'France');
    expect(name(fr, 'US'), 'États-Unis');
    expect(name(en, 'GB'), 'United Kingdom');
  });

  test('code en minuscules accepté', () {
    expect(name(fr, 'tr'), 'Turquie');
  });

  test('codes spéciaux chess.com', () {
    expect(name(fr, 'XE'), 'Angleterre');
    expect(name(fr, 'XS'), 'Écosse');
    expect(name(fr, 'XW'), 'Pays de Galles');
    expect(name(fr, 'XX'), 'International');
    expect(name(en, 'XC'), 'Catalonia');
  });

  test('pays inconnu et code non répertorié', () {
    expect(name(fr, CountryStatsService.unknownCountry), 'Pays inconnu');
    expect(name(fr, 'QQ'), 'QQ');
  });

  test('drapeaux : ISO, codes spéciaux, neutre sinon', () {
    expect(CountryNameService.getFlag('TR'), '\u{1F1F9}\u{1F1F7}');
    expect(CountryNameService.getFlag('XE'), startsWith('\u{1F3F4}'));
    expect(CountryNameService.getFlag('XP'), CountryNameService.getFlag('PS'));
    expect(CountryNameService.getFlag('XX'), '\u{1F3F3}');
    expect(CountryNameService.getFlag('Unknown'), '\u{1F3F3}');
  });

  test('bulle de la carte : 0, 1 et plusieurs parties', () {
    // En français, 0 relève du singulier : sans cas « =0 », la bulle d'un
    // pays non joué affichait « 1 partie ».
    expect(fr.countryMapGames('France', 0), 'France : 0 partie');
    expect(fr.countryMapGames('France', 1), 'France : 1 partie');
    expect(fr.countryMapGames('France', 12), 'France : 12 parties');
    expect(en.countryMapGames('France', 0), 'France: 0 games');
    expect(en.countryMapGames('France', 1), 'France: 1 game');
    expect(fr.countryMapNotShownItem('International', 0), 'International (0 partie)');
  });
}
