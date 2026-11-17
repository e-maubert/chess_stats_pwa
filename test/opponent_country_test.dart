import 'package:chess_stats_pwa/models/country_game.dart';
import 'package:chess_stats_pwa/models/stats_period.dart';
import 'package:chess_stats_pwa/models/year_month.dart';
import 'package:chess_stats_pwa/services/country_stats_service.dart';
import 'package:chess_stats_pwa/services/game_repository.dart';
import 'package:chess_stats_pwa/services/game_store.dart';
import 'package:chess_stats_pwa/services/monthly_games_source.dart';
import 'package:chess_stats_pwa/services/opponent_country_service.dart';
import 'package:chess_stats_pwa/services/player_country_service.dart';
import 'package:chess_stats_pwa/viewmodels/player_games_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

CountryGame _game(String opponent, DateTime end, {String? country}) => CountryGame(
      country: country,
      opponent: opponent,
      timeClass: 'blitz',
      result: 'win',
      playerColor: 'white',
      opening: 'Sicilian-Defense',
      endTime: end,
      url: 'https://chess.com/game/$opponent/${end.millisecondsSinceEpoch}',
    );

class _NoSource implements MonthlyGamesSource {
  @override
  Future<Map<YearMonth, List<CountryGame>>> fetchMonths(String username, List<YearMonth> months) async =>
      {for (final month in months) month: const <CountryGame>[]};
}

/// Pays connus d'avance ; note chaque demande.
class _FakeCountries extends PlayerCountryService {
  final Map<String, String> known;
  final List<Set<String>> requests = [];
  bool fail = false;

  _FakeCountries(this.known);

  @override
  Future<Map<String, String>> countries(Iterable<String> usernames) async {
    final wanted = usernames.toSet();
    requests.add(wanted);
    if (fail) throw Exception('hors ligne');
    return {for (final name in wanted) name: known[name] ?? CountryStatsService.unknownCountry};
  }
}

void main() {
  final now = DateTime.utc(2026, 11, 17, 12);
  final recent = DateTime.utc(2026, 11, 10);
  final older = DateTime.utc(2026, 9, 10);

  group('OpponentCountryService', () {
    test('adversaires sans pays, en minuscules, sans doublon', () {
      final games = [
        _game('Bob', recent),
        _game('bob', recent),
        _game('Carol', recent, country: 'DE'),
        _game('dave', recent),
      ];
      expect(OpponentCountryService.missingOpponents(games, {'dave': 'US'}), {'bob'});
    });

    test('ajoute les pays connus, null s\'il en manque un', () {
      final games = [_game('Bob', recent), _game('carol', recent, country: 'DE')];
      expect(OpponentCountryService.withCountries(games, const {}), isNull);
      final withCountries = OpponentCountryService.withCountries(games, {'bob': 'FR'})!;
      expect([for (final game in withCountries) game.country], ['FR', 'DE']);
      expect(withCountries.first.opponent, 'Bob');
    });
  });

  group('PlayerGamesViewModel.countryGamesIn', () {
    GameRepository repository() => GameRepository(
          store: GameStore(newDatabaseFactoryMemory()),
          source: _NoSource(),
          now: () => now,
        );

    test('null pendant la recherche, puis les parties avec leur pays', () async {
      final countries = _FakeCountries({'bob': 'FR'});
      final viewModel = PlayerGamesViewModel(
        repository(),
        'alice',
        initialGames: [_game('Bob', recent), _game('carol', older)],
        upToDate: true,
        countryService: countries,
      );

      // Les autres stats sont disponibles tout de suite.
      expect(viewModel.gamesIn(StatsPeriod.oneMonth), hasLength(1));
      expect(viewModel.countryGamesIn(StatsPeriod.oneMonth), isNull);
      await pumpEventQueue();

      // Seuls les adversaires de la période affichée ont été demandés.
      expect(countries.requests, [
        {'bob'},
      ]);
      final games = viewModel.countryGamesIn(StatsPeriod.oneMonth)!;
      expect(games.single.country, 'FR');
      expect(identical(viewModel.countryGamesIn(StatsPeriod.oneMonth), games), isTrue);

      // Passer à 3 mois ne demande que le nouvel adversaire.
      expect(viewModel.countryGamesIn(StatsPeriod.threeMonths), isNull);
      await pumpEventQueue();
      expect(countries.requests.last, {'carol'});
      expect(
        [for (final game in viewModel.countryGamesIn(StatsPeriod.threeMonths)!) game.country],
        ['FR', CountryStatsService.unknownCountry],
      );
    });

    test('pays déjà stockés : pas de recherche', () async {
      final countries = _FakeCountries(const {});
      final viewModel = PlayerGamesViewModel(
        repository(),
        'alice',
        initialGames: [_game('bob', recent, country: 'FR')],
        upToDate: true,
        countryService: countries,
      );
      expect(viewModel.countryGamesIn(StatsPeriod.oneMonth)!.single.country, 'FR');
      await pumpEventQueue();
      expect(countries.requests, isEmpty);
    });

    test('échec de la recherche : pays inconnu plutôt qu\'un chargement sans fin', () async {
      final countries = _FakeCountries(const {})..fail = true;
      final viewModel = PlayerGamesViewModel(
        repository(),
        'alice',
        initialGames: [_game('bob', recent)],
        upToDate: true,
        countryService: countries,
      );
      expect(viewModel.countryGamesIn(StatsPeriod.oneMonth), isNull);
      await pumpEventQueue();
      expect(viewModel.countryGamesIn(StatsPeriod.oneMonth)!.single.country, CountryStatsService.unknownCountry);
    });
  });
}
