import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'country_stats_service.dart';

class CountryNameService {
  /// Nom localisé d'un pays à partir de son code chess.com (ex. 'FR').
  /// Tous les codes ISO 3166-1 et les codes spéciaux chess.com (X…) sont
  /// traduits par la clé `countryName` des .arb ; repli : le code lui-même.
  static String getCountryName(BuildContext context, String code) {
    return countryName(AppLocalizations.of(context)!, code);
  }

  /// Comme [getCountryName], à partir des traductions déjà chargées.
  static String countryName(AppLocalizations l10n, String code) {
    if (code == CountryStatsService.unknownCountry) return l10n.countryUnknown;
    return l10n.countryName(code.toUpperCase());
  }

  /// Drapeaux des codes spéciaux chess.com qui en ont un : séquences emoji
  /// de l'Angleterre, de l'Écosse et du Pays de Galles, indicateurs du Kosovo
  /// et de la Palestine.
  static const Map<String, String> _specialFlags = {
    'XE': '\u{1F3F4}\u{E0067}\u{E0062}\u{E0065}\u{E006E}\u{E0067}\u{E007F}',
    'XS': '\u{1F3F4}\u{E0067}\u{E0062}\u{E0073}\u{E0063}\u{E0074}\u{E007F}',
    'XW': '\u{1F3F4}\u{E0067}\u{E0062}\u{E0077}\u{E006C}\u{E0073}\u{E007F}',
    'XK': '\u{1F1FD}\u{1F1F0}',
    'XP': '\u{1F1F5}\u{1F1F8}',
  };

  /// Drapeau emoji d'un code pays ISO à deux lettres. Les autres codes
  /// spéciaux de chess.com (International, Catalogne...) et les pays
  /// inconnus reçoivent un drapeau neutre.
  static String getFlag(String code) {
    final upper = code.toUpperCase();
    final special = _specialFlags[upper];
    if (special != null) return special;
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(upper) || upper.startsWith('X')) {
      return '\u{1F3F3}';
    }
    const base = 0x1F1E6 - 0x41; // indicateur régional A - 'A'
    return String.fromCharCodes(upper.codeUnits.map((c) => base + c));
  }
}
