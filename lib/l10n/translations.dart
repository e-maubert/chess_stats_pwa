import 'package:flutter/foundation.dart';

class Translations extends ChangeNotifier {
  static final Translations _instance = Translations._internal();
  factory Translations() => _instance;
  Translations._internal();

  String _locale = 'fr'; // Pour l'instant, on utilise uniquement le français

  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Chess Stats',
      'enterUsername': 'Enter your Chess.com username',
      'search': 'Search',
      'error': 'Error',
      'errorFetchingStats': 'Error fetching statistics',
      'retry': 'Retry',
      'refresh': 'Refresh',
      'colorStats': 'Color Statistics',
      'whiteStats': 'With White',
      'blackStats': 'With Black',
      'wins': 'Wins',
      'losses': 'Losses',
      'draws': 'Draws',
      'winRate': 'Win Rate',
      'totalGames': 'Total Games',
      'playedOpenings': 'Played Openings',
    },
    'fr': {
      'appTitle': 'Statistiques d\'échecs',
      'enterUsername': 'Entrez votre nom d\'utilisateur Chess.com',
      'search': 'Rechercher',
      'error': 'Erreur',
      'errorFetchingStats': 'Erreur lors de la récupération des statistiques',
      'retry': 'Réessayer',
      'refresh': 'Actualiser',
      'colorStats': 'Statistiques par couleur',
      'whiteStats': 'Avec les blancs',
      'blackStats': 'Avec les noirs',
      'wins': 'Victoires',
      'losses': 'Défaites',
      'draws': 'Matchs nuls',
      'winRate': 'Taux de victoire',
      'totalGames': 'Parties jouées',
      'playedOpenings': 'Ouvertures jouées',
    },
  };

  /// Langue courante de l'app, partagée avec MaterialApp (localisation .arb).
  String get locale => _locale;

  String get appTitle => _getLocalizedValue('appTitle');
  String get enterUsername => _getLocalizedValue('enterUsername');
  String get search => _getLocalizedValue('search');
  String get error => _getLocalizedValue('error');
  String get errorFetchingStats => _getLocalizedValue('errorFetchingStats');
  String get retry => _getLocalizedValue('retry');
  String get refresh => _getLocalizedValue('refresh');
  String get colorStats => _getLocalizedValue('colorStats');
  String get whiteStats => _getLocalizedValue('whiteStats');
  String get blackStats => _getLocalizedValue('blackStats');
  String get wins => _getLocalizedValue('wins');
  String get losses => _getLocalizedValue('losses');
  String get draws => _getLocalizedValue('draws');
  String get winRate => _getLocalizedValue('winRate');
  String get totalGames => _getLocalizedValue('totalGames');
  String get playedOpenings => _getLocalizedValue('playedOpenings');

  String _getLocalizedValue(String key) {
    return _localizedValues[_locale]?[key] ?? key;
  }

  void setLocale(String locale) {
    if (_locale != locale && _localizedValues.containsKey(locale)) {
      _locale = locale;
      notifyListeners();
    }
  }

  String getCountryName(String code) {
    final key = 'country${code.toUpperCase()}';
    return _localizedValues[_locale]?[key] ?? code.toUpperCase();
  }

  String formatWinRate(double rate) {
    return '${(rate * 100).toStringAsFixed(1)}%';
  }

  String formatWinCount(int wins, double rate) {
    return '$wins (${formatWinRate(rate)})';
  }

  String formatPlayed(int count) {
    return '$totalGames: $count';
  }
} 