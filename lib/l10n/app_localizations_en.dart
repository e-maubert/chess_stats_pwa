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
  String get appLogo => 'Chess Stats logo';

  @override
  String statsTitle(String username) {
    return 'Chess Stats: $username';
  }

  @override
  String get enterUsername => 'Enter your Chess.com username';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'e.g. Hikaru';

  @override
  String removeRecentPlayer(String username) {
    return 'Remove $username from the list';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get retry => 'Retry';

  @override
  String get periodOneMonth => '1 month';

  @override
  String get periodThreeMonths => '3 months';

  @override
  String periodRange(String start, String end) {
    return 'from $start to $end';
  }

  @override
  String get switchToDarkMode => 'Switch to dark mode';

  @override
  String get switchToLightMode => 'Switch to light mode';

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
  String get colorStats => 'Win statistics';

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
  String get countryRankColumn => '#';

  @override
  String get countryColumn => 'Country';

  @override
  String get opponentsColumn => 'Opponents';

  @override
  String get timeClassLabel => 'Time control';

  @override
  String get timeClassAll => 'All';

  @override
  String get timeClassBullet => 'Bullet';

  @override
  String get timeClassBlitz => 'Blitz';

  @override
  String get timeClassRapid => 'Rapid';

  @override
  String get noCountryData => 'No games for this time control';

  @override
  String get countryStatsLoading => 'Looking up your opponents\' countries…';

  @override
  String get openingColumn => 'Opening';

  @override
  String get ratingEvolution => 'Rating progress';

  @override
  String get ratingCurrent => 'Current rating';

  @override
  String get ratingSincePeriodStart => 'since the first game of the period';

  @override
  String get noRatingData => 'No rated games for this time control';

  @override
  String countryResultRates(String win, String draw, String loss) {
    return 'W $win · D $draw · L $loss';
  }

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
  String get timeTimeout => 'Lost on time';

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
  String countryName(String code) {
    String _temp0 = intl.Intl.selectLogic(
      code,
      {
        'AD': 'Andorra',
        'AE': 'United Arab Emirates',
        'AF': 'Afghanistan',
        'AG': 'Antigua and Barbuda',
        'AI': 'Anguilla',
        'AL': 'Albania',
        'AM': 'Armenia',
        'AO': 'Angola',
        'AQ': 'Antarctica',
        'AR': 'Argentina',
        'AS': 'American Samoa',
        'AT': 'Austria',
        'AU': 'Australia',
        'AW': 'Aruba',
        'AX': 'Åland Islands',
        'AZ': 'Azerbaijan',
        'BA': 'Bosnia and Herzegovina',
        'BB': 'Barbados',
        'BD': 'Bangladesh',
        'BE': 'Belgium',
        'BF': 'Burkina Faso',
        'BG': 'Bulgaria',
        'BH': 'Bahrain',
        'BI': 'Burundi',
        'BJ': 'Benin',
        'BL': 'Saint Barthélemy',
        'BM': 'Bermuda',
        'BN': 'Brunei',
        'BO': 'Bolivia',
        'BQ': 'Caribbean Netherlands',
        'BR': 'Brazil',
        'BS': 'Bahamas',
        'BT': 'Bhutan',
        'BV': 'Bouvet Island',
        'BW': 'Botswana',
        'BY': 'Belarus',
        'BZ': 'Belize',
        'CA': 'Canada',
        'CC': 'Cocos (Keeling) Islands',
        'CD': 'DR Congo',
        'CF': 'Central African Republic',
        'CG': 'Congo',
        'CH': 'Switzerland',
        'CI': 'Côte d\'Ivoire',
        'CK': 'Cook Islands',
        'CL': 'Chile',
        'CM': 'Cameroon',
        'CN': 'China',
        'CO': 'Colombia',
        'CR': 'Costa Rica',
        'CU': 'Cuba',
        'CV': 'Cape Verde',
        'CW': 'Curaçao',
        'CX': 'Christmas Island',
        'CY': 'Cyprus',
        'CZ': 'Czechia',
        'DE': 'Germany',
        'DJ': 'Djibouti',
        'DK': 'Denmark',
        'DM': 'Dominica',
        'DO': 'Dominican Republic',
        'DZ': 'Algeria',
        'EC': 'Ecuador',
        'EE': 'Estonia',
        'EG': 'Egypt',
        'EH': 'Western Sahara',
        'ER': 'Eritrea',
        'ES': 'Spain',
        'ET': 'Ethiopia',
        'FI': 'Finland',
        'FJ': 'Fiji',
        'FK': 'Falkland Islands',
        'FM': 'Micronesia',
        'FO': 'Faroe Islands',
        'FR': 'France',
        'GA': 'Gabon',
        'GB': 'United Kingdom',
        'GD': 'Grenada',
        'GE': 'Georgia',
        'GF': 'French Guiana',
        'GG': 'Guernsey',
        'GH': 'Ghana',
        'GI': 'Gibraltar',
        'GL': 'Greenland',
        'GM': 'Gambia',
        'GN': 'Guinea',
        'GP': 'Guadeloupe',
        'GQ': 'Equatorial Guinea',
        'GR': 'Greece',
        'GS': 'South Georgia and the South Sandwich Islands',
        'GT': 'Guatemala',
        'GU': 'Guam',
        'GW': 'Guinea-Bissau',
        'GY': 'Guyana',
        'HK': 'Hong Kong',
        'HM': 'Heard Island and McDonald Islands',
        'HN': 'Honduras',
        'HR': 'Croatia',
        'HT': 'Haiti',
        'HU': 'Hungary',
        'ID': 'Indonesia',
        'IE': 'Ireland',
        'IL': 'Israel',
        'IM': 'Isle of Man',
        'IN': 'India',
        'IO': 'British Indian Ocean Territory',
        'IQ': 'Iraq',
        'IR': 'Iran',
        'IS': 'Iceland',
        'IT': 'Italy',
        'JE': 'Jersey',
        'JM': 'Jamaica',
        'JO': 'Jordan',
        'JP': 'Japan',
        'KE': 'Kenya',
        'KG': 'Kyrgyzstan',
        'KH': 'Cambodia',
        'KI': 'Kiribati',
        'KM': 'Comoros',
        'KN': 'Saint Kitts and Nevis',
        'KP': 'North Korea',
        'KR': 'South Korea',
        'KW': 'Kuwait',
        'KY': 'Cayman Islands',
        'KZ': 'Kazakhstan',
        'LA': 'Laos',
        'LB': 'Lebanon',
        'LC': 'Saint Lucia',
        'LI': 'Liechtenstein',
        'LK': 'Sri Lanka',
        'LR': 'Liberia',
        'LS': 'Lesotho',
        'LT': 'Lithuania',
        'LU': 'Luxembourg',
        'LV': 'Latvia',
        'LY': 'Libya',
        'MA': 'Morocco',
        'MC': 'Monaco',
        'MD': 'Moldova',
        'ME': 'Montenegro',
        'MF': 'Saint Martin',
        'MG': 'Madagascar',
        'MH': 'Marshall Islands',
        'MK': 'North Macedonia',
        'ML': 'Mali',
        'MM': 'Myanmar',
        'MN': 'Mongolia',
        'MO': 'Macao',
        'MP': 'Northern Mariana Islands',
        'MQ': 'Martinique',
        'MR': 'Mauritania',
        'MS': 'Montserrat',
        'MT': 'Malta',
        'MU': 'Mauritius',
        'MV': 'Maldives',
        'MW': 'Malawi',
        'MX': 'Mexico',
        'MY': 'Malaysia',
        'MZ': 'Mozambique',
        'NA': 'Namibia',
        'NC': 'New Caledonia',
        'NE': 'Niger',
        'NF': 'Norfolk Island',
        'NG': 'Nigeria',
        'NI': 'Nicaragua',
        'NL': 'Netherlands',
        'NO': 'Norway',
        'NP': 'Nepal',
        'NR': 'Nauru',
        'NU': 'Niue',
        'NZ': 'New Zealand',
        'OM': 'Oman',
        'PA': 'Panama',
        'PE': 'Peru',
        'PF': 'French Polynesia',
        'PG': 'Papua New Guinea',
        'PH': 'Philippines',
        'PK': 'Pakistan',
        'PL': 'Poland',
        'PM': 'Saint Pierre and Miquelon',
        'PN': 'Pitcairn Islands',
        'PR': 'Puerto Rico',
        'PS': 'Palestine',
        'PT': 'Portugal',
        'PW': 'Palau',
        'PY': 'Paraguay',
        'QA': 'Qatar',
        'RE': 'Réunion',
        'RO': 'Romania',
        'RS': 'Serbia',
        'RU': 'Russia',
        'RW': 'Rwanda',
        'SA': 'Saudi Arabia',
        'SB': 'Solomon Islands',
        'SC': 'Seychelles',
        'SD': 'Sudan',
        'SE': 'Sweden',
        'SG': 'Singapore',
        'SH': 'Saint Helena',
        'SI': 'Slovenia',
        'SJ': 'Svalbard and Jan Mayen',
        'SK': 'Slovakia',
        'SL': 'Sierra Leone',
        'SM': 'San Marino',
        'SN': 'Senegal',
        'SO': 'Somalia',
        'SR': 'Suriname',
        'SS': 'South Sudan',
        'ST': 'São Tomé and Príncipe',
        'SV': 'El Salvador',
        'SX': 'Sint Maarten',
        'SY': 'Syria',
        'SZ': 'Eswatini',
        'TC': 'Turks and Caicos Islands',
        'TD': 'Chad',
        'TF': 'French Southern Territories',
        'TG': 'Togo',
        'TH': 'Thailand',
        'TJ': 'Tajikistan',
        'TK': 'Tokelau',
        'TL': 'Timor-Leste',
        'TM': 'Turkmenistan',
        'TN': 'Tunisia',
        'TO': 'Tonga',
        'TR': 'Turkey',
        'TT': 'Trinidad and Tobago',
        'TV': 'Tuvalu',
        'TW': 'Taiwan',
        'TZ': 'Tanzania',
        'UA': 'Ukraine',
        'UG': 'Uganda',
        'UM': 'U.S. Outlying Islands',
        'US': 'United States',
        'UY': 'Uruguay',
        'UZ': 'Uzbekistan',
        'VA': 'Vatican City',
        'VC': 'Saint Vincent and the Grenadines',
        'VE': 'Venezuela',
        'VG': 'British Virgin Islands',
        'VI': 'U.S. Virgin Islands',
        'VN': 'Vietnam',
        'VU': 'Vanuatu',
        'WF': 'Wallis and Futuna',
        'WS': 'Samoa',
        'YE': 'Yemen',
        'YT': 'Mayotte',
        'ZA': 'South Africa',
        'ZM': 'Zambia',
        'ZW': 'Zimbabwe',
        'EU': 'European Union',
        'XA': 'Canary Islands',
        'XB': 'Basque Country',
        'XC': 'Catalonia',
        'XE': 'England',
        'XG': 'Galicia',
        'XK': 'Kosovo',
        'XP': 'Palestine',
        'XS': 'Scotland',
        'XW': 'Wales',
        'XX': 'International',
        'other': '$code',
      },
    );
    return '$_temp0';
  }

  @override
  String get countryMapHint =>
      'Tap a country to see how many games you played against it. Pinch or use the buttons to zoom.';

  @override
  String countryMapGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games',
      one: '1 game',
      zero: '0 games',
    );
    return '$_temp0';
  }

  @override
  String get countryMapLegend => 'Games played';

  @override
  String get countryMapZoomIn => 'Zoom in';

  @override
  String get countryMapZoomOut => 'Zoom out';

  @override
  String get countryMapReset => 'Reset view';

  @override
  String countryMapNotShown(String countries) {
    return 'Not shown on the map: $countries';
  }

  @override
  String countryMapNotShownItem(String country, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games',
      one: '1 game',
      zero: '0 games',
    );
    return '$country ($_temp0)';
  }

  @override
  String countryMapTopRank(String rank) {
    String _temp0 = intl.Intl.selectLogic(
      rank,
      {
        '1': 'Most played country',
        '2': '2nd most played country',
        '3': '3rd most played country',
        'other': 'No. $rank most played country',
      },
    );
    return '$_temp0';
  }

  @override
  String get countryMapModeGames => 'Games played';

  @override
  String get countryMapModePerformance => 'Performance';

  @override
  String get countryMapPerformanceHint =>
      'Tap a country to see your performance against it. Pinch or use the buttons to zoom.';

  @override
  String get countryMapPerformanceLegend => 'Performance';

  @override
  String countryMapPercent(int percent) {
    return '$percent%';
  }

  @override
  String countryMapPerformanceTitle(String country, int percent) {
    return '$country · $percent%';
  }

  @override
  String countryMapPerformanceDetail(
      int games, int wins, int draws, int losses) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games games',
      one: '1 game',
    );
    return '$_temp0 · W $wins · D $draws · L $losses';
  }

  @override
  String countryMapNotEnoughDetail(int games) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games games',
      one: '1 game',
      zero: '0 games',
    );
    return '$_temp0 · not enough to rate';
  }

  @override
  String countryMapGroup(String countries) {
    return '$countries: tap to zoom in';
  }

  @override
  String countryMapNotEnoughLegend(int minGames) {
    return 'Fewer than $minGames games: not enough to rate';
  }

  @override
  String countryMapNoneJudged(int minGames) {
    return 'No country has enough games yet to rate the performance ($minGames minimum).';
  }

  @override
  String get countryMapStrengths => 'Strengths: ';

  @override
  String get countryMapWeaknesses => 'Weaknesses: ';

  @override
  String get countryMapNoStrength => 'none in this period';

  @override
  String get countryMapNoWeakness => 'none in this period';

  @override
  String countryMapSummaryItem(String country, int percent) {
    return '$country $percent%';
  }

  @override
  String countryMapStrengthRank(String rank) {
    String _temp0 = intl.Intl.selectLogic(
      rank,
      {
        '1': 'Best performance',
        '2': '2nd best performance',
        '3': '3rd best performance',
        'other': 'No. $rank best performance',
      },
    );
    return '$_temp0';
  }

  @override
  String countryMapWeaknessRank(String rank) {
    String _temp0 = intl.Intl.selectLogic(
      rank,
      {
        '1': 'Weakest performance',
        '2': '2nd weakest performance',
        '3': '3rd weakest performance',
        'other': 'No. $rank weakest performance',
      },
    );
    return '$_temp0';
  }

  @override
  String paginationRange(int first, int last, int total) {
    return '$first–$last of $total';
  }

  @override
  String get previousPage => 'Previous page';

  @override
  String get nextPage => 'Next page';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get whatsNew => 'What\'s new';

  @override
  String get close => 'Close';

  @override
  String changelogVersionTitle(String version, String date) {
    return 'Version $version – $date';
  }

  @override
  String get changelogV180 =>
      'Filters grouped in a menu, each with its own title\nSummary of your chosen filters always visible on mobile\nA lighter top bar on mobile and tablet\nOn desktop, filters stay visible on the left';

  @override
  String get changelogV170 =>
      'Share a player\'s stats with a simple link\nStats on rated games, or on all games if you prefer\nLosses on time shown in time management\nA clearer monthly recap';

  @override
  String get share => 'Share';

  @override
  String shareText(String username) {
    return '$username\'s stats on Chess Stats';
  }

  @override
  String shareRecapText(String username) {
    return '$username\'s monthly recap on Chess Stats';
  }

  @override
  String shareScoutText(String username) {
    return 'How to beat $username on Chess Stats';
  }

  @override
  String get shareCopied => 'Link copied';

  @override
  String get shareLinkTitle => 'Link to share';

  @override
  String get playerLoading => 'Loading games…';

  @override
  String get changelogV160 =>
      'Your monthly recap as slides, the first time you look up a player, and to replay from the stats page\nShared filters at the top of the page: time control, colour and opening\nOpening names translated and grouped more accurately\nOne rating curve per time control, and by colour';

  @override
  String get changelogV150 =>
      'New \"Game phases\" card: see where your games are decided, from the opening to the endgame\nYour time left against your opponent\'s, at a glance, after the opening and in the endgame\nYour endgame results by material and by type of endgame\nFaster page: the longest stats show up a moment later';

  @override
  String get changelogV140 =>
      'Stats for the last month or the last 3 months, your choice\nFaster display: each player\'s games are kept in your browser\nSearch: players you already looked up are suggested\nCleaner, more compact page, especially on mobile';

  @override
  String get changelogV130 =>
      'New \"Playing hours\" card: a 24-hour dial of this month\'s games by start time, in your local time\n\"Activity\" mode: number of games per hour, in shades of blue\n\"Performance\" mode: score per hour, from red to green through yellow (at least 5 games per hour)\nBest and weakest time slots: one click shows them on the dial\nTap an hour to see its details in a bubble';

  @override
  String get changelogV121 =>
      'Faster loading: each opponent\'s country is requested only once, several at a time, and remembered for a month in your browser';

  @override
  String get changelogV120 =>
      'Countries map: new \"Performance\" map, from red (losses) to green (wins) through yellow (even)\nCountries with too few games in grey: 2 games minimum, 3 above 40 games in the month\nStrengths and weaknesses: markers on the map and a summary under the legend';

  @override
  String get changelogV110 =>
      'Desktop display: statistics on two columns on large screens\nPage title centered on every page\nPlayed openings and opponents\' countries: paginated tables, 5 rows per page\nFooter with the version number and what\'s new';

  @override
  String get changelogV100 =>
      'Current month statistics: by color, by opening, rating history, time management, loss causes\nStatistics by opponents\' country, with a world map\nLight / dark mode\nApp in English and French';

  @override
  String get playingHours => 'Playing hours';

  @override
  String get playingHoursModeActivity => 'Activity';

  @override
  String get playingHoursModePerformance => 'Performance';

  @override
  String get playingHoursHint =>
      'Each slice is one hour, by the time the game started (your local time). Tap an hour to see the details.';

  @override
  String playingHoursHourLabel(int hour) {
    return '$hour:00';
  }

  @override
  String playingHoursRange(int start, int end) {
    return '$start:00–$end:00';
  }

  @override
  String playingHoursDetail(String range, String detail) {
    return '$range · $detail';
  }

  @override
  String playingHoursPerformanceDetail(
      int percent, int games, int wins, int draws, int losses) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games games',
      one: '1 game',
    );
    return '$percent% · $_temp0 · W $wins · D $draws · L $losses';
  }

  @override
  String playingHoursNotEnoughDetail(int games, int minGames) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games games',
      one: '1 game',
      zero: '0 games',
    );
    return '$_temp0, not enough to rate ($minGames minimum)';
  }

  @override
  String get playingHoursBandVeryLow => 'Below 40%';

  @override
  String get playingHoursBandLow => '40–46%';

  @override
  String get playingHoursBandEven => '46–54%';

  @override
  String get playingHoursBandHigh => '54–60%';

  @override
  String get playingHoursBandVeryHigh => 'Above 60%';

  @override
  String get playingHoursBest => 'Best time slot:';

  @override
  String get playingHoursWorst => 'Weakest time slot:';

  @override
  String playingHoursSlot(String range, int percent, int games) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games games',
      one: '1 game',
    );
    return '$range ($percent%, $_temp0)';
  }

  @override
  String playingHoursNoneJudged(int minGames) {
    return 'No hour has enough games yet to rate your performance ($minGames minimum).';
  }

  @override
  String get gamePhases => 'Game phases';

  @override
  String gamePhasesLoading(String percent) {
    return 'Analysing your games… $percent';
  }

  @override
  String get noPhaseData => 'No analysed games for this time control';

  @override
  String get phaseEndTitle => 'Where your games end';

  @override
  String get phaseOpening => 'In the opening';

  @override
  String get phaseMiddlegame => 'In the middlegame';

  @override
  String get phaseEndgame => 'In the endgame';

  @override
  String phaseTimeoutLosses(int count) {
    return 'Including $count lost on time';
  }

  @override
  String get phaseClockTitle => 'Time left';

  @override
  String get phaseClockMiddlegame => 'End of the opening';

  @override
  String get phaseClockEndgame => 'Reaching the endgame';

  @override
  String get phaseClockPlayer => 'You';

  @override
  String get phaseClockOpponent => 'Opponent';

  @override
  String get phaseClockNote =>
      'Average, as a share of the starting time (timed games only).';

  @override
  String get endgameMaterialTitle => 'Your endgames by material';

  @override
  String get endgameMaterialAhead => 'Material up';

  @override
  String get endgameMaterialEqual => 'Material equal';

  @override
  String get endgameMaterialBehind => 'Material down';

  @override
  String get endgameTypeTitle => 'By endgame type';

  @override
  String get endgameTypePawn => 'Pawn endgames';

  @override
  String get endgameTypeMinor => 'Minor piece endgames';

  @override
  String get endgameTypeRook => 'Rook endgames';

  @override
  String get endgameTypeRookMinor => 'Rooks and minor pieces';

  @override
  String get endgameTypeQueen => 'Queen endgames';

  @override
  String get endgameTypeQueenOther => 'Queens and other pieces';

  @override
  String get phaseClockLegendPlayer => 'Your time left (top half):';

  @override
  String get phaseClockLegendOpponent => 'Opponent\'s time left (bottom half)';

  @override
  String get phaseClockLegendElapsed => 'Time used';

  @override
  String get phaseClockLegendAhead =>
      'More than your opponent (gap above 10% of the starting time)';

  @override
  String get phaseClockLegendBalanced =>
      'About the same as your opponent (gap of 10% or less)';

  @override
  String get phaseClockLegendBehind =>
      'Less than your opponent (gap above 10% of the starting time)';

  @override
  String get ratedFilterLabel => 'Games included';

  @override
  String get ratedFilterRated => 'Rated games';

  @override
  String get ratedFilterAll => 'All games';

  @override
  String get colorFilterLabel => 'Color played';

  @override
  String get colorFilterBoth => 'Both';

  @override
  String get colorFilterWhite => 'White';

  @override
  String get colorFilterBlack => 'Black';

  @override
  String get allGames => 'All games';

  @override
  String resultRateWithCount(String rate, int count) {
    return '$rate ($count)';
  }

  @override
  String get ratingTrendWhite => 'Rating points won or lost with white';

  @override
  String get ratingTrendBlack => 'Rating points won or lost with black';

  @override
  String ratingTrendPoints(String points) {
    return '$points pts';
  }

  @override
  String ratingTrendGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'over $count games',
      one: 'over 1 game',
    );
    return '$_temp0';
  }

  @override
  String get ratingTrendNotEnough =>
      'Not enough rated games to compute the trend';

  @override
  String openingFamilyName(String family, String fallback) {
    String _temp0 = intl.Intl.selectLogic(
      family,
      {
        'QueensPawn': 'Queen\'s Pawn Game',
        'QueensGambit': 'Queen\'s Gambit',
        'SicilianDefense': 'Sicilian Defense',
        'RuyLopez': 'Ruy Lopez',
        'EnglishOpening': 'English Opening',
        'FrenchDefense': 'French Defense',
        'DutchDefense': 'Dutch Defense',
        'KingsGambit': 'King\'s Gambit',
        'CaroKann': 'Caro-Kann Defense',
        'ViennaGame': 'Vienna Game',
        'TwoKnights': 'Two Knights Defense',
        'GiuocoPiano': 'Giuoco Piano',
        'ItalianGame': 'Italian Game',
        'AlekhinesDefense': 'Alekhine\'s Defense',
        'RetiOpening': 'Réti Opening',
        'RetiAccepted': 'Réti Accepted',
        'PircDefense': 'Pirc Defense',
        'KingsPawn': 'King\'s Pawn Game',
        'FourKnights': 'Four Knights Game',
        'PetrovDefense': 'Petrov\'s Defense',
        'PetrovsDefense': 'Petrov\'s Defense',
        'KingsKnights': 'King\'s Knight Opening',
        'KingsIndian': 'King\'s Indian',
        'QueensIndian': 'Queen\'s Indian Defense',
        'NimzoIndian': 'Nimzo-Indian Defense',
        'BogoIndian': 'Bogo-Indian Defense',
        'IndianGame': 'Indian Game',
        'CenterGame': 'Center Game',
        'BishopsOpening': 'Bishop\'s Opening',
        'BirdsOpening': 'Bird\'s Opening',
        'ScotchGame': 'Scotch Game',
        'ScandinavianDefense': 'Scandinavian Defense',
        'RobatschDefense': 'Modern Defense (Robatsch)',
        'ModernDefense': 'Modern Defense',
        'PhilidorDefense': 'Philidor Defense',
        'NimzowitschLarsen': 'Nimzowitsch-Larsen Attack',
        'AnderssenOpening': 'Anderssen\'s Opening',
        'LondonSystem': 'London System',
        'ColleSystem': 'Colle System',
        'TrompowskyAttack': 'Trompowsky Attack',
        'GrunfeldDefense': 'Grünfeld Defense',
        'SlavDefense': 'Slav Defense',
        'SemiSlav': 'Semi-Slav Defense',
        'CatalanOpening': 'Catalan Opening',
        'BenoniDefense': 'Benoni Defense',
        'BenkoGambit': 'Benko Gambit',
        'OwensDefense': 'Owen\'s Defense',
        'PolishOpening': 'Polish Opening',
        'ZukertortOpening': 'Zukertort Opening',
        'PonzianiOpening': 'Ponziani Opening',
        'EvansGambit': 'Evans Gambit',
        'DanishGambit': 'Danish Gambit',
        'UnknownOpening': 'Unknown opening',
        'UncommonOpening': 'Uncommon Opening',
        'KingsIndianAttack': 'King\'s Indian Attack',
        'BudapestGambit': 'Budapest Gambit',
        'OldIndian': 'Old Indian Defense',
        'KingsKnight': 'King\'s Knight Opening',
        'ThreeKnights': 'Three Knights Game',
        'VeresovAttack': 'Veresov Attack',
        'TorreAttack': 'Torre Attack',
        'OpenGame': 'Open Game',
        'ClosedGame': 'Closed Game',
        'HorwitzDefense': 'Horwitz Defense',
        'EnglundGambit': 'Englund Gambit',
        'NimzowitschDefense': 'Nimzowitsch Defense',
        'OldBenoni': 'Old Benoni Defense',
        'ReversedSicilian': 'Reversed Sicilian',
        'SymmetricalEnglish': 'Symmetrical English',
        'AngloIndian': 'Anglo-Indian Defense',
        'KingsFianchetto': 'King\'s Fianchetto Opening',
        'other': '$fallback',
      },
    );
    return '$_temp0';
  }

  @override
  String get openingFilterLabel => 'Opening';

  @override
  String get openingFilterAll => 'All openings';

  @override
  String get openingFilterOthers => 'Other openings';

  @override
  String openingOptionCount(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get ratingTrendSelection =>
      'Rating points won or lost in the selected games';

  @override
  String get slidesPrevious => 'Previous';

  @override
  String get slidesNext => 'Next';

  @override
  String get recapSkip => 'Skip';

  @override
  String get recapSeeStats => 'See all stats';

  @override
  String get recapIntroLabel => 'Your month on chess.com';

  @override
  String recapIntroTitle(String username) {
    return '$username, here are your last 30 days';
  }

  @override
  String get recapIntroHint => 'Tap or swipe to continue';

  @override
  String get recapGamesLabel => 'Games played';

  @override
  String recapWins(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wins',
      one: '$count win',
    );
    return '$_temp0';
  }

  @override
  String recapDraws(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count draws',
      one: '$count draw',
    );
    return '$_temp0';
  }

  @override
  String recapLosses(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count losses',
      one: '$count loss',
    );
    return '$_temp0';
  }

  @override
  String get recapScoreLabel => 'Your results';

  @override
  String get recapScoreCaption => 'of games won';

  @override
  String get recapReplay => 'Replay the monthly recap';

  @override
  String get recapTimeClassLabel => 'Your favourite time control';

  @override
  String get recapTimeClassDaily => 'Daily';

  @override
  String recapGamesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games',
      one: '$count game',
    );
    return '$_temp0';
  }

  @override
  String recapRatingChange(String change) {
    return 'Rating: $change over the month';
  }

  @override
  String recapPeakRating(int rating) {
    return 'Peak: $rating';
  }

  @override
  String get recapStreakLabel => 'Longest winning streak';

  @override
  String get recapStreakCaption => 'wins in a row';

  @override
  String get recapStreakCaptionHot => 'wins in a row. Unstoppable!';

  @override
  String get recapOpeningLabel => 'Your go-to opening';

  @override
  String recapOpeningCaption(num count, String percent) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games',
      one: '$count game',
    );
    return '$_temp0 · $percent won';
  }

  @override
  String get recapBestOpeningLabel => 'Your secret weapon';

  @override
  String get recapHourLabel => 'Your favourite time to play';

  @override
  String recapHourValue(int hour) {
    return '$hour:00';
  }

  @override
  String recapBusiestDay(String date, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games',
      one: '$count game',
    );
    return 'Busiest day: $date, $_temp0';
  }

  @override
  String get recapOpponentLabel => 'Your most-faced opponent';

  @override
  String recapOpponentCaption(int count, int wins, int draws, int losses) {
    return '$count games together · $wins W, $draws D, $losses L';
  }

  @override
  String get recapWeakOpeningLabel => 'The opening that gives you trouble';

  @override
  String get recapOutroLabel => 'That\'s your month';

  @override
  String get recapOutroTitle => 'Want to dig deeper?';

  @override
  String get recapEmptyTitle => 'No games in the last 30 days';

  @override
  String get recapHourEarlyBird => 'Early bird: chess before coffee!';

  @override
  String get recapHourMorning => 'You start the day with a game.';

  @override
  String get recapHourLunch => 'A game over your lunch break?';

  @override
  String get recapHourAfternoon => 'Afternoons are your time.';

  @override
  String get recapHourEvening => 'Your evening game is sacred.';

  @override
  String get recapHourNightOwl => 'A true night owl!';

  @override
  String get recapVolumeCasual => 'Easy does it: a game now and then.';

  @override
  String recapVolumeRegular(int count) {
    return 'A steady pace, about $count a week.';
  }

  @override
  String get recapVolumeEveryDay => 'You play almost every day!';

  @override
  String recapVolumeEnthusiast(int count) {
    return 'A real enthusiast: $count games a day on average.';
  }

  @override
  String get recapVolumeNonStop => 'Your board never gets cold.';

  @override
  String get recapScoreDominant => 'You\'re crushing the competition.';

  @override
  String get recapScoreWinning => 'More wins than losses: well played!';

  @override
  String get recapScoreBalanced =>
      'Evenly matched: every game comes down to the wire.';

  @override
  String get recapScoreTough => 'A tough month, the next one will be better.';

  @override
  String get recapScoreLearning =>
      'A month for learning: every loss is a lesson.';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get filtersOpen => 'Open menu';

  @override
  String get filtersReset => 'Reset';

  @override
  String get filtersDone => 'See stats';

  @override
  String get periodLabel => 'Period';

  @override
  String get menuTitle => 'Menu';

  @override
  String get menuMoreSection => 'More';

  @override
  String get showStats => 'Show stats';

  @override
  String get scoutButton => 'How to beat this player';

  @override
  String get scoutIntroLabel => 'How to beat';

  @override
  String get scoutEmpty => 'Not enough games to analyze this player';

  @override
  String get scoutSeeStats => 'See their stats';

  @override
  String get scoutFormLabel => 'Current form';

  @override
  String get scoutFormCollapse => 'In crisis';

  @override
  String get scoutFormSlump => 'Struggling';

  @override
  String get scoutFormSteady => 'Steady';

  @override
  String get scoutFormGood => 'In form';

  @override
  String get scoutFormLegendary => 'Legendary';

  @override
  String scoutFormRating(String change, int rating, String timeClass) {
    return '$change points over these games ($timeClass: $rating)';
  }

  @override
  String scoutFormScore(String percent, int games) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$percent wins over their last $games games',
      one: '$percent wins in their last game',
    );
    return '$_temp0';
  }

  @override
  String get scoutFormTipCollapse =>
      'Your opponent is in crisis: put on pressure from the opening, confidence is low.';

  @override
  String get scoutFormTipSlump =>
      'Going through a rough patch: impose your game and pose problems early.';

  @override
  String get scoutFormTipSteady =>
      'Steady form: nothing to exploit here, it will all be decided on the board.';

  @override
  String get scoutFormTipGood =>
      'Your opponent is confident: play solid and don\'t hand over the initiative.';

  @override
  String get scoutFormTipLegendary =>
      'Legendary streak: expect a tough game, stay solid and pounce on any mistake.';

  @override
  String scoutCadenceTipSame(String timeClass) {
    return 'Challenge them in $timeClass: that\'s where their score is lowest.';
  }

  @override
  String scoutCadenceTipOther(String timeClass) {
    return 'If you can choose the time control, play $timeClass.';
  }

  @override
  String scoutCadenceTipFewGames(String timeClass) {
    return 'If you can choose the time control, give $timeClass a try.';
  }

  @override
  String get scoutWhiteLabel => 'When your opponent has white';

  @override
  String get scoutBlackLabel => 'When your opponent has black';

  @override
  String get scoutOpeningFavorite => 'their #1 opening';

  @override
  String scoutOpeningGames(int games) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games games with this color',
      one: '1 game with this color',
    );
    return '$_temp0';
  }

  @override
  String get scoutPlanLabel => 'Your game plan';

  @override
  String get scoutPlanTitle => 'Key points';

  @override
  String scoutPlanAsBlack(String tip) {
    return 'With black — $tip';
  }

  @override
  String scoutPlanAsWhite(String tip) {
    return 'With white — $tip';
  }

  @override
  String scoutIntroBase(int games, String timeClass, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other:
          'We analyze their $games $timeClass games from the last $days days: their main time control.',
      one:
          'We analyze their only $timeClass game from the last $days days: their main time control.',
    );
    return '$_temp0';
  }

  @override
  String get scoutCadenceSingle =>
      'No other time control played over the period.';

  @override
  String scoutCadenceSame(String percent) {
    return 'It\'s also their least successful one ($percent wins).';
  }

  @override
  String scoutCadenceOther(String timeClass, String percent, int games) {
    return 'Their least successful time control is $timeClass: $percent wins over $games games.';
  }

  @override
  String scoutCadenceOtherRating(String timeClass, int games) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: 'Their lowest rating is in $timeClass ($games games).',
      one: 'Their lowest rating is in $timeClass (1 game).',
    );
    return '$_temp0';
  }

  @override
  String scoutCadenceFewGames(String timeClass, int games) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other:
          '$timeClass seems harder for them, but from only $games games: to be confirmed.',
      one:
          '$timeClass seems harder for them, but from a single game: to be confirmed.',
    );
    return '$_temp0';
  }

  @override
  String scoutMainMove(String move, String percent) {
    return 'First move: $move in $percent of their games.';
  }

  @override
  String scoutReplyTarget(
      String move, String reply, String percent, int games) {
    return 'Against $move, reply $reply: only $percent wins for your opponent ($games games).';
  }

  @override
  String scoutReplyAvoid(String move, String reply, String percent, int games) {
    return 'Against $move, avoid $reply: $percent wins for your opponent ($games games).';
  }

  @override
  String scoutReplyNone(String move) {
    return 'No reply to $move stands out yet: play the one you know best.';
  }

  @override
  String scoutFirstMoveTarget(String move, String percent, int games) {
    return 'Open with $move: only $percent wins for your opponent ($games games).';
  }

  @override
  String scoutFirstMoveAvoid(String move, String percent, int games) {
    return 'Avoid opening with $move: $percent wins for your opponent ($games games).';
  }

  @override
  String get scoutFirstMoveNone =>
      'No first move stands out yet: play what you know best.';

  @override
  String scoutMoveWithName(String move, String name) {
    return '$move ($name)';
  }

  @override
  String scoutIntroTitle(String username) {
    return 'How to beat $username';
  }

  @override
  String scoutIntroTimeClass(String timeClass) {
    String _temp0 = intl.Intl.selectLogic(
      timeClass,
      {
        'bullet': 'in bullet',
        'blitz': 'in blitz',
        'rapid': 'in rapid',
        'other': 'in $timeClass',
      },
    );
    return '$_temp0';
  }

  @override
  String scoutOpeningResults(int games, String percent) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games games · $percent wins',
      one: '1 game · $percent wins',
    );
    return '$_temp0';
  }

  @override
  String get changelogV190 =>
      'New: “How to beat this player”, their weak spots and tips in slides\nTheir current form shown as a chess piece\nOpening tips on the moves you choose\nHome: “Show stats” or “How to beat this player”';

  @override
  String get scoutAnalyzing => 'Analyzing games…';

  @override
  String get scoutNotEnough => 'Not enough games to tell';

  @override
  String get scoutPhaseLabel => 'Where your opponent cracks';

  @override
  String get scoutPhaseExplain =>
      'Games grouped by the phase in which they end.';

  @override
  String get scoutPhaseTipOpening =>
      'Put on pressure from the opening: that\'s where your opponent wins least.';

  @override
  String get scoutPhaseTipMiddlegame =>
      'Keep pieces on and complicate the middlegame: that\'s where your opponent wins least.';

  @override
  String get scoutPhaseTipEndgame =>
      'Simplify and head for the endgame: that\'s where your opponent wins least.';

  @override
  String get scoutPhaseTipNone =>
      'No clearly weaker phase: their level is steady from start to finish.';

  @override
  String get scoutTimeLabel => 'Time management';

  @override
  String get scoutTimeSlow => 'Slow';

  @override
  String get scoutTimeBalanced => 'Balanced';

  @override
  String get scoutTimeFast => 'Fast';

  @override
  String scoutTimeMiddlegame(String gap) {
    return 'End of the opening: $gap of the starting time compared with their opponent';
  }

  @override
  String scoutTimeEndgame(String gap) {
    return 'Entering the endgame: $gap of the starting time';
  }

  @override
  String scoutTimeTimeouts(String percent) {
    return '$percent of their losses on time';
  }

  @override
  String get scoutTimeTipSlow =>
      'Play fast and keep the clock pressure on: time is their weak spot.';

  @override
  String get scoutTimeTipBalanced =>
      'Balanced time management: no clock trap, it will all be decided on the board.';

  @override
  String get scoutTimeTipFast =>
      'Your opponent plays fast: take your time and look for complex positions.';

  @override
  String get scoutTiltLabel => 'After a loss';

  @override
  String get scoutTiltTilts => 'It rattles them';

  @override
  String get scoutTiltSteady => 'No change';

  @override
  String get scoutTiltResilient => 'It fires them up';

  @override
  String get scoutTiltAfterRow => 'Right after a loss';

  @override
  String get scoutTiltUsualRow => 'Usually';

  @override
  String get scoutTiltExplain =>
      'Games started less than an hour after a loss.';

  @override
  String get scoutTiltTipTilts =>
      'If you win, offer a rematch right away: just after a loss, your opponent wins much less.';

  @override
  String get scoutTiltTipResilient =>
      'Beware the rematch: just after a loss, your opponent wins even more.';

  @override
  String get scoutTiltTipSteady =>
      'A loss doesn\'t change their game: no rematch effect to expect.';

  @override
  String get scoutHoursLabel => 'By time of day';

  @override
  String get scoutHoursCaption => 'their weakest time of day';

  @override
  String get scoutHoursExplain =>
      'Game start time, in your device\'s time zone.';

  @override
  String get scoutDayPartMorning => 'In the morning';

  @override
  String get scoutDayPartAfternoon => 'In the afternoon';

  @override
  String get scoutDayPartEvening => 'In the evening';

  @override
  String get scoutDayPartNight => 'At night';

  @override
  String get scoutDayPartMorningRow => 'Morning (5 am – 12 pm)';

  @override
  String get scoutDayPartAfternoonRow => 'Afternoon (12 pm – 6 pm)';

  @override
  String get scoutDayPartEveningRow => 'Evening (6 pm – 10 pm)';

  @override
  String get scoutDayPartNightRow => 'Night (10 pm – 5 am)';

  @override
  String scoutHoursTipMorning(String percent) {
    return 'If you can, play them in the morning: only $percent wins for your opponent.';
  }

  @override
  String scoutHoursTipAfternoon(String percent) {
    return 'If you can, play them in the afternoon: only $percent wins for your opponent.';
  }

  @override
  String scoutHoursTipEvening(String percent) {
    return 'If you can, play them in the evening: only $percent wins for your opponent.';
  }

  @override
  String scoutHoursTipNight(String percent) {
    return 'If you can, play them at night: only $percent wins for your opponent.';
  }

  @override
  String get scoutHoursTipNone =>
      'Time of day makes no difference to their level.';

  @override
  String get scoutPhaseNone => 'No weak phase';

  @override
  String get scoutHoursNone => 'No weak time of day';

  @override
  String get changelogV1100 =>
      '“How to beat this player”: the phase where your opponent cracks\nTheir time management and how they react after a loss\nTheir weakest times of day\nA fuller game plan';

  @override
  String get changelogV1110 =>
      'Share the monthly recap or “How to beat this player” with their own link\nA shared stats link opens the stats straight away\nThe monthly recap starts on its own only when you search for a player';
}
