import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/country_game.dart';
import '../models/stats_period.dart';
import '../services/country_stats_service.dart';
import '../services/game_repository.dart';
import '../services/opponent_country_service.dart';
import '../services/player_country_service.dart';
import '../services/stats_period_service.dart';

/// Parties du joueur affiché : celles du stockage local d'abord (affichage
/// immédiat), puis mises à jour en arrière-plan. Les pays des adversaires
/// sont cherchés ensuite, seulement pour la carte des pays
/// ([countryGamesIn]).
class PlayerGamesViewModel extends ChangeNotifier {
  final GameRepository _repository;
  final PlayerCountryService _countryService;
  final String username;

  List<CountryGame>? _games;
  bool _updating = false;
  bool _updateFailed = false;
  bool _disposed = false;

  /// [initialGames] : parties déjà chargées par l'écran de recherche ;
  /// [upToDate] : elles viennent d'être téléchargées, inutile de les mettre
  /// à jour tout de suite.
  PlayerGamesViewModel(
    this._repository,
    this.username, {
    List<CountryGame>? initialGames,
    bool upToDate = false,
    PlayerCountryService? countryService,
  })  : _games = initialGames,
        _countryService = countryService ?? PlayerCountryService() {
    _open(upToDate);
  }

  /// null tant que rien n'est chargé.
  List<CountryGame>? get games => _games;
  bool get isUpdating => _updating;

  /// La dernière mise à jour a échoué (les parties affichées, s'il y en a,
  /// sont celles du stockage).
  bool get updateFailed => _updateFailed;

  /// Parties de la [period] (les N derniers jours), celles affichées. Même
  /// liste tant que les parties et la période ne changent pas : les cartes
  /// gardent leurs filtres (elles repartent de zéro quand la liste change).
  List<CountryGame> gamesIn(StatsPeriod period) {
    if (_displayedSource != _games || _displayedPeriod != period || _displayed == null) {
      _displayedSource = _games;
      _displayedPeriod = period;
      _displayed = StatsPeriodService.filter(_games ?? const [], period, _repository.now);
    }
    return _displayed!;
  }

  List<CountryGame>? _displayedSource;
  StatsPeriod? _displayedPeriod;
  List<CountryGame>? _displayed;

  /// Pays des adversaires déjà trouvés (pseudo en minuscules → code pays).
  final Map<String, String> _countries = {};
  int _countriesVersion = 0;
  bool _resolvingCountries = false;
  List<CountryGame> _countriesWanted = const [];

  List<CountryGame>? _countrySource;
  int? _countrySourceVersion;
  List<CountryGame>? _countryGames;

  /// Parties de la [period] avec le pays de chaque adversaire ; null tant
  /// qu'il en manque (la carte des pays affiche alors un indicateur de
  /// chargement). Lance la recherche des pays manquants, et seulement pour
  /// cette période : passer à « 3 mois » ne cherche que les nouveaux
  /// adversaires.
  List<CountryGame>? countryGamesIn(StatsPeriod period) {
    final games = gamesIn(period);
    if (!identical(_countrySource, games) || _countrySourceVersion != _countriesVersion) {
      _countrySource = games;
      _countrySourceVersion = _countriesVersion;
      _countryGames = OpponentCountryService.withCountries(games, _countries);
    }
    if (_countryGames == null) {
      _countriesWanted = games;
      // Pas de notification pendant la construction de l'écran.
      scheduleMicrotask(_resolveCountries);
    }
    return _countryGames;
  }

  /// Cherche les pays manquants des parties demandées en dernier, une
  /// recherche à la fois (si la période ou les parties changent entre-temps,
  /// la boucle reprend avec les nouvelles).
  Future<void> _resolveCountries() async {
    if (_resolvingCountries) return;
    _resolvingCountries = true;
    try {
      while (!_disposed) {
        final missing = OpponentCountryService.missingOpponents(_countriesWanted, _countries);
        if (missing.isEmpty) break;
        Map<String, String> found;
        try {
          found = await _countryService.countries(missing);
        } catch (error) {
          debugPrint('Pays des adversaires introuvables : $error');
          found = const {};
        }
        // Un pays non trouvé devient « inconnu » : jamais de boucle infinie.
        for (final name in missing) {
          _countries[name] = found[name] ?? CountryStatsService.unknownCountry;
        }
        _countriesVersion++;
        _notify();
      }
    } finally {
      _resolvingCountries = false;
    }
  }

  Future<void> _open(bool upToDate) async {
    await _repository.markViewed(username);
    if (_games == null) {
      _games = await _repository.storedGames(username);
      _notify();
    }
    if (!upToDate) await update();
  }

  /// Télécharge les mois pas encore clos et met l'affichage à jour.
  Future<void> update() async {
    _updating = true;
    _updateFailed = false;
    _notify();
    try {
      _games = await _repository.updateGames(username);
    } catch (error) {
      debugPrint('Mise à jour impossible : $error');
      _updateFailed = true;
    } finally {
      _updating = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
