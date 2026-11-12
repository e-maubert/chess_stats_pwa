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
  String get refresh => 'Refresh';

  @override
  String get retry => 'Retry';

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
  String get countryMapNoStrength => 'none this month';

  @override
  String get countryMapNoWeakness => 'none this month';

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
}
