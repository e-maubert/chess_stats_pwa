/// Prépare le nom d'une famille d'ouvertures (ex. 'Sicilian-Defense',
/// 'Queens-Pawn') pour sa traduction dans les .arb (`openingFamilyName`).
class OpeningNameService {
  /// Clé du message traduit : la famille sans tirets ni apostrophes
  /// (ex. 'SicilianDefense').
  static String key(String family) => family.replaceAll(RegExp(r"[^A-Za-z0-9]"), '');

  /// Nom affiché pour une famille absente des traductions : tirets
  /// remplacés par des espaces (ex. 'Kings-Fianchetto' => 'Kings Fianchetto').
  static String fallback(String family) => family.replaceAll('-', ' ');
}
