import '../models/country_game.dart';

/// Pays des adversaires, ajoutés aux parties après leur affichage : la page
/// des stats s'affiche sans les attendre, seule la carte des pays en a
/// besoin (voir PlayerGamesViewModel.countryGamesIn).
class OpponentCountryService {
  /// Adversaires (pseudos en minuscules) dont le pays manque : absent de la
  /// partie et de [known] (pseudo en minuscules → code pays).
  static Set<String> missingOpponents(Iterable<CountryGame> games, Map<String, String> known) => {
        for (final game in games)
          if (game.country == null && !known.containsKey(game.opponent.toLowerCase())) game.opponent.toLowerCase(),
      };

  /// [games] avec le pays de chaque adversaire, pris dans [known] quand la
  /// partie ne l'a pas ; null s'il en manque encore un.
  static List<CountryGame>? withCountries(List<CountryGame> games, Map<String, String> known) {
    final result = <CountryGame>[];
    for (final game in games) {
      if (game.country != null) {
        result.add(game);
        continue;
      }
      final country = known[game.opponent.toLowerCase()];
      if (country == null) return null;
      result.add(game.withCountry(country));
    }
    return result;
  }
}
