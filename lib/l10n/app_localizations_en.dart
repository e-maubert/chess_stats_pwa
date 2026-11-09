// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Chess Stats PWA';

  @override
  String get enterUsername => 'Enter Chess.com username';

  @override
  String get username => 'Username';

  @override
  String get search => 'Search';

  @override
  String get pleaseEnterUsername => 'Please enter a username';

  @override
  String playerStats(String username) {
    return 'Statistics for $username';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get forceRefresh => 'Force refresh';

  @override
  String get retry => 'Retry';

  @override
  String errorLoadingStats(String error) {
    return 'Error loading statistics: $error';
  }

  @override
  String errorForceRefresh(String error) {
    return 'Error during force refresh: $error';
  }

  @override
  String get globalStats => 'Global Statistics';

  @override
  String get gamesPlayed => 'Games Played';

  @override
  String get wins => 'Wins';

  @override
  String get losses => 'Losses';

  @override
  String get draws => 'Draws';

  @override
  String get winRate => 'Win Rate';

  @override
  String get colorStats => 'Statistics by Color';

  @override
  String get withWhite => 'With White';

  @override
  String get withBlack => 'With Black';

  @override
  String get topOpenings => 'Top 5 Openings';

  @override
  String get countryStats => 'Statistics by Country';

  @override
  String played(int count) {
    return 'Games Played: $count';
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
  String get countryStatsLink => 'See statistics by opponent country';

  @override
  String get countryStatsPeriod => 'Games of the current month';

  @override
  String get countryRankColumn => '#';

  @override
  String get countryColumn => 'Country';

  @override
  String get opponentsColumn => 'Opponents';

  @override
  String get timeClassAll => 'All games';

  @override
  String get timeClassBullet => 'Bullet';

  @override
  String get timeClassBlitz => 'Blitz';

  @override
  String get timeClassRapid => 'Rapid';

  @override
  String get noCountryData => 'No games for this time control';

  @override
  String countryResultRates(String win, String draw, String loss) {
    return 'W $win · D $draw · L $loss';
  }

  @override
  String get lossBreakdown => 'Losses by type';

  @override
  String get lossByTimeout => 'On time';

  @override
  String get lossByCheckmate => 'By checkmate';

  @override
  String get lossByResignation => 'By resignation';

  @override
  String get lossOther => 'Other';

  @override
  String get noLossData => 'No losses for this time control';

  @override
  String lossCauseValue(int count, String percent) {
    return '$count ($percent)';
  }

  @override
  String get countryUnknown => 'Unknown country';

  @override
  String get countryKZ => 'Kazakhstan';

  @override
  String get countryUS => 'United States';

  @override
  String get countryFR => 'France';

  @override
  String get countryBR => 'Brazil';

  @override
  String get countryDE => 'Germany';

  @override
  String get countryIN => 'India';

  @override
  String get countryAR => 'Argentina';

  @override
  String get countryCO => 'Colombia';

  @override
  String get countryDZ => 'Algeria';

  @override
  String get countryID => 'Indonesia';

  @override
  String get countryUZ => 'Uzbekistan';

  @override
  String get countryJO => 'Jordan';

  @override
  String get countryEG => 'Egypt';

  @override
  String get countryMD => 'Moldova';

  @override
  String get countryTN => 'Tunisia';

  @override
  String get countryNP => 'Nepal';

  @override
  String get countryGB => 'United Kingdom';

  @override
  String get countryCH => 'Switzerland';

  @override
  String get countryDK => 'Denmark';

  @override
  String get countryMX => 'Mexico';

  @override
  String get countryBE => 'Belgium';

  @override
  String get countrySY => 'Syria';

  @override
  String get countrySA => 'Saudi Arabia';

  @override
  String get countryHR => 'Croatia';

  @override
  String get countrySZ => 'Eswatini';

  @override
  String get countryPT => 'Portugal';

  @override
  String get countryXW => 'Wales';

  @override
  String get countryPH => 'Philippines';

  @override
  String get countryUA => 'Ukraine';

  @override
  String get countryPL => 'Poland';

  @override
  String get countryPE => 'Peru';

  @override
  String get countryXX => 'International';

  @override
  String get countryNL => 'Netherlands';

  @override
  String get countryTH => 'Thailand';
}
