/// Famille d'ouvertures d'un code ECO (ex. 'B43' => 'Sicilian-Defense'),
/// d'après le découpage standard de l'Encyclopédie des ouvertures.
///
/// Les noms sont en anglais, mots séparés par des tirets, comme les adresses
/// des ouvertures de chess.com ; ils sont traduits à l'affichage
/// (`openingFamilyName` dans les .arb). Toute nouvelle famille doit y
/// avoir sa traduction.
class EcoService {
  static const String unknown = 'Unknown-Opening';

  /// Plages de codes (bornes incluses) et leur famille, dans l'ordre.
  static const List<(String from, String to, String family)> _ranges = [
    ('A00', 'A00', 'Uncommon-Opening'),
    ('A01', 'A01', 'Nimzowitsch-Larsen'),
    ('A02', 'A03', 'Birds-Opening'),
    ('A04', 'A06', 'Reti-Opening'),
    ('A07', 'A08', 'Kings-Indian-Attack'),
    ('A09', 'A09', 'Reti-Opening'),
    ('A10', 'A39', 'English-Opening'),
    ('A40', 'A41', 'Queens-Pawn'),
    ('A42', 'A42', 'Modern-Defense'),
    ('A43', 'A44', 'Benoni-Defense'),
    ('A45', 'A46', 'Indian-Game'),
    ('A47', 'A47', 'Queens-Indian'),
    ('A48', 'A50', 'Indian-Game'),
    ('A51', 'A52', 'Budapest-Gambit'),
    ('A53', 'A55', 'Old-Indian'),
    ('A56', 'A56', 'Benoni-Defense'),
    ('A57', 'A59', 'Benko-Gambit'),
    ('A60', 'A79', 'Benoni-Defense'),
    ('A80', 'A99', 'Dutch-Defense'),
    ('B00', 'B00', 'Kings-Pawn'),
    ('B01', 'B01', 'Scandinavian-Defense'),
    ('B02', 'B05', 'Alekhines-Defense'),
    ('B06', 'B06', 'Modern-Defense'),
    ('B07', 'B09', 'Pirc-Defense'),
    ('B10', 'B19', 'Caro-Kann'),
    ('B20', 'B99', 'Sicilian-Defense'),
    ('C00', 'C19', 'French-Defense'),
    ('C20', 'C20', 'Kings-Pawn'),
    ('C21', 'C22', 'Center-Game'),
    ('C23', 'C24', 'Bishops-Opening'),
    ('C25', 'C29', 'Vienna-Game'),
    ('C30', 'C39', 'Kings-Gambit'),
    ('C40', 'C40', 'Kings-Knight'),
    ('C41', 'C41', 'Philidor-Defense'),
    ('C42', 'C43', 'Petrov-Defense'),
    ('C44', 'C44', 'Kings-Pawn'),
    ('C45', 'C45', 'Scotch-Game'),
    ('C46', 'C46', 'Three-Knights'),
    ('C47', 'C49', 'Four-Knights'),
    ('C50', 'C50', 'Italian-Game'),
    ('C51', 'C52', 'Evans-Gambit'),
    ('C53', 'C54', 'Italian-Game'),
    ('C55', 'C59', 'Two-Knights'),
    ('C60', 'C99', 'Ruy-Lopez'),
    ('D00', 'D00', 'Queens-Pawn'),
    ('D01', 'D01', 'Veresov-Attack'),
    ('D02', 'D02', 'Queens-Pawn'),
    ('D03', 'D03', 'Torre-Attack'),
    ('D04', 'D05', 'Colle-System'),
    ('D06', 'D09', 'Queens-Gambit'),
    ('D10', 'D19', 'Slav-Defense'),
    ('D20', 'D42', 'Queens-Gambit'),
    ('D43', 'D49', 'Semi-Slav'),
    ('D50', 'D69', 'Queens-Gambit'),
    ('D70', 'D99', 'Grunfeld-Defense'),
    ('E00', 'E00', 'Queens-Pawn'),
    ('E01', 'E09', 'Catalan-Opening'),
    ('E10', 'E10', 'Indian-Game'),
    ('E11', 'E11', 'Bogo-Indian'),
    ('E12', 'E19', 'Queens-Indian'),
    ('E20', 'E59', 'Nimzo-Indian'),
    ('E60', 'E99', 'Kings-Indian'),
  ];

  static final RegExp _code = RegExp(r'^[A-E]\d{2}$');

  /// Famille du code ECO [code], [unknown] s'il n'est pas valide.
  static String familyOf(String code) {
    if (!_code.hasMatch(code)) return unknown;
    for (final (from, to, family) in _ranges) {
      if (code.compareTo(from) >= 0 && code.compareTo(to) <= 0) return family;
    }
    return unknown;
  }
}
