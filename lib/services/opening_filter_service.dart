import '../models/country_game.dart';
import '../models/opening_family.dart';

/// Une famille d'ouvertures proposée dans le filtre, avec son nombre de
/// parties.
typedef OpeningOption = ({String family, int games});

/// Choix du filtre d'ouverture de l'en-tête.
///
/// Les ouvertures proposées sont celles jouées dans les parties retenues par
/// les autres filtres (période, cadence, couleur), de la plus jouée à la
/// moins jouée : les [topCount] premières, puis « Autres ouvertures » (le
/// regroupement de toutes les suivantes), puis ces suivantes une par une.
class OpeningFilterService {
  /// Valeur du filtre pour « Autres ouvertures ».
  static const String others = '#others';

  /// Nombre d'ouvertures proposées avant « Autres ouvertures ».
  static const int topCount = 5;

  /// Familles jouées dans [games] pour la cadence [timeClass] et la couleur
  /// [color] (null = toutes), de la plus jouée à la moins jouée (à égalité,
  /// par ordre alphabétique, pour un ordre stable).
  static List<OpeningOption> options(List<CountryGame> games, {String? timeClass, String? color}) {
    final counts = <String, int>{};
    for (final game in games) {
      if (timeClass != null && game.timeClass != timeClass) continue;
      if (color != null && game.playerColor != color) continue;
      final family = OpeningFamily.getFamilyName(game.opening);
      counts[family] = (counts[family] ?? 0) + 1;
    }
    final options = [for (final entry in counts.entries) (family: entry.key, games: entry.value)];
    options.sort((a, b) => b.games != a.games ? b.games.compareTo(a.games) : a.family.compareTo(b.family));
    return options;
  }

  /// Contenu du menu pour [options] (voir [options]) et le choix actuel
  /// [selected] : les [topCount] premières ([top]), le nombre de parties
  /// d'« Autres ouvertures » ([othersGames], null si ce choix n'est pas
  /// proposé), puis les suivantes ([rest]).
  ///
  /// Une ouverture choisie absente des parties (autres filtres changés
  /// depuis) reste proposée avec 0 partie, à la fin de [top] : le choix ne
  /// change pas tout seul.
  static ({List<OpeningOption> top, int? othersGames, List<OpeningOption> rest}) menu(
    List<OpeningOption> options,
    String? selected,
  ) {
    final top = options.take(topCount).toList();
    final rest = options.skip(topCount).toList();
    if (selected != null && selected != others && !options.any((option) => option.family == selected)) {
      top.add((family: selected, games: 0));
    }
    final showOthers = rest.isNotEmpty || selected == others;
    return (
      top: top,
      othersGames: showOthers ? rest.fold<int>(0, (sum, option) => sum + option.games) : null,
      rest: rest,
    );
  }

  /// Familles regroupées sous « Autres ouvertures » : toutes sauf les
  /// [topCount] plus jouées.
  static Set<String> otherFamilies(List<OpeningOption> options) =>
      {for (final option in options.skip(topCount)) option.family};

  /// Vrai si [game] correspond au choix [selection] (null = toutes ;
  /// [others] = hors des [topCount] plus jouées, d'après [otherFamilies]).
  static bool matches(CountryGame game, String? selection, Set<String> otherFamilies) {
    if (selection == null) return true;
    final family = OpeningFamily.getFamilyName(game.opening);
    if (selection == others) return otherFamilies.contains(family);
    return family == selection;
  }
}
