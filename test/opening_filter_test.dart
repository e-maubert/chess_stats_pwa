import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/services/opening_filter_service.dart';
import 'package:chess_stats_pwa/viewmodels/color_stats_viewmodel.dart';
import 'package:chess_stats_pwa/viewmodels/rating_history_viewmodel.dart';
import 'package:chess_stats_pwa/viewmodels/stats_filter_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

CountryGame g(String opening, {String color = 'white', String timeClass = 'blitz', int? rating, int day = 1}) =>
    CountryGame(
      country: 'FR',
      opponent: 'x',
      timeClass: timeClass,
      result: 'win',
      playerColor: color,
      opening: opening,
      rating: rating,
      endTime: DateTime(2026, 11, day),
    );

List<CountryGame> many(String opening, int count, {String color = 'white'}) =>
    [for (var i = 0; i < count; i++) g(opening, color: color)];

void main() {
  // 7 familles : Sicilienne 6, Française 5, Espagnole 4, Anglaise 3,
  // Italienne 2, puis Caro-Kann 1 et Scandinave 1 (« Autres »).
  final games = [
    ...many('Sicilian-Defense-Najdorf', 6),
    ...many('French-Defense', 5),
    ...many('Ruy-Lopez', 4),
    ...many('English-Opening', 3),
    ...many('Italian-Game', 2),
    g('Caro-Kann'),
    g('Scandinavian-Defense'),
    g('Pirc-Defense', color: 'black', timeClass: 'bullet'),
  ];

  test('options : familles jouées avec les autres filtres, de la plus jouée à la moins jouée', () {
    final options = OpeningFilterService.options(games, timeClass: 'blitz', color: 'white');
    expect(options.first, (family: 'Sicilian-Defense', games: 6));
    expect(options.map((o) => o.family), isNot(contains('Pirc-Defense')));
    // À égalité : ordre alphabétique.
    expect(options.skip(5).map((o) => o.family), ['Caro-Kann', 'Scandinavian-Defense']);
    expect(OpeningFilterService.options(games, color: 'black').single.family, 'Pirc-Defense');
  });

  test('menu : 5 premières, « Autres » (total des suivantes), puis les suivantes', () {
    final menu = OpeningFilterService.menu(OpeningFilterService.options(games, timeClass: 'blitz'), null);
    expect(menu.top.length, 5);
    expect(menu.othersGames, 2);
    expect(menu.rest.map((o) => o.family), ['Caro-Kann', 'Scandinavian-Defense']);
  });

  test('menu : moins de 6 familles, pas d\'« Autres »', () {
    final menu = OpeningFilterService.menu(OpeningFilterService.options(games, color: 'black'), null);
    expect(menu.othersGames, isNull);
    expect(menu.rest, isEmpty);
  });

  test('menu : une ouverture choisie sans partie reste proposée avec 0', () {
    final options = OpeningFilterService.options(games, color: 'black');
    final menu = OpeningFilterService.menu(options, 'Sicilian-Defense');
    expect(menu.top.last, (family: 'Sicilian-Defense', games: 0));
    expect(OpeningFilterService.menu(options, OpeningFilterService.others).othersGames, 0);
  });

  test('les cartes suivent le filtre : une famille, ou « Autres »', () {
    final opening = OpeningFilterViewModel();
    final viewModel = ColorStatsViewModel(games, openingFilter: opening);
    var notified = 0;
    viewModel.addListener(() => notified++);

    opening.select('French-Defense');
    expect(viewModel.rows.first.stats.totalGames, 5);
    opening.select(OpeningFilterService.others);
    // Caro-Kann + Scandinave (blitz) ; la Pirc (bullet, noirs) est hors des 5
    // premières aussi : « Autres » toutes cadences = 3.
    expect(viewModel.rows.first.stats.totalGames, 3);
    // Ouverture jamais jouée : tout à zéro.
    opening.select('Dutch-Defense');
    expect(viewModel.rows.first.stats.totalGames, 0);
    expect(notified, 3);
  });

  test('Elo : une ouverture choisie passe en tendance sur ses parties', () {
    final rated = [
      g('Sicilian-Defense', rating: 1500, day: 1),
      g('French-Defense', rating: 1520, day: 2), // +20 (française)
      g('Sicilian-Defense', rating: 1510, day: 3), // -10 (sicilienne)
      g('Sicilian-Defense', rating: 1530, day: 4), // +20 (sicilienne)
    ];
    final opening = OpeningFilterViewModel();
    final viewModel = RatingHistoryViewModel(rated, openingFilter: opening);
    expect(viewModel.showsTrend, isFalse);

    opening.select('Sicilian-Defense');
    expect(viewModel.showsTrend, isTrue);
    expect(viewModel.trends.single.points, 10);
    expect(viewModel.trends.single.games, 2);
  });
}
