import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'country_stats_service.dart';

class CountryNameService {
  /// Nom localisé d'un pays à partir de son code chess.com (ex. 'FR').
  /// Repli : le code lui-même si aucune traduction n'existe.
  static String getCountryName(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context)!;
    if (code == CountryStatsService.unknownCountry) return l10n.countryUnknown;

    switch (code.toUpperCase()) {
      case 'KZ':
        return l10n.countryKZ;
      case 'US':
        return l10n.countryUS;
      case 'FR':
        return l10n.countryFR;
      case 'BR':
        return l10n.countryBR;
      case 'DE':
        return l10n.countryDE;
      case 'IN':
        return l10n.countryIN;
      case 'AR':
        return l10n.countryAR;
      case 'CO':
        return l10n.countryCO;
      case 'DZ':
        return l10n.countryDZ;
      case 'ID':
        return l10n.countryID;
      case 'UZ':
        return l10n.countryUZ;
      case 'JO':
        return l10n.countryJO;
      case 'EG':
        return l10n.countryEG;
      case 'MD':
        return l10n.countryMD;
      case 'TN':
        return l10n.countryTN;
      case 'NP':
        return l10n.countryNP;
      case 'GB':
        return l10n.countryGB;
      case 'CH':
        return l10n.countryCH;
      case 'DK':
        return l10n.countryDK;
      case 'MX':
        return l10n.countryMX;
      case 'BE':
        return l10n.countryBE;
      case 'SY':
        return l10n.countrySY;
      case 'SA':
        return l10n.countrySA;
      case 'HR':
        return l10n.countryHR;
      case 'SZ':
        return l10n.countrySZ;
      case 'PT':
        return l10n.countryPT;
      case 'XW':
        return l10n.countryXW;
      case 'PH':
        return l10n.countryPH;
      case 'UA':
        return l10n.countryUA;
      case 'PL':
        return l10n.countryPL;
      case 'PE':
        return l10n.countryPE;
      case 'XX':
        return l10n.countryXX;
      case 'NL':
        return l10n.countryNL;
      case 'TH':
        return l10n.countryTH;
      default:
        return code.toUpperCase();
    }
  }

  /// Drapeau emoji d'un code pays ISO à deux lettres. Les codes spéciaux de
  /// chess.com (commençant par X : International, Pays de Galles...) et les
  /// pays inconnus reçoivent un drapeau neutre.
  static String getFlag(String code) {
    final upper = code.toUpperCase();
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(upper) || upper.startsWith('X')) {
      return '\u{1F3F3}';
    }
    const base = 0x1F1E6 - 0x41; // indicateur régional A - 'A'
    return String.fromCharCodes(upper.codeUnits.map((c) => base + c));
  }
}
