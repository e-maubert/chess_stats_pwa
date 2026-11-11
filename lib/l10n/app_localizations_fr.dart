// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Chess Stats';

  @override
  String get appLogo => 'Logo Chess Stats';

  @override
  String statsTitle(String username) {
    return 'Chess Stats : $username';
  }

  @override
  String get enterUsername => 'Entrez votre nom d\'utilisateur Chess.com';

  @override
  String get search => 'Rechercher';

  @override
  String get refresh => 'Actualiser';

  @override
  String get retry => 'Réessayer';

  @override
  String get switchToDarkMode => 'Passer en mode sombre';

  @override
  String get switchToLightMode => 'Passer en mode clair';

  @override
  String get errorFetchingStats =>
      'Erreur lors de la récupération des statistiques';

  @override
  String get playedOpenings => 'Ouvertures jouées';

  @override
  String get gamesPlayed => 'Parties jouées';

  @override
  String get wins => 'Victoires';

  @override
  String get losses => 'Défaites';

  @override
  String get draws => 'Matchs nuls';

  @override
  String get colorStats => 'Statistiques par couleur';

  @override
  String get withWhite => 'Avec les blancs';

  @override
  String get withBlack => 'Avec les noirs';

  @override
  String get countryStats => 'Statistiques par pays';

  @override
  String played(int count) {
    return 'Parties jouées: $count';
  }

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
  String get openingColumn => 'Ouverture';

  @override
  String get ratingEvolution => 'Évolution du classement';

  @override
  String get ratingCurrent => 'Classement actuel';

  @override
  String get ratingSinceMonthStart => 'depuis la 1re partie du mois';

  @override
  String get noRatingData => 'Aucune partie classée pour cette cadence';

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
  String get timeManagement => 'Gestion du temps sur les défaites';

  @override
  String get timeGapAverage =>
      'Lorsque vous perdez, voici votre écart de temps moyen avec l\'adversaire en fin de partie :';

  @override
  String get timeBehind => 'En retard au temps';

  @override
  String get timeBalanced => 'Temps équilibré';

  @override
  String get timeAhead => 'En avance au temps';

  @override
  String get timeThresholdNote =>
      'Écart important : plus de 10 % du temps initial';

  @override
  String get countryUnknown => 'Pays inconnu';

  @override
  String countryName(String code) {
    String _temp0 = intl.Intl.selectLogic(
      code,
      {
        'AD': 'Andorre',
        'AE': 'Émirats arabes unis',
        'AF': 'Afghanistan',
        'AG': 'Antigua-et-Barbuda',
        'AI': 'Anguilla',
        'AL': 'Albanie',
        'AM': 'Arménie',
        'AO': 'Angola',
        'AQ': 'Antarctique',
        'AR': 'Argentine',
        'AS': 'Samoa américaines',
        'AT': 'Autriche',
        'AU': 'Australie',
        'AW': 'Aruba',
        'AX': 'Îles Åland',
        'AZ': 'Azerbaïdjan',
        'BA': 'Bosnie-Herzégovine',
        'BB': 'Barbade',
        'BD': 'Bangladesh',
        'BE': 'Belgique',
        'BF': 'Burkina Faso',
        'BG': 'Bulgarie',
        'BH': 'Bahreïn',
        'BI': 'Burundi',
        'BJ': 'Bénin',
        'BL': 'Saint-Barthélemy',
        'BM': 'Bermudes',
        'BN': 'Brunei',
        'BO': 'Bolivie',
        'BQ': 'Pays-Bas caribéens',
        'BR': 'Brésil',
        'BS': 'Bahamas',
        'BT': 'Bhoutan',
        'BV': 'Île Bouvet',
        'BW': 'Botswana',
        'BY': 'Biélorussie',
        'BZ': 'Belize',
        'CA': 'Canada',
        'CC': 'Îles Cocos',
        'CD': 'République démocratique du Congo',
        'CF': 'République centrafricaine',
        'CG': 'Congo',
        'CH': 'Suisse',
        'CI': 'Côte d\'Ivoire',
        'CK': 'Îles Cook',
        'CL': 'Chili',
        'CM': 'Cameroun',
        'CN': 'Chine',
        'CO': 'Colombie',
        'CR': 'Costa Rica',
        'CU': 'Cuba',
        'CV': 'Cap-Vert',
        'CW': 'Curaçao',
        'CX': 'Île Christmas',
        'CY': 'Chypre',
        'CZ': 'Tchéquie',
        'DE': 'Allemagne',
        'DJ': 'Djibouti',
        'DK': 'Danemark',
        'DM': 'Dominique',
        'DO': 'République dominicaine',
        'DZ': 'Algérie',
        'EC': 'Équateur',
        'EE': 'Estonie',
        'EG': 'Égypte',
        'EH': 'Sahara occidental',
        'ER': 'Érythrée',
        'ES': 'Espagne',
        'ET': 'Éthiopie',
        'FI': 'Finlande',
        'FJ': 'Fidji',
        'FK': 'Îles Malouines',
        'FM': 'Micronésie',
        'FO': 'Îles Féroé',
        'FR': 'France',
        'GA': 'Gabon',
        'GB': 'Royaume-Uni',
        'GD': 'Grenade',
        'GE': 'Géorgie',
        'GF': 'Guyane',
        'GG': 'Guernesey',
        'GH': 'Ghana',
        'GI': 'Gibraltar',
        'GL': 'Groenland',
        'GM': 'Gambie',
        'GN': 'Guinée',
        'GP': 'Guadeloupe',
        'GQ': 'Guinée équatoriale',
        'GR': 'Grèce',
        'GS': 'Géorgie du Sud-et-les îles Sandwich du Sud',
        'GT': 'Guatemala',
        'GU': 'Guam',
        'GW': 'Guinée-Bissau',
        'GY': 'Guyana',
        'HK': 'Hong Kong',
        'HM': 'Îles Heard-et-MacDonald',
        'HN': 'Honduras',
        'HR': 'Croatie',
        'HT': 'Haïti',
        'HU': 'Hongrie',
        'ID': 'Indonésie',
        'IE': 'Irlande',
        'IL': 'Israël',
        'IM': 'Île de Man',
        'IN': 'Inde',
        'IO': 'Territoire britannique de l\'océan Indien',
        'IQ': 'Irak',
        'IR': 'Iran',
        'IS': 'Islande',
        'IT': 'Italie',
        'JE': 'Jersey',
        'JM': 'Jamaïque',
        'JO': 'Jordanie',
        'JP': 'Japon',
        'KE': 'Kenya',
        'KG': 'Kirghizistan',
        'KH': 'Cambodge',
        'KI': 'Kiribati',
        'KM': 'Comores',
        'KN': 'Saint-Christophe-et-Niévès',
        'KP': 'Corée du Nord',
        'KR': 'Corée du Sud',
        'KW': 'Koweït',
        'KY': 'Îles Caïmans',
        'KZ': 'Kazakhstan',
        'LA': 'Laos',
        'LB': 'Liban',
        'LC': 'Sainte-Lucie',
        'LI': 'Liechtenstein',
        'LK': 'Sri Lanka',
        'LR': 'Liberia',
        'LS': 'Lesotho',
        'LT': 'Lituanie',
        'LU': 'Luxembourg',
        'LV': 'Lettonie',
        'LY': 'Libye',
        'MA': 'Maroc',
        'MC': 'Monaco',
        'MD': 'Moldavie',
        'ME': 'Monténégro',
        'MF': 'Saint-Martin',
        'MG': 'Madagascar',
        'MH': 'Îles Marshall',
        'MK': 'Macédoine du Nord',
        'ML': 'Mali',
        'MM': 'Birmanie',
        'MN': 'Mongolie',
        'MO': 'Macao',
        'MP': 'Îles Mariannes du Nord',
        'MQ': 'Martinique',
        'MR': 'Mauritanie',
        'MS': 'Montserrat',
        'MT': 'Malte',
        'MU': 'Maurice',
        'MV': 'Maldives',
        'MW': 'Malawi',
        'MX': 'Mexique',
        'MY': 'Malaisie',
        'MZ': 'Mozambique',
        'NA': 'Namibie',
        'NC': 'Nouvelle-Calédonie',
        'NE': 'Niger',
        'NF': 'Île Norfolk',
        'NG': 'Nigeria',
        'NI': 'Nicaragua',
        'NL': 'Pays-Bas',
        'NO': 'Norvège',
        'NP': 'Népal',
        'NR': 'Nauru',
        'NU': 'Niue',
        'NZ': 'Nouvelle-Zélande',
        'OM': 'Oman',
        'PA': 'Panama',
        'PE': 'Pérou',
        'PF': 'Polynésie française',
        'PG': 'Papouasie-Nouvelle-Guinée',
        'PH': 'Philippines',
        'PK': 'Pakistan',
        'PL': 'Pologne',
        'PM': 'Saint-Pierre-et-Miquelon',
        'PN': 'Îles Pitcairn',
        'PR': 'Porto Rico',
        'PS': 'Palestine',
        'PT': 'Portugal',
        'PW': 'Palaos',
        'PY': 'Paraguay',
        'QA': 'Qatar',
        'RE': 'La Réunion',
        'RO': 'Roumanie',
        'RS': 'Serbie',
        'RU': 'Russie',
        'RW': 'Rwanda',
        'SA': 'Arabie saoudite',
        'SB': 'Îles Salomon',
        'SC': 'Seychelles',
        'SD': 'Soudan',
        'SE': 'Suède',
        'SG': 'Singapour',
        'SH': 'Sainte-Hélène',
        'SI': 'Slovénie',
        'SJ': 'Svalbard et Jan Mayen',
        'SK': 'Slovaquie',
        'SL': 'Sierra Leone',
        'SM': 'Saint-Marin',
        'SN': 'Sénégal',
        'SO': 'Somalie',
        'SR': 'Suriname',
        'SS': 'Soudan du Sud',
        'ST': 'Sao Tomé-et-Principe',
        'SV': 'Salvador',
        'SX': 'Saint-Martin (partie néerlandaise)',
        'SY': 'Syrie',
        'SZ': 'Eswatini',
        'TC': 'Îles Turques-et-Caïques',
        'TD': 'Tchad',
        'TF': 'Terres australes françaises',
        'TG': 'Togo',
        'TH': 'Thaïlande',
        'TJ': 'Tadjikistan',
        'TK': 'Tokelau',
        'TL': 'Timor oriental',
        'TM': 'Turkménistan',
        'TN': 'Tunisie',
        'TO': 'Tonga',
        'TR': 'Turquie',
        'TT': 'Trinité-et-Tobago',
        'TV': 'Tuvalu',
        'TW': 'Taïwan',
        'TZ': 'Tanzanie',
        'UA': 'Ukraine',
        'UG': 'Ouganda',
        'UM': 'Îles mineures éloignées des États-Unis',
        'US': 'États-Unis',
        'UY': 'Uruguay',
        'UZ': 'Ouzbékistan',
        'VA': 'Vatican',
        'VC': 'Saint-Vincent-et-les-Grenadines',
        'VE': 'Venezuela',
        'VG': 'Îles Vierges britanniques',
        'VI': 'Îles Vierges des États-Unis',
        'VN': 'Viêt Nam',
        'VU': 'Vanuatu',
        'WF': 'Wallis-et-Futuna',
        'WS': 'Samoa',
        'YE': 'Yémen',
        'YT': 'Mayotte',
        'ZA': 'Afrique du Sud',
        'ZM': 'Zambie',
        'ZW': 'Zimbabwe',
        'EU': 'Union européenne',
        'XA': 'Îles Canaries',
        'XB': 'Pays basque',
        'XC': 'Catalogne',
        'XE': 'Angleterre',
        'XG': 'Galice',
        'XK': 'Kosovo',
        'XP': 'Palestine',
        'XS': 'Écosse',
        'XW': 'Pays de Galles',
        'XX': 'International',
        'other': '$code',
      },
    );
    return '$_temp0';
  }

  @override
  String get countryMapHint =>
      'Touchez un pays pour voir le nombre de parties jouées contre lui. Pincez ou utilisez les boutons pour zoomer.';

  @override
  String countryMapGames(String country, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parties',
      one: '1 partie',
      zero: '0 partie',
    );
    return '$country : $_temp0';
  }

  @override
  String get countryMapLegend => 'Parties jouées';

  @override
  String get countryMapZoomIn => 'Zoomer';

  @override
  String get countryMapZoomOut => 'Dézoomer';

  @override
  String get countryMapReset => 'Revenir à la vue d’ensemble';

  @override
  String countryMapNotShown(String countries) {
    return 'Hors carte : $countries';
  }

  @override
  String countryMapNotShownItem(String country, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parties',
      one: '1 partie',
      zero: '0 partie',
    );
    return '$country ($_temp0)';
  }

  @override
  String countryMapTopRank(String rank) {
    String _temp0 = intl.Intl.selectLogic(
      rank,
      {
        '1': 'Pays le plus rencontré',
        'other': '${rank}e pays le plus rencontré',
      },
    );
    return '$_temp0';
  }
}
