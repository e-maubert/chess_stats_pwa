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
  String get changelogV180 =>
      'Filtres regroupés dans un menu, avec un titre pour chacun\nRésumé des filtres choisis toujours visible sur mobile\nBarre du haut allégée sur mobile et tablette\nSur ordinateur, les filtres restent visibles à gauche';

  @override
  String get changelogV170 =>
      'Partagez les stats d\'un joueur avec un simple lien\nStatistiques sur les parties classées, ou sur toutes au choix\nDéfaites au temps visibles dans la gestion du temps\nBilan du mois plus clair';

  @override
  String get share => 'Partager';

  @override
  String shareText(String username) {
    return 'Les stats de $username sur Chess Stats';
  }

  @override
  String shareRecapText(String username) {
    return 'Le bilan du mois de $username sur Chess Stats';
  }

  @override
  String shareScoutText(String username) {
    return 'Comment battre $username sur Chess Stats';
  }

  @override
  String get shareCopied => 'Lien copié';

  @override
  String get shareLinkTitle => 'Lien à partager';

  @override
  String get playerLoading => 'Chargement des parties…';

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
  String get playingDays => 'Jours de jeu';

  @override
  String get playingDaysHint =>
      'Une case par jour (selon l’heure locale de début des parties), une colonne par semaine. La dernière colonne résume chaque jour de la semaine. Touchez une case pour voir le détail.';

  @override
  String get playingDaysAverageHeader => 'Moy.';

  @override
  String playingDaysWeekdayTitle(String weekday) {
    return 'Tous les ${weekday}s';
  }

  @override
  String playingDaysAverageDetail(String average, int games) {
    return '$average parties par jour en moyenne · $games au total';
  }

  @override
  String get playingDaysBest => 'Meilleur jour :';

  @override
  String get playingDaysWorst => 'Moins bon jour :';

  @override
  String playingDaysWeekendBetter(int weekend, int week) {
    return 'Vous jouez mieux le week-end : $weekend % contre $week % en semaine.';
  }

  @override
  String playingDaysWeekBetter(int weekend, int week) {
    return 'Vous jouez mieux en semaine : $week % contre $weekend % le week-end.';
  }

  @override
  String get playingDaysEven =>
      'Vos résultats sont à peu près les mêmes quel que soit le jour de la semaine.';

  @override
  String playingDaysNoneJudged(int minGames) {
    return 'Pas encore assez de parties par jour de la semaine pour les comparer ($minGames minimum par jour).';
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
        'OpenGame': 'Partie ouverte',
        'ClosedGame': 'Partie fermée',
        'HorwitzDefense': 'Défense Horwitz',
        'EnglundGambit': 'Gambit Englund',
        'NimzowitschDefense': 'Défense Nimzowitsch',
        'OldBenoni': 'Benoni ancienne',
        'ReversedSicilian': 'Sicilienne inversée',
        'SymmetricalEnglish': 'Anglaise symétrique',
        'AngloIndian': 'Défense anglo-indienne',
        'KingsFianchetto': 'Fianchetto du roi',
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

  @override
  String get filtersTitle => 'Filtres';

  @override
  String get filtersOpen => 'Ouvrir le menu';

  @override
  String get filtersReset => 'Réinitialiser';

  @override
  String get filtersDone => 'Voir les stats';

  @override
  String get periodLabel => 'Période';

  @override
  String get menuTitle => 'Menu';

  @override
  String get menuMoreSection => 'Plus';

  @override
  String get showStats => 'Afficher les statistiques';

  @override
  String get scoutButton => 'Comment battre ce joueur';

  @override
  String get scoutIntroLabel => 'Comment battre';

  @override
  String get scoutEmpty => 'Pas assez de parties pour analyser ce joueur';

  @override
  String get scoutSeeStats => 'Voir ses statistiques';

  @override
  String get scoutFormLabel => 'Sa forme du moment';

  @override
  String get scoutFormCollapse => 'En crise';

  @override
  String get scoutFormSlump => 'En difficulté';

  @override
  String get scoutFormSteady => 'Stable';

  @override
  String get scoutFormGood => 'En forme';

  @override
  String get scoutFormLegendary => 'Légendaire';

  @override
  String scoutFormRating(String change, int rating, String timeClass) {
    return '$change points sur ces parties ($timeClass : $rating)';
  }

  @override
  String scoutFormScore(String percent, int games) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$percent de victoires sur ses $games dernières parties',
      one: '$percent de victoires sur sa dernière partie',
    );
    return '$_temp0';
  }

  @override
  String get scoutFormTipCollapse =>
      'Ton adversaire est en pleine crise : mets la pression dès l\'ouverture, la confiance n\'y est pas.';

  @override
  String get scoutFormTipSlump =>
      'Passe difficile : impose ton jeu et pose des problèmes tôt dans la partie.';

  @override
  String get scoutFormTipSteady =>
      'Forme stable : rien à exploiter de ce côté, tout se jouera sur l\'échiquier.';

  @override
  String get scoutFormTipGood =>
      'Ton adversaire est en confiance : joue solide et ne lui laisse pas l\'initiative.';

  @override
  String get scoutFormTipLegendary =>
      'Série légendaire : attends-toi à une partie difficile, reste solide et profite de la moindre erreur.';

  @override
  String scoutCadenceTipSame(String timeClass) {
    return 'Propose une partie en $timeClass : c\'est là que son score est le plus bas.';
  }

  @override
  String scoutCadenceTipOther(String timeClass) {
    return 'Si tu peux choisir la cadence, propose une partie en $timeClass.';
  }

  @override
  String scoutCadenceTipFewGames(String timeClass) {
    return 'Si tu peux choisir la cadence, tente le $timeClass.';
  }

  @override
  String get scoutWhiteLabel => 'Quand ton adversaire a les blancs';

  @override
  String get scoutBlackLabel => 'Quand ton adversaire a les noirs';

  @override
  String get scoutOpeningFavorite => 'son ouverture n° 1';

  @override
  String scoutOpeningGames(int games) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games parties avec cette couleur',
      one: '1 partie avec cette couleur',
    );
    return '$_temp0';
  }

  @override
  String get scoutPlanLabel => 'Ton plan de jeu';

  @override
  String get scoutPlanTitle => 'À retenir';

  @override
  String scoutPlanAsBlack(String tip) {
    return 'Avec les noirs — $tip';
  }

  @override
  String scoutPlanAsWhite(String tip) {
    return 'Avec les blancs — $tip';
  }

  @override
  String scoutIntroBase(int games, String timeClass, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other:
          'On analyse ses $games parties de $timeClass des $days derniers jours : sa cadence principale.',
      one:
          'On analyse sa seule partie de $timeClass des $days derniers jours : sa cadence principale.',
    );
    return '$_temp0';
  }

  @override
  String get scoutCadenceSingle => 'Aucune autre cadence jouée sur la période.';

  @override
  String scoutCadenceSame(String percent) {
    return 'C\'est aussi sa cadence la moins réussie ($percent de victoires).';
  }

  @override
  String scoutCadenceOther(String timeClass, String percent, int games) {
    return 'Sa cadence la moins réussie est le $timeClass : $percent de victoires sur $games parties.';
  }

  @override
  String scoutCadenceOtherRating(String timeClass, int games) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: 'Son classement le plus bas est en $timeClass ($games parties).',
      one: 'Son classement le plus bas est en $timeClass (1 partie).',
    );
    return '$_temp0';
  }

  @override
  String scoutCadenceFewGames(String timeClass, int games) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other:
          'Le $timeClass semble lui poser problème, mais sur $games parties seulement : à confirmer.',
      one:
          'Le $timeClass semble lui poser problème, mais sur 1 seule partie : à confirmer.',
    );
    return '$_temp0';
  }

  @override
  String scoutMainMove(String move, String percent) {
    return 'Premier coup : $move dans $percent de ses parties.';
  }

  @override
  String scoutReplyTarget(
      String move, String reply, String percent, int games) {
    return 'Contre $move, réponds $reply : seulement $percent de victoires pour ton adversaire ($games parties).';
  }

  @override
  String scoutReplyAvoid(String move, String reply, String percent, int games) {
    return 'Contre $move, évite $reply : $percent de victoires pour ton adversaire ($games parties).';
  }

  @override
  String scoutReplyNone(String move) {
    return 'Aucune réponse à $move ne ressort encore : joue celle que tu connais le mieux.';
  }

  @override
  String scoutFirstMoveTarget(String move, String percent, int games) {
    return 'Ouvre par $move : seulement $percent de victoires pour ton adversaire ($games parties).';
  }

  @override
  String scoutFirstMoveAvoid(String move, String percent, int games) {
    return 'Évite d\'ouvrir par $move : $percent de victoires pour ton adversaire ($games parties).';
  }

  @override
  String get scoutFirstMoveNone =>
      'Aucun premier coup ne ressort encore : joue ce que tu connais le mieux.';

  @override
  String scoutMoveWithName(String move, String name) {
    return '$move ($name)';
  }

  @override
  String scoutIntroTitle(String username) {
    return 'Comment battre $username';
  }

  @override
  String scoutIntroTimeClass(String timeClass) {
    String _temp0 = intl.Intl.selectLogic(
      timeClass,
      {
        'bullet': 'en bullet',
        'blitz': 'en blitz',
        'rapid': 'en rapide',
        'other': 'en $timeClass',
      },
    );
    return '$_temp0';
  }

  @override
  String scoutOpeningResults(int games, String percent) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games parties · $percent de victoires',
      one: '1 partie · $percent de victoires',
    );
    return '$_temp0';
  }

  @override
  String get changelogV190 =>
      'Nouveau : « Comment battre ce joueur », ses points faibles et des conseils en diapositives\nSa forme du moment illustrée par une pièce d\'échecs\nDes conseils d\'ouverture sur les coups que tu choisis\nAccueil : « Afficher les statistiques » ou « Comment battre ce joueur »';

  @override
  String get scoutAnalyzing => 'Analyse des parties…';

  @override
  String get scoutNotEnough => 'Pas assez de parties pour conclure';

  @override
  String get scoutPhaseLabel => 'Où ton adversaire craque';

  @override
  String get scoutPhaseExplain =>
      'Parties classées selon la phase où elles se terminent.';

  @override
  String get scoutPhaseTipOpening =>
      'Mets la pression dès l\'ouverture : c\'est là que ton adversaire gagne le moins.';

  @override
  String get scoutPhaseTipMiddlegame =>
      'Garde des pièces et complique le milieu de partie : c\'est là que ton adversaire gagne le moins.';

  @override
  String get scoutPhaseTipEndgame =>
      'Simplifie et vise la finale : c\'est là que ton adversaire gagne le moins.';

  @override
  String get scoutPhaseTipNone =>
      'Aucune phase nettement plus fragile : son niveau est régulier du début à la fin.';

  @override
  String get scoutTimeLabel => 'Sa gestion du temps';

  @override
  String get scoutTimeSlow => 'Lent';

  @override
  String get scoutTimeBalanced => 'Équilibré';

  @override
  String get scoutTimeFast => 'Rapide';

  @override
  String scoutTimeMiddlegame(String gap) {
    return 'Fin de l\'ouverture : $gap du temps initial par rapport à son adversaire';
  }

  @override
  String scoutTimeEndgame(String gap) {
    return 'Entrée en finale : $gap du temps initial';
  }

  @override
  String scoutTimeTimeouts(String percent) {
    return '$percent de ses défaites au temps';
  }

  @override
  String get scoutTimeTipSlow =>
      'Joue vite et garde la pression à la pendule : le temps est son point faible.';

  @override
  String get scoutTimeTipBalanced =>
      'Gestion du temps équilibrée : pas de piège à la pendule, tout se jouera sur l\'échiquier.';

  @override
  String get scoutTimeTipFast =>
      'Ton adversaire joue vite : prends ton temps et cherche des positions complexes.';

  @override
  String get scoutTiltLabel => 'Après une défaite';

  @override
  String get scoutTiltTilts => 'Ça le déstabilise';

  @override
  String get scoutTiltSteady => 'Rien ne change';

  @override
  String get scoutTiltResilient => 'Ça le motive';

  @override
  String get scoutTiltAfterRow => 'Juste après une défaite';

  @override
  String get scoutTiltUsualRow => 'D\'habitude';

  @override
  String get scoutTiltExplain =>
      'Parties commencées moins d\'une heure après une défaite.';

  @override
  String get scoutTiltTipTilts =>
      'Si tu gagnes, propose vite une revanche : juste après une défaite, ton adversaire gagne beaucoup moins.';

  @override
  String get scoutTiltTipResilient =>
      'Méfie-toi de la revanche : juste après une défaite, ton adversaire gagne encore plus.';

  @override
  String get scoutTiltTipSteady =>
      'Une défaite ne change rien à son jeu : pas d\'effet revanche à attendre.';

  @override
  String get scoutHoursLabel => 'Selon l\'heure';

  @override
  String get scoutHoursCaption => 'son moment le plus fragile';

  @override
  String get scoutHoursExplain =>
      'Heure de début des parties, à l\'heure de ton appareil.';

  @override
  String get scoutDayPartMorning => 'Le matin';

  @override
  String get scoutDayPartAfternoon => 'L\'après-midi';

  @override
  String get scoutDayPartEvening => 'Le soir';

  @override
  String get scoutDayPartNight => 'La nuit';

  @override
  String get scoutDayPartMorningRow => 'Matin (5 h – 12 h)';

  @override
  String get scoutDayPartAfternoonRow => 'Après-midi (12 h – 18 h)';

  @override
  String get scoutDayPartEveningRow => 'Soir (18 h – 22 h)';

  @override
  String get scoutDayPartNightRow => 'Nuit (22 h – 5 h)';

  @override
  String scoutHoursTipMorning(String percent) {
    return 'Si tu peux, joue-le le matin : seulement $percent de victoires pour ton adversaire.';
  }

  @override
  String scoutHoursTipAfternoon(String percent) {
    return 'Si tu peux, joue-le l\'après-midi : seulement $percent de victoires pour ton adversaire.';
  }

  @override
  String scoutHoursTipEvening(String percent) {
    return 'Si tu peux, joue-le le soir : seulement $percent de victoires pour ton adversaire.';
  }

  @override
  String scoutHoursTipNight(String percent) {
    return 'Si tu peux, joue-le la nuit : seulement $percent de victoires pour ton adversaire.';
  }

  @override
  String get scoutHoursTipNone => 'L\'heure ne change rien à son niveau.';

  @override
  String get scoutPhaseNone => 'Aucune phase fragile';

  @override
  String get scoutHoursNone => 'Aucun moment fragile';

  @override
  String get changelogV1100 =>
      '« Comment battre ce joueur » : la phase où ton adversaire craque\nSa gestion du temps et sa réaction après une défaite\nSes moments de la journée les plus fragiles\nUn plan de jeu plus complet';

  @override
  String get changelogV1110 =>
      'Partage le bilan du mois ou « Comment battre ce joueur » avec leur propre lien\nUn lien vers des stats ouvre directement les stats\nLe bilan du mois ne se lance tout seul qu\'après une recherche';

  @override
  String scoutIntroBaseChosen(int games, String timeClass, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other:
          'On analyse ses $games parties de $timeClass des $days derniers jours.',
      one: 'On analyse sa seule partie de $timeClass des $days derniers jours.',
    );
    return '$_temp0';
  }

  @override
  String scoutAnalyzeTimeClass(String timeClass) {
    String _temp0 = intl.Intl.selectLogic(
      timeClass,
      {
        'bullet': 'Analyser le bullet',
        'blitz': 'Analyser le blitz',
        'rapid': 'Analyser le rapide',
        'other': 'Analyser le $timeClass',
      },
    );
    return '$_temp0';
  }

  @override
  String scoutCadenceSameChosen(String percent) {
    return 'C\'est sa cadence la moins réussie ($percent de victoires).';
  }

  @override
  String get changelogV1120 =>
      '« Comment battre ce joueur » : choisis la cadence à analyser\nUn raccourci vers sa cadence la moins réussie\nUn lien à partager pour chaque cadence\nDiaporama plus court quand il y a trop peu de parties pour conclure';

  @override
  String get changelogV1130 =>
      'Nouvel onglet « Axes d\'amélioration », à côté des stats\n« Améliorer son ouverture » : le coup que tu répètes et qui te coûte l\'avantage, avec le meilleur coup à jouer\nUn échiquier aux couleurs de l\'app pour voir la position en un coup d\'œil\nRien à corriger ? L\'app te dit que ton ouverture tient la route';

  @override
  String get changelogV1140 =>
      'Nouvelle carte « Jours de jeu » : tes parties jour par jour, façon calendrier\nDécouvre si tu joues mieux le week-end ou en semaine\n« Améliorer son ouverture » : rejoue les coups jusqu\'à la position à corriger\nAnalyse de tes ouvertures bien plus rapide dès la deuxième visite';

  @override
  String get tabStats => 'Stats';

  @override
  String get tabImprovement => 'Axes d\'amélioration';

  @override
  String get improvementFiltersNote =>
      'Les filtres ne s\'appliquent pas encore ici : l\'analyse porte sur ta cadence la plus jouée, sur les 3 derniers mois (parties classées).';

  @override
  String get improvementFiltersSummary => 'Cadence la plus jouée · 3 mois';

  @override
  String get openingImprovementTitle => 'Améliorer son ouverture';

  @override
  String openingImprovementScope(String timeClass) {
    return '$timeClass · 3 derniers mois · parties classées';
  }

  @override
  String get openingImprovementIntro =>
      'Dans ton ouverture la plus jouée avec chaque couleur, on cherche un coup que tu répètes et qui te fait perdre l\'avantage, et le coup à jouer à la place.';

  @override
  String get openingImprovementNoGames =>
      'Aucune partie classée sur les 3 derniers mois.';

  @override
  String get openingImprovementError =>
      'L\'analyse des positions est indisponible pour le moment. Réessaie dans une minute.';

  @override
  String get openingImprovementSource =>
      'Évaluations du moteur : base cloud de Lichess.';

  @override
  String openingImprovementLoading(String percent) {
    return 'Analyse de tes ouvertures… $percent';
  }

  @override
  String get openingImprovementNoColorGames =>
      'Aucune partie avec cette couleur.';

  @override
  String openingImprovementColorHeader(
      String color, String opening, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parties',
      one: '$count partie',
    );
    return '$color : $opening ($_temp0)';
  }

  @override
  String get openingImprovementNotEnough =>
      'Pas assez de parties dans cette ouverture pour repérer un coup répété.';

  @override
  String get openingImprovementSolid =>
      'Ton ouverture tient la route : aucun coup répété ne te fait perdre l\'avantage.';

  @override
  String get sanPieceLetters => 'CFTDR';

  @override
  String openingImprovementBoardLabel(String move, String best) {
    return 'Échiquier : ton coup $move (flèche rouge), meilleur coup $best (flèche verte)';
  }

  @override
  String get openingImprovementAtStart => 'Dès ton premier coup :';

  @override
  String openingImprovementAfter(String line) {
    return 'Après $line :';
  }

  @override
  String openingImprovementYouPlay(String move) {
    return 'Tu joues souvent $move';
  }

  @override
  String openingImprovementRepeats(int count, num losses) {
    String _temp0 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: 'dont $losses défaites',
      one: 'dont $losses défaite',
      zero: 'aucune défaite',
    );
    return '$count fois, $_temp0';
  }

  @override
  String openingImprovementBetter(String move) {
    return 'Mieux : $move';
  }

  @override
  String openingImprovementEval(String before, String after) {
    return 'Évaluation du moteur : $before avant ton coup, $after après.';
  }

  @override
  String get openingReplayStart => 'Position de départ';

  @override
  String get openingReplayPrevious => 'Coup précédent';

  @override
  String get openingReplayNext => 'Coup suivant';

  @override
  String get openingReplayPlay => 'Rejouer l\'ouverture';

  @override
  String get openingReplayPause => 'Pause';

  @override
  String get openingReplayMistake => 'Position à corriger';
}
