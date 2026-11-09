// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Chess Stats PWA';

  @override
  String get enterUsername => 'Entrez le nom d\'utilisateur Chess.com';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get search => 'Rechercher';

  @override
  String get pleaseEnterUsername => 'Veuillez entrer un nom d\'utilisateur';

  @override
  String playerStats(String username) {
    return 'Statistiques de $username';
  }

  @override
  String get refresh => 'Rafraîchir';

  @override
  String get forceRefresh => 'Forcer le rafraîchissement';

  @override
  String get retry => 'Réessayer';

  @override
  String errorLoadingStats(String error) {
    return 'Erreur lors du chargement des statistiques: $error';
  }

  @override
  String errorForceRefresh(String error) {
    return 'Erreur lors du rafraîchissement forcé: $error';
  }

  @override
  String get globalStats => 'Statistiques globales';

  @override
  String get gamesPlayed => 'Parties jouées';

  @override
  String get wins => 'Victoires';

  @override
  String get losses => 'Défaites';

  @override
  String get draws => 'Matchs nuls';

  @override
  String get winRate => 'Taux de victoire';

  @override
  String get colorStats => 'Statistiques par couleur';

  @override
  String get withWhite => 'Avec les blancs';

  @override
  String get withBlack => 'Avec les noirs';

  @override
  String get topOpenings => 'Top 5 des ouvertures';

  @override
  String get countryStats => 'Statistiques par pays';

  @override
  String played(int count) {
    return 'Parties jouées: $count';
  }

  @override
  String winRatePercent(double rate) {
    final intl.NumberFormat rateNumberFormat =
        intl.NumberFormat.decimalPercentPattern(
            locale: localeName, decimalDigits: 1);
    final String rateString = rateNumberFormat.format(rate);

    return '$rateString%';
  }

  @override
  String winCount(int wins, double rate) {
    final intl.NumberFormat rateNumberFormat =
        intl.NumberFormat.decimalPercentPattern(
            locale: localeName, decimalDigits: 1);
    final String rateString = rateNumberFormat.format(rate);

    return '$wins ($rateString%)';
  }

  @override
  String lossCount(int losses, double rate) {
    final intl.NumberFormat rateNumberFormat =
        intl.NumberFormat.decimalPercentPattern(
            locale: localeName, decimalDigits: 1);
    final String rateString = rateNumberFormat.format(rate);

    return '$losses ($rateString%)';
  }

  @override
  String drawCount(int draws, double rate) {
    final intl.NumberFormat rateNumberFormat =
        intl.NumberFormat.decimalPercentPattern(
            locale: localeName, decimalDigits: 1);
    final String rateString = rateNumberFormat.format(rate);

    return '$draws ($rateString%)';
  }

  @override
  String get countryStatsLink =>
      'Voir les statistiques par pays des adversaires';

  @override
  String get countryStatsPeriod => 'Parties du mois en cours';

  @override
  String get countryRankColumn => '#';

  @override
  String get countryColumn => 'Pays';

  @override
  String get opponentsColumn => 'Adversaires';

  @override
  String get timeClassAll => 'Toutes les parties';

  @override
  String get timeClassBullet => 'Bullet';

  @override
  String get timeClassBlitz => 'Blitz';

  @override
  String get timeClassRapid => 'Rapide';

  @override
  String get noCountryData => 'Aucune partie pour cette cadence';

  @override
  String get openingOthers => 'Autres';

  @override
  String countryResultRates(String win, String draw, String loss) {
    return 'V $win · N $draw · D $loss';
  }

  @override
  String get lossBreakdown => 'Répartition des défaites';

  @override
  String get lossByTimeout => 'Au temps';

  @override
  String get lossByCheckmate => 'Par mat';

  @override
  String get lossByResignation => 'Par abandon';

  @override
  String get lossOther => 'Autre';

  @override
  String get noLossData => 'Aucune défaite pour cette cadence';

  @override
  String lossCauseValue(int count, String percent) {
    return '$count ($percent)';
  }

  @override
  String get countryUnknown => 'Pays inconnu';

  @override
  String get countryKZ => 'Kazakhstan';

  @override
  String get countryUS => 'États-Unis';

  @override
  String get countryFR => 'France';

  @override
  String get countryBR => 'Brésil';

  @override
  String get countryDE => 'Allemagne';

  @override
  String get countryIN => 'Inde';

  @override
  String get countryAR => 'Argentine';

  @override
  String get countryCO => 'Colombie';

  @override
  String get countryDZ => 'Algérie';

  @override
  String get countryID => 'Indonésie';

  @override
  String get countryUZ => 'Ouzbékistan';

  @override
  String get countryJO => 'Jordanie';

  @override
  String get countryEG => 'Égypte';

  @override
  String get countryMD => 'Moldova';

  @override
  String get countryTN => 'Tunisie';

  @override
  String get countryNP => 'Népal';

  @override
  String get countryGB => 'Royaume-Uni';

  @override
  String get countryCH => 'Suisse';

  @override
  String get countryDK => 'Danemark';

  @override
  String get countryMX => 'Mexique';

  @override
  String get countryBE => 'Belgique';

  @override
  String get countrySY => 'Syrie';

  @override
  String get countrySA => 'Arabie Saoudite';

  @override
  String get countryHR => 'Croatie';

  @override
  String get countrySZ => 'Eswatini';

  @override
  String get countryPT => 'Portugal';

  @override
  String get countryXW => 'Pays de Galles';

  @override
  String get countryPH => 'Philippines';

  @override
  String get countryUA => 'Ukraine';

  @override
  String get countryPL => 'Pologne';

  @override
  String get countryPE => 'Pérou';

  @override
  String get countryXX => 'International';

  @override
  String get countryNL => 'Pays-Bas';

  @override
  String get countryTH => 'Thaïlande';
}
