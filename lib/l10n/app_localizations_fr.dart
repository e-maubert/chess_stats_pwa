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
  String get searchHint => 'ex : Hikaru';

  @override
  String removeRecentPlayer(String username) {
    return 'Retirer $username de la liste';
  }

  @override
  String get refresh => 'Actualiser';

  @override
  String get retry => 'Réessayer';

  @override
  String get periodOneMonth => '1 mois';

  @override
  String get periodThreeMonths => '3 mois';

  @override
  String periodRange(String start, String end) {
    return 'du $start au $end';
  }

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
  String get colorStats => 'Statistiques de victoire';

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
  String get countryRankColumn => '#';

  @override
  String get countryColumn => 'Pays';

  @override
  String get opponentsColumn => 'Adversaires';

  @override
  String get timeClassLabel => 'Cadence';

  @override
  String get timeClassAll => 'Toutes';

  @override
  String get timeClassBullet => 'Bullet';

  @override
  String get timeClassBlitz => 'Blitz';

  @override
  String get timeClassRapid => 'Rapide';

  @override
  String get noCountryData => 'Aucune partie pour cette cadence';

  @override
  String get countryStatsLoading => 'Recherche du pays de vos adversaires…';

  @override
  String get openingColumn => 'Ouverture';

  @override
  String get ratingEvolution => 'Évolution du classement';

  @override
  String get ratingCurrent => 'Classement actuel';

  @override
  String get ratingSincePeriodStart => 'depuis la 1re partie de la période';

  @override
  String get noRatingData => 'Aucune partie classée pour cette cadence';

  @override
  String countryResultRates(String win, String draw, String loss) {
    return 'V $win · N $draw · D $loss';
  }

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
  String get timeTimeout => 'Perdu au temps';

  @override
  String get timeBehind => 'En retard à la pendule';

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
  String countryMapGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parties',
      one: '1 partie',
      zero: '0 partie',
    );
    return '$_temp0';
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

  @override
  String get countryMapModeGames => 'Parties jouées';

  @override
  String get countryMapModePerformance => 'Performance';

  @override
  String get countryMapPerformanceHint =>
      'Touchez un pays pour voir votre performance contre lui. Pincez ou utilisez les boutons pour zoomer.';

  @override
  String get countryMapPerformanceLegend => 'Performance';

  @override
  String countryMapPercent(int percent) {
    return '$percent %';
  }

  @override
  String countryMapPerformanceTitle(String country, int percent) {
    return '$country · $percent %';
  }

  @override
  String countryMapPerformanceDetail(
      int games, int wins, int draws, int losses) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games parties',
      one: '1 partie',
    );
    return '$_temp0 · V $wins · N $draws · D $losses';
  }

  @override
  String countryMapNotEnoughDetail(int games) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games parties',
      one: '1 partie',
      zero: '0 partie',
    );
    return '$_temp0 · pas assez pour juger';
  }

  @override
  String countryMapGroup(String countries) {
    return '$countries : touchez pour zoomer';
  }

  @override
  String countryMapNotEnoughLegend(int minGames) {
    return 'Moins de $minGames parties : pas assez pour juger';
  }

  @override
  String countryMapNoneJudged(int minGames) {
    return 'Aucun pays n\'a encore assez de parties pour juger la performance ($minGames minimum).';
  }

  @override
  String get countryMapStrengths => 'Points forts : ';

  @override
  String get countryMapWeaknesses => 'Points faibles : ';

  @override
  String get countryMapNoStrength => 'aucun sur la période';

  @override
  String get countryMapNoWeakness => 'aucun sur la période';

  @override
  String countryMapSummaryItem(String country, int percent) {
    return '$country $percent %';
  }

  @override
  String countryMapStrengthRank(String rank) {
    String _temp0 = intl.Intl.selectLogic(
      rank,
      {
        '1': 'Meilleure performance',
        'other': '${rank}e meilleure performance',
      },
    );
    return '$_temp0';
  }

  @override
  String countryMapWeaknessRank(String rank) {
    String _temp0 = intl.Intl.selectLogic(
      rank,
      {
        '1': 'Performance la plus faible',
        'other': '${rank}e performance la plus faible',
      },
    );
    return '$_temp0';
  }

  @override
  String paginationRange(int first, int last, int total) {
    return '$first–$last sur $total';
  }

  @override
  String get previousPage => 'Page précédente';

  @override
  String get nextPage => 'Page suivante';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get whatsNew => 'Nouveautés';

  @override
  String get close => 'Fermer';

  @override
  String changelogVersionTitle(String version, String date) {
    return 'Version $version – $date';
  }

  @override
  String get changelogV160 =>
      'Votre bilan du mois en diapositives, à la première recherche d\'un joueur, et à revoir depuis la page des stats\nFiltres communs en haut de la page : cadence, couleur et ouverture\nNoms des ouvertures traduits et mieux regroupés\nUne courbe de classement par cadence, et par couleur';

  @override
  String get changelogV150 =>
      'Nouvelle carte « Phases de la partie » : où se jouent vos parties, de l\'ouverture à la finale\nVotre temps restant face à celui de l\'adversaire, d\'un coup d\'œil, à la sortie de l\'ouverture et en finale\nVos résultats en finale selon le matériel et le type de finale\nPage affichée plus vite : les statistiques les plus longues arrivent juste après';

  @override
  String get changelogV140 =>
      'Statistiques sur 1 mois ou 3 mois glissants, au choix\nAffichage plus rapide : les parties d\'un joueur sont gardées dans le navigateur\nRecherche : les joueurs déjà consultés sont proposés\nPage plus claire et plus compacte, surtout sur mobile';

  @override
  String get changelogV130 =>
      'Nouvelle carte « Heures de jeu » : cadran de 24 h des parties du mois selon leur heure de début, à l\'heure locale\nMode « Activité » : nombre de parties par heure, en dégradé de bleu\nMode « Performance » : score par heure, du rouge au vert en passant par le jaune (5 parties minimum par heure)\nMeilleur et moins bon créneau : un clic les montre sur le cadran\nToucher une heure affiche son détail dans une bulle';

  @override
  String get changelogV121 =>
      'Chargement plus rapide : le pays de chaque adversaire n\'est demandé qu\'une fois, plusieurs à la fois, et mémorisé un mois dans le navigateur';

  @override
  String get changelogV120 =>
      'Carte des pays : nouvelle carte « Performance », du rouge (défaites) au vert (victoires) en passant par le jaune (équilibre)\nPays trop peu joués en gris : 2 parties minimum, 3 au-delà de 40 parties dans le mois\nPoints forts et points faibles : marqueurs sur la carte et résumé sous la légende';

  @override
  String get changelogV110 =>
      'Affichage sur ordinateur : statistiques sur deux colonnes sur grand écran\nTitre centré sur toutes les pages\nOuvertures jouées et pays rencontrés : tableaux paginés, 5 lignes par page\nPied de page avec le numéro de version et les nouveautés';

  @override
  String get changelogV100 =>
      'Statistiques du mois en cours : par couleur, par ouverture, évolution du classement, gestion du temps, causes des défaites\nStatistiques par pays des adversaires, avec carte du monde\nMode clair / sombre\nApplication en français et en anglais';

  @override
  String get playingHours => 'Heures de jeu';

  @override
  String get playingHoursModeActivity => 'Activité';

  @override
  String get playingHoursModePerformance => 'Performance';

  @override
  String get playingHoursHint =>
      'Une tranche par heure, selon l’heure de début des parties (heure locale). Touchez une heure pour voir le détail.';

  @override
  String playingHoursHourLabel(int hour) {
    return '$hour h';
  }

  @override
  String playingHoursRange(int start, int end) {
    return '$start h – $end h';
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
      other: '$games parties',
      one: '1 partie',
    );
    return '$percent % · $_temp0 · V $wins · N $draws · D $losses';
  }

  @override
  String playingHoursNotEnoughDetail(int games, int minGames) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games parties',
      one: '1 partie',
      zero: '0 partie',
    );
    return '$_temp0, pas assez pour juger ($minGames minimum)';
  }

  @override
  String get playingHoursBandVeryLow => 'Moins de 40 %';

  @override
  String get playingHoursBandLow => '40 à 46 %';

  @override
  String get playingHoursBandEven => '46 à 54 %';

  @override
  String get playingHoursBandHigh => '54 à 60 %';

  @override
  String get playingHoursBandVeryHigh => 'Plus de 60 %';

  @override
  String get playingHoursBest => 'Meilleur créneau :';

  @override
  String get playingHoursWorst => 'Moins bon créneau :';

  @override
  String playingHoursSlot(String range, int percent, int games) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games parties',
      one: '1 partie',
    );
    return '$range ($percent %, $_temp0)';
  }

  @override
  String playingHoursNoneJudged(int minGames) {
    return 'Aucune heure n’a encore assez de parties pour juger la performance ($minGames minimum).';
  }

  @override
  String get gamePhases => 'Phases de la partie';

  @override
  String gamePhasesLoading(String percent) {
    return 'Analyse de vos parties… $percent';
  }

  @override
  String get noPhaseData => 'Aucune partie analysée pour cette cadence';

  @override
  String get phaseEndTitle => 'Où se terminent vos parties';

  @override
  String get phaseOpening => 'Dans l\'ouverture';

  @override
  String get phaseMiddlegame => 'En milieu de partie';

  @override
  String get phaseEndgame => 'En finale';

  @override
  String phaseTimeoutLosses(int count) {
    return 'Dont $count perdues au temps';
  }

  @override
  String get phaseClockTitle => 'Temps restant';

  @override
  String get phaseClockMiddlegame => 'Fin de l\'ouverture';

  @override
  String get phaseClockEndgame => 'Entrée en finale';

  @override
  String get phaseClockPlayer => 'Vous';

  @override
  String get phaseClockOpponent => 'Adversaire';

  @override
  String get phaseClockNote =>
      'En moyenne, en part du temps initial (parties à la pendule uniquement).';

  @override
  String get endgameMaterialTitle => 'Vos finales selon le matériel';

  @override
  String get endgameMaterialAhead => 'Avec plus de matériel';

  @override
  String get endgameMaterialEqual => 'À égalité de matériel';

  @override
  String get endgameMaterialBehind => 'Avec moins de matériel';

  @override
  String get endgameTypeTitle => 'Par type de finale';

  @override
  String get endgameTypePawn => 'Finales de pions';

  @override
  String get endgameTypeMinor => 'Finales de pièces mineures';

  @override
  String get endgameTypeRook => 'Finales de tours';

  @override
  String get endgameTypeRookMinor => 'Tours et pièces mineures';

  @override
  String get endgameTypeQueen => 'Finales de dames';

  @override
  String get endgameTypeQueenOther => 'Dames et autres pièces';

  @override
  String get phaseClockLegendPlayer => 'Votre temps restant (moitié haute) :';

  @override
  String get phaseClockLegendOpponent =>
      'Temps restant de l\'adversaire (moitié basse)';

  @override
  String get phaseClockLegendElapsed => 'Temps écoulé';

  @override
  String get phaseClockLegendAhead =>
      'Plus que l\'adversaire (écart de plus de 10 % du temps initial)';

  @override
  String get phaseClockLegendBalanced =>
      'À peu près autant que l\'adversaire (écart de 10 % ou moins)';

  @override
  String get phaseClockLegendBehind =>
      'Moins que l\'adversaire (écart de plus de 10 % du temps initial)';

  @override
  String get ratedFilterLabel => 'Parties prises en compte';

  @override
  String get ratedFilterRated => 'Parties classées';

  @override
  String get ratedFilterAll => 'Toutes les parties';

  @override
  String get colorFilterLabel => 'Couleur jouée';

  @override
  String get colorFilterBoth => 'Les deux';

  @override
  String get colorFilterWhite => 'Blancs';

  @override
  String get colorFilterBlack => 'Noirs';

  @override
  String get allGames => 'Toutes les parties';

  @override
  String resultRateWithCount(String rate, int count) {
    return '$rate ($count)';
  }

  @override
  String get ratingTrendWhite =>
      'Points de classement gagnés ou perdus avec les blancs';

  @override
  String get ratingTrendBlack =>
      'Points de classement gagnés ou perdus avec les noirs';

  @override
  String ratingTrendPoints(String points) {
    return '$points pts';
  }

  @override
  String ratingTrendGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sur $count parties',
      one: 'sur 1 partie',
    );
    return '$_temp0';
  }

  @override
  String get ratingTrendNotEnough =>
      'Pas assez de parties classées pour calculer la tendance';

  @override
  String openingFamilyName(String family, String fallback) {
    String _temp0 = intl.Intl.selectLogic(
      family,
      {
        'QueensPawn': 'Partie du pion dame',
        'QueensGambit': 'Gambit dame',
        'SicilianDefense': 'Défense sicilienne',
        'RuyLopez': 'Partie espagnole',
        'EnglishOpening': 'Ouverture anglaise',
        'FrenchDefense': 'Défense française',
        'DutchDefense': 'Défense hollandaise',
        'KingsGambit': 'Gambit du roi',
        'CaroKann': 'Défense Caro-Kann',
        'ViennaGame': 'Partie viennoise',
        'TwoKnights': 'Défense des deux cavaliers',
        'GiuocoPiano': 'Giuoco piano',
        'ItalianGame': 'Partie italienne',
        'AlekhinesDefense': 'Défense Alekhine',
        'RetiOpening': 'Ouverture Réti',
        'RetiAccepted': 'Réti acceptée',
        'PircDefense': 'Défense Pirc',
        'KingsPawn': 'Partie du pion roi',
        'FourKnights': 'Partie des quatre cavaliers',
        'PetrovDefense': 'Défense Petrov',
        'PetrovsDefense': 'Défense Petrov',
        'KingsKnights': 'Ouverture du cavalier roi',
        'KingsIndian': 'Indienne du roi',
        'QueensIndian': 'Défense indienne de la dame',
        'NimzoIndian': 'Défense nimzo-indienne',
        'BogoIndian': 'Défense bogo-indienne',
        'IndianGame': 'Partie indienne',
        'CenterGame': 'Partie du centre',
        'BishopsOpening': 'Ouverture du fou',
        'BirdsOpening': 'Ouverture Bird',
        'ScotchGame': 'Partie écossaise',
        'ScandinavianDefense': 'Défense scandinave',
        'RobatschDefense': 'Défense moderne (Robatsch)',
        'ModernDefense': 'Défense moderne',
        'PhilidorDefense': 'Défense Philidor',
        'NimzowitschLarsen': 'Attaque Nimzowitsch-Larsen',
        'AnderssenOpening': 'Ouverture Anderssen',
        'LondonSystem': 'Système de Londres',
        'ColleSystem': 'Système Colle',
        'TrompowskyAttack': 'Attaque Trompowsky',
        'GrunfeldDefense': 'Défense Grünfeld',
        'SlavDefense': 'Défense slave',
        'SemiSlav': 'Défense semi-slave',
        'CatalanOpening': 'Ouverture catalane',
        'BenoniDefense': 'Défense Benoni',
        'BenkoGambit': 'Gambit Benko',
        'OwensDefense': 'Défense Owen',
        'PolishOpening': 'Ouverture polonaise',
        'ZukertortOpening': 'Ouverture Zukertort',
        'PonzianiOpening': 'Ouverture Ponziani',
        'EvansGambit': 'Gambit Evans',
        'DanishGambit': 'Gambit danois',
        'UnknownOpening': 'Ouverture inconnue',
        'UncommonOpening': 'Début irrégulier',
        'KingsIndianAttack': 'Attaque indienne du roi',
        'BudapestGambit': 'Gambit de Budapest',
        'OldIndian': 'Vieille défense indienne',
        'KingsKnight': 'Ouverture du cavalier roi',
        'ThreeKnights': 'Partie des trois cavaliers',
        'VeresovAttack': 'Attaque Veresov',
        'TorreAttack': 'Attaque Torre',
        'other': '$fallback',
      },
    );
    return '$_temp0';
  }

  @override
  String get openingFilterLabel => 'Ouverture';

  @override
  String get openingFilterAll => 'Toutes les ouvertures';

  @override
  String get openingFilterOthers => 'Autres ouvertures';

  @override
  String openingOptionCount(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get ratingTrendSelection =>
      'Points de classement gagnés ou perdus sur les parties sélectionnées';

  @override
  String get slidesPrevious => 'Précédent';

  @override
  String get slidesNext => 'Suivant';

  @override
  String get recapSkip => 'Passer';

  @override
  String get recapSeeStats => 'Voir toutes les stats';

  @override
  String get recapIntroLabel => 'Ton mois sur chess.com';

  @override
  String recapIntroTitle(String username) {
    return '$username, voici tes 30 derniers jours';
  }

  @override
  String get recapIntroHint => 'Touche ou fais glisser pour continuer';

  @override
  String get recapGamesLabel => 'Parties jouées';

  @override
  String recapWins(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count victoires',
      one: '$count victoire',
    );
    return '$_temp0';
  }

  @override
  String recapDraws(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nulles',
      one: '$count nulle',
    );
    return '$_temp0';
  }

  @override
  String recapLosses(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count défaites',
      one: '$count défaite',
    );
    return '$_temp0';
  }

  @override
  String get recapScoreLabel => 'Tes résultats';

  @override
  String get recapScoreCaption => 'de parties gagnées';

  @override
  String get recapReplay => 'Revoir le bilan du mois';

  @override
  String get recapTimeClassLabel => 'Ta cadence préférée';

  @override
  String get recapTimeClassDaily => 'Correspondance';

  @override
  String recapGamesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parties',
      one: '$count partie',
    );
    return '$_temp0';
  }

  @override
  String recapRatingChange(String change) {
    return 'Classement : $change sur le mois';
  }

  @override
  String recapPeakRating(int rating) {
    return 'Plus haut : $rating';
  }

  @override
  String get recapStreakLabel => 'Plus longue série de victoires';

  @override
  String get recapStreakCaption => 'victoires d\'affilée';

  @override
  String get recapStreakCaptionHot => 'victoires d\'affilée. Inarrêtable !';

  @override
  String get recapOpeningLabel => 'Ton ouverture fétiche';

  @override
  String recapOpeningCaption(num count, String percent) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parties',
      one: '$count partie',
    );
    return '$_temp0 · $percent de victoires';
  }

  @override
  String get recapBestOpeningLabel => 'Ton arme secrète';

  @override
  String get recapHourLabel => 'Ton heure préférée pour jouer';

  @override
  String recapHourValue(int hour) {
    return '$hour h';
  }

  @override
  String recapBusiestDay(String date, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parties',
      one: '$count partie',
    );
    return 'Journée record : $date, $_temp0';
  }

  @override
  String get recapOpponentLabel => 'Ton adversaire le plus fréquent';

  @override
  String recapOpponentCaption(int count, int wins, int draws, int losses) {
    return '$count parties ensemble · $wins V, $draws N, $losses D';
  }

  @override
  String get recapWeakOpeningLabel => 'L\'ouverture qui te résiste';

  @override
  String get recapOutroLabel => 'Voilà ton mois';

  @override
  String get recapOutroTitle => 'Envie d\'aller plus loin ?';

  @override
  String get recapEmptyTitle => 'Aucune partie ces 30 derniers jours';

  @override
  String get recapHourEarlyBird => 'Lève-tôt : les échecs avant le café !';

  @override
  String get recapHourMorning => 'Tu commences la journée par une partie.';

  @override
  String get recapHourLunch => 'Une partie pendant la pause déjeuner ?';

  @override
  String get recapHourAfternoon => 'L\'après-midi, c\'est ton moment.';

  @override
  String get recapHourEvening => 'Ta partie du soir, c\'est sacré.';

  @override
  String get recapHourNightOwl => 'Un vrai oiseau de nuit !';

  @override
  String get recapVolumeCasual => 'Tranquille : une partie de temps en temps.';

  @override
  String recapVolumeRegular(int count) {
    return 'Un rythme régulier, environ $count par semaine.';
  }

  @override
  String get recapVolumeEveryDay => 'Tu joues presque tous les jours !';

  @override
  String recapVolumeEnthusiast(int count) {
    return 'Accro aux échecs : $count parties par jour en moyenne.';
  }

  @override
  String get recapVolumeNonStop => 'Ton échiquier ne refroidit jamais.';

  @override
  String get recapScoreDominant => 'Tu écrases la concurrence.';

  @override
  String get recapScoreWinning =>
      'Plus de victoires que de défaites : bien joué !';

  @override
  String get recapScoreBalanced =>
      'À l\'équilibre : chaque partie se joue à peu de chose.';

  @override
  String get recapScoreTough => 'Un mois difficile, le prochain sera meilleur.';

  @override
  String get recapScoreLearning =>
      'Un mois pour apprendre : chaque défaite est une leçon.';
}
