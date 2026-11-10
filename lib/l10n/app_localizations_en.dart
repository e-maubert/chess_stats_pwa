// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Chess Stats';

  @override
  String get enterUsername => 'Enter your Chess.com username';

  @override
  String get search => 'Search';

  @override
  String get refresh => 'Refresh';

  @override
  String get retry => 'Retry';

  @override
  String get errorFetchingStats => 'Error fetching statistics';

  @override
  String get playedOpenings => 'Played openings';

  @override
  String get gamesPlayed => 'Games Played';

  @override
  String get wins => 'Wins';

  @override
  String get losses => 'Losses';

  @override
  String get draws => 'Draws';

  @override
  String get colorStats => 'Statistics by Color';

  @override
  String get withWhite => 'With White';

  @override
  String get withBlack => 'With Black';

  @override
  String get countryStats => 'Statistics by Country';

  @override
  String played(int count) {
    return 'Games Played: $count';
  }

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
  String get openingColumn => 'Opening';

  @override
  String get ratingEvolution => 'Rating progress';

  @override
  String get ratingCurrent => 'Current rating';

  @override
  String get ratingSinceMonthStart => 'since the first game of the month';

  @override
  String get noRatingData => 'No rated games for this time control';

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
  String get timeManagement => 'Time management in losses';

  @override
  String get timeGapAverage =>
      'When you lose, this is your average clock gap with the opponent at the end of the game:';

  @override
  String get timeBehind => 'Behind on the clock';

  @override
  String get timeBalanced => 'Even on the clock';

  @override
  String get timeAhead => 'Ahead on the clock';

  @override
  String get timeThresholdNote =>
      'Significant gap: more than 10% of the initial time';

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
