import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Chess Stats'**
  String get appTitle;

  /// No description provided for @appLogo.
  ///
  /// In en, this message translates to:
  /// **'Chess Stats logo'**
  String get appLogo;

  /// Titre de la page de statistiques, avec le pseudo du joueur
  ///
  /// In en, this message translates to:
  /// **'Chess Stats: {username}'**
  String statsTitle(String username);

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your Chess.com username'**
  String get enterUsername;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Hikaru'**
  String get searchHint;

  /// Tooltip of the cross next to an already viewed player, under the search field
  ///
  /// In en, this message translates to:
  /// **'Remove {username} from the list'**
  String removeRecentPlayer(String username);

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @periodOneMonth.
  ///
  /// In en, this message translates to:
  /// **'1 month'**
  String get periodOneMonth;

  /// No description provided for @periodThreeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get periodThreeMonths;

  /// Exact dates of the selected period, under the period selector
  ///
  /// In en, this message translates to:
  /// **'from {start} to {end}'**
  String periodRange(String start, String end);

  /// No description provided for @switchToDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark mode'**
  String get switchToDarkMode;

  /// No description provided for @switchToLightMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to light mode'**
  String get switchToLightMode;

  /// No description provided for @errorFetchingStats.
  ///
  /// In en, this message translates to:
  /// **'Error fetching statistics'**
  String get errorFetchingStats;

  /// No description provided for @playedOpenings.
  ///
  /// In en, this message translates to:
  /// **'Played openings'**
  String get playedOpenings;

  /// No description provided for @gamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Games Played'**
  String get gamesPlayed;

  /// No description provided for @wins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get wins;

  /// No description provided for @losses.
  ///
  /// In en, this message translates to:
  /// **'Losses'**
  String get losses;

  /// No description provided for @draws.
  ///
  /// In en, this message translates to:
  /// **'Draws'**
  String get draws;

  /// No description provided for @colorStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics by Color'**
  String get colorStats;

  /// No description provided for @withWhite.
  ///
  /// In en, this message translates to:
  /// **'With White'**
  String get withWhite;

  /// No description provided for @withBlack.
  ///
  /// In en, this message translates to:
  /// **'With Black'**
  String get withBlack;

  /// No description provided for @countryStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics by Country'**
  String get countryStats;

  /// No description provided for @played.
  ///
  /// In en, this message translates to:
  /// **'Games Played: {count}'**
  String played(int count);

  /// No description provided for @countryRankColumn.
  ///
  /// In en, this message translates to:
  /// **'#'**
  String get countryRankColumn;

  /// No description provided for @countryColumn.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryColumn;

  /// No description provided for @opponentsColumn.
  ///
  /// In en, this message translates to:
  /// **'Opponents'**
  String get opponentsColumn;

  /// No description provided for @timeClassLabel.
  ///
  /// In en, this message translates to:
  /// **'Time control'**
  String get timeClassLabel;

  /// No description provided for @timeClassAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get timeClassAll;

  /// No description provided for @timeClassBullet.
  ///
  /// In en, this message translates to:
  /// **'Bullet'**
  String get timeClassBullet;

  /// No description provided for @timeClassBlitz.
  ///
  /// In en, this message translates to:
  /// **'Blitz'**
  String get timeClassBlitz;

  /// No description provided for @timeClassRapid.
  ///
  /// In en, this message translates to:
  /// **'Rapid'**
  String get timeClassRapid;

  /// No description provided for @noCountryData.
  ///
  /// In en, this message translates to:
  /// **'No games for this time control'**
  String get noCountryData;

  /// No description provided for @countryStatsLoading.
  ///
  /// In en, this message translates to:
  /// **'Looking up your opponents\' countries…'**
  String get countryStatsLoading;

  /// No description provided for @openingColumn.
  ///
  /// In en, this message translates to:
  /// **'Opening'**
  String get openingColumn;

  /// No description provided for @ratingEvolution.
  ///
  /// In en, this message translates to:
  /// **'Rating progress'**
  String get ratingEvolution;

  /// No description provided for @ratingCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current rating'**
  String get ratingCurrent;

  /// No description provided for @ratingSincePeriodStart.
  ///
  /// In en, this message translates to:
  /// **'since the first game of the period'**
  String get ratingSincePeriodStart;

  /// No description provided for @noRatingData.
  ///
  /// In en, this message translates to:
  /// **'No rated games for this time control'**
  String get noRatingData;

  /// No description provided for @countryResultRates.
  ///
  /// In en, this message translates to:
  /// **'W {win} · D {draw} · L {loss}'**
  String countryResultRates(String win, String draw, String loss);

  /// No description provided for @lossBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Losses by type'**
  String get lossBreakdown;

  /// No description provided for @lossByTimeout.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get lossByTimeout;

  /// No description provided for @lossByCheckmate.
  ///
  /// In en, this message translates to:
  /// **'By checkmate'**
  String get lossByCheckmate;

  /// No description provided for @lossByResignation.
  ///
  /// In en, this message translates to:
  /// **'By resignation'**
  String get lossByResignation;

  /// No description provided for @lossOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get lossOther;

  /// No description provided for @noLossData.
  ///
  /// In en, this message translates to:
  /// **'No losses for this time control'**
  String get noLossData;

  /// No description provided for @lossCauseValue.
  ///
  /// In en, this message translates to:
  /// **'{count} ({percent})'**
  String lossCauseValue(int count, String percent);

  /// No description provided for @timeManagement.
  ///
  /// In en, this message translates to:
  /// **'Time management in losses'**
  String get timeManagement;

  /// No description provided for @timeGapAverage.
  ///
  /// In en, this message translates to:
  /// **'When you lose, this is your average clock gap with the opponent at the end of the game:'**
  String get timeGapAverage;

  /// No description provided for @timeBehind.
  ///
  /// In en, this message translates to:
  /// **'Behind on the clock'**
  String get timeBehind;

  /// No description provided for @timeBalanced.
  ///
  /// In en, this message translates to:
  /// **'Even on the clock'**
  String get timeBalanced;

  /// No description provided for @timeAhead.
  ///
  /// In en, this message translates to:
  /// **'Ahead on the clock'**
  String get timeAhead;

  /// No description provided for @timeThresholdNote.
  ///
  /// In en, this message translates to:
  /// **'Significant gap: more than 10% of the initial time'**
  String get timeThresholdNote;

  /// No description provided for @countryUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown country'**
  String get countryUnknown;

  /// Nom du pays à partir de son code chess.com (ISO 3166-1 ou code spécial X…).
  ///
  /// In en, this message translates to:
  /// **'{code, select, AD{Andorra} AE{United Arab Emirates} AF{Afghanistan} AG{Antigua and Barbuda} AI{Anguilla} AL{Albania} AM{Armenia} AO{Angola} AQ{Antarctica} AR{Argentina} AS{American Samoa} AT{Austria} AU{Australia} AW{Aruba} AX{Åland Islands} AZ{Azerbaijan} BA{Bosnia and Herzegovina} BB{Barbados} BD{Bangladesh} BE{Belgium} BF{Burkina Faso} BG{Bulgaria} BH{Bahrain} BI{Burundi} BJ{Benin} BL{Saint Barthélemy} BM{Bermuda} BN{Brunei} BO{Bolivia} BQ{Caribbean Netherlands} BR{Brazil} BS{Bahamas} BT{Bhutan} BV{Bouvet Island} BW{Botswana} BY{Belarus} BZ{Belize} CA{Canada} CC{Cocos (Keeling) Islands} CD{DR Congo} CF{Central African Republic} CG{Congo} CH{Switzerland} CI{Côte d\'Ivoire} CK{Cook Islands} CL{Chile} CM{Cameroon} CN{China} CO{Colombia} CR{Costa Rica} CU{Cuba} CV{Cape Verde} CW{Curaçao} CX{Christmas Island} CY{Cyprus} CZ{Czechia} DE{Germany} DJ{Djibouti} DK{Denmark} DM{Dominica} DO{Dominican Republic} DZ{Algeria} EC{Ecuador} EE{Estonia} EG{Egypt} EH{Western Sahara} ER{Eritrea} ES{Spain} ET{Ethiopia} FI{Finland} FJ{Fiji} FK{Falkland Islands} FM{Micronesia} FO{Faroe Islands} FR{France} GA{Gabon} GB{United Kingdom} GD{Grenada} GE{Georgia} GF{French Guiana} GG{Guernsey} GH{Ghana} GI{Gibraltar} GL{Greenland} GM{Gambia} GN{Guinea} GP{Guadeloupe} GQ{Equatorial Guinea} GR{Greece} GS{South Georgia and the South Sandwich Islands} GT{Guatemala} GU{Guam} GW{Guinea-Bissau} GY{Guyana} HK{Hong Kong} HM{Heard Island and McDonald Islands} HN{Honduras} HR{Croatia} HT{Haiti} HU{Hungary} ID{Indonesia} IE{Ireland} IL{Israel} IM{Isle of Man} IN{India} IO{British Indian Ocean Territory} IQ{Iraq} IR{Iran} IS{Iceland} IT{Italy} JE{Jersey} JM{Jamaica} JO{Jordan} JP{Japan} KE{Kenya} KG{Kyrgyzstan} KH{Cambodia} KI{Kiribati} KM{Comoros} KN{Saint Kitts and Nevis} KP{North Korea} KR{South Korea} KW{Kuwait} KY{Cayman Islands} KZ{Kazakhstan} LA{Laos} LB{Lebanon} LC{Saint Lucia} LI{Liechtenstein} LK{Sri Lanka} LR{Liberia} LS{Lesotho} LT{Lithuania} LU{Luxembourg} LV{Latvia} LY{Libya} MA{Morocco} MC{Monaco} MD{Moldova} ME{Montenegro} MF{Saint Martin} MG{Madagascar} MH{Marshall Islands} MK{North Macedonia} ML{Mali} MM{Myanmar} MN{Mongolia} MO{Macao} MP{Northern Mariana Islands} MQ{Martinique} MR{Mauritania} MS{Montserrat} MT{Malta} MU{Mauritius} MV{Maldives} MW{Malawi} MX{Mexico} MY{Malaysia} MZ{Mozambique} NA{Namibia} NC{New Caledonia} NE{Niger} NF{Norfolk Island} NG{Nigeria} NI{Nicaragua} NL{Netherlands} NO{Norway} NP{Nepal} NR{Nauru} NU{Niue} NZ{New Zealand} OM{Oman} PA{Panama} PE{Peru} PF{French Polynesia} PG{Papua New Guinea} PH{Philippines} PK{Pakistan} PL{Poland} PM{Saint Pierre and Miquelon} PN{Pitcairn Islands} PR{Puerto Rico} PS{Palestine} PT{Portugal} PW{Palau} PY{Paraguay} QA{Qatar} RE{Réunion} RO{Romania} RS{Serbia} RU{Russia} RW{Rwanda} SA{Saudi Arabia} SB{Solomon Islands} SC{Seychelles} SD{Sudan} SE{Sweden} SG{Singapore} SH{Saint Helena} SI{Slovenia} SJ{Svalbard and Jan Mayen} SK{Slovakia} SL{Sierra Leone} SM{San Marino} SN{Senegal} SO{Somalia} SR{Suriname} SS{South Sudan} ST{São Tomé and Príncipe} SV{El Salvador} SX{Sint Maarten} SY{Syria} SZ{Eswatini} TC{Turks and Caicos Islands} TD{Chad} TF{French Southern Territories} TG{Togo} TH{Thailand} TJ{Tajikistan} TK{Tokelau} TL{Timor-Leste} TM{Turkmenistan} TN{Tunisia} TO{Tonga} TR{Turkey} TT{Trinidad and Tobago} TV{Tuvalu} TW{Taiwan} TZ{Tanzania} UA{Ukraine} UG{Uganda} UM{U.S. Outlying Islands} US{United States} UY{Uruguay} UZ{Uzbekistan} VA{Vatican City} VC{Saint Vincent and the Grenadines} VE{Venezuela} VG{British Virgin Islands} VI{U.S. Virgin Islands} VN{Vietnam} VU{Vanuatu} WF{Wallis and Futuna} WS{Samoa} YE{Yemen} YT{Mayotte} ZA{South Africa} ZM{Zambia} ZW{Zimbabwe} EU{European Union} XA{Canary Islands} XB{Basque Country} XC{Catalonia} XE{England} XG{Galicia} XK{Kosovo} XP{Palestine} XS{Scotland} XW{Wales} XX{International} other{{code}}}'**
  String countryName(String code);

  /// No description provided for @countryMapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a country to see how many games you played against it. Pinch or use the buttons to zoom.'**
  String get countryMapHint;

  /// Bulle d’un pays de la carte, 2e ligne : nombre de parties.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 games} =1{1 game} other{{count} games}}'**
  String countryMapGames(int count);

  /// No description provided for @countryMapLegend.
  ///
  /// In en, this message translates to:
  /// **'Games played'**
  String get countryMapLegend;

  /// No description provided for @countryMapZoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get countryMapZoomIn;

  /// No description provided for @countryMapZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get countryMapZoomOut;

  /// No description provided for @countryMapReset.
  ///
  /// In en, this message translates to:
  /// **'Reset view'**
  String get countryMapReset;

  /// Pays joués qui ne figurent pas sur la carte (International, pays inconnu…).
  ///
  /// In en, this message translates to:
  /// **'Not shown on the map: {countries}'**
  String countryMapNotShown(String countries);

  /// Un pays hors carte avec son nombre de parties, ex. International (3 parties).
  ///
  /// In en, this message translates to:
  /// **'{country} ({count, plural, =0{0 games} =1{1 game} other{{count} games}})'**
  String countryMapNotShownItem(String country, int count);

  /// Infobulle du marqueur posé sur les 3 pays les plus rencontrés (rang 1 à 3).
  ///
  /// In en, this message translates to:
  /// **'{rank, select, 1{Most played country} 2{2nd most played country} 3{3rd most played country} other{No. {rank} most played country}}'**
  String countryMapTopRank(String rank);

  /// Bouton de choix de la carte : nombre de parties par pays.
  ///
  /// In en, this message translates to:
  /// **'Games played'**
  String get countryMapModeGames;

  /// Bouton de choix de la carte : performance par pays, (victoires + ½ nulles) / parties.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get countryMapModePerformance;

  /// No description provided for @countryMapPerformanceHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a country to see your performance against it. Pinch or use the buttons to zoom.'**
  String get countryMapPerformanceHint;

  /// No description provided for @countryMapPerformanceLegend.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get countryMapPerformanceLegend;

  /// No description provided for @countryMapPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String countryMapPercent(int percent);

  /// Bulle d'un pays sur la carte Performance, 1re ligne (en gras).
  ///
  /// In en, this message translates to:
  /// **'{country} · {percent}%'**
  String countryMapPerformanceTitle(String country, int percent);

  /// Bulle d'un pays sur la carte Performance, 2e ligne (chiffres en gras).
  ///
  /// In en, this message translates to:
  /// **'{games, plural, =1{1 game} other{{games} games}} · W {wins} · D {draws} · L {losses}'**
  String countryMapPerformanceDetail(
      int games, int wins, int draws, int losses);

  /// Bulle d'un pays trop peu joué sur la carte Performance, 2e ligne.
  ///
  /// In en, this message translates to:
  /// **'{games, plural, =0{0 games} =1{1 game} other{{games} games}} · not enough to rate'**
  String countryMapNotEnoughDetail(int games);

  /// Infobulle d'un marqueur regroupant plusieurs pays proches.
  ///
  /// In en, this message translates to:
  /// **'{countries}: tap to zoom in'**
  String countryMapGroup(String countries);

  /// No description provided for @countryMapNotEnoughLegend.
  ///
  /// In en, this message translates to:
  /// **'Fewer than {minGames} games: not enough to rate'**
  String countryMapNotEnoughLegend(int minGames);

  /// No description provided for @countryMapNoneJudged.
  ///
  /// In en, this message translates to:
  /// **'No country has enough games yet to rate the performance ({minGames} minimum).'**
  String countryMapNoneJudged(int minGames);

  /// No description provided for @countryMapStrengths.
  ///
  /// In en, this message translates to:
  /// **'Strengths: '**
  String get countryMapStrengths;

  /// No description provided for @countryMapWeaknesses.
  ///
  /// In en, this message translates to:
  /// **'Weaknesses: '**
  String get countryMapWeaknesses;

  /// No description provided for @countryMapNoStrength.
  ///
  /// In en, this message translates to:
  /// **'none in this period'**
  String get countryMapNoStrength;

  /// No description provided for @countryMapNoWeakness.
  ///
  /// In en, this message translates to:
  /// **'none in this period'**
  String get countryMapNoWeakness;

  /// No description provided for @countryMapSummaryItem.
  ///
  /// In en, this message translates to:
  /// **'{country} {percent}%'**
  String countryMapSummaryItem(String country, int percent);

  /// Infobulle du marqueur d'un point fort (rang 1 à 3).
  ///
  /// In en, this message translates to:
  /// **'{rank, select, 1{Best performance} 2{2nd best performance} 3{3rd best performance} other{No. {rank} best performance}}'**
  String countryMapStrengthRank(String rank);

  /// Infobulle du marqueur d'un point faible (rang 1 à 3).
  ///
  /// In en, this message translates to:
  /// **'{rank, select, 1{Weakest performance} 2{2nd weakest performance} 3{3rd weakest performance} other{No. {rank} weakest performance}}'**
  String countryMapWeaknessRank(String rank);

  /// Sous un tableau paginé : lignes affichées et total, ex. 11–20 of 37.
  ///
  /// In en, this message translates to:
  /// **'{first}–{last} of {total}'**
  String paginationRange(int first, int last, int total);

  /// No description provided for @previousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get previousPage;

  /// No description provided for @nextPage.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get nextPage;

  /// Pied de page : numéro de version de l'application.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// Lien du pied de page et titre du journal des versions.
  ///
  /// In en, this message translates to:
  /// **'What\'s new'**
  String get whatsNew;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Titre d'une version dans le journal, ex. Version 1.1.0 – November 12, 2026.
  ///
  /// In en, this message translates to:
  /// **'Version {version} – {date}'**
  String changelogVersionTitle(String version, String date);

  /// Nouveautés de la version 1.4.0, une par ligne.
  ///
  /// In en, this message translates to:
  /// **'Stats for the last month or the last 3 months, your choice\nFaster display: each player\'s games are kept in your browser\nSearch: players you already looked up are suggested\nCleaner, more compact page, especially on mobile'**
  String get changelogV140;

  /// Nouveautés de la version 1.3.0, une par ligne.
  ///
  /// In en, this message translates to:
  /// **'New \"Playing hours\" card: a 24-hour dial of this month\'s games by start time, in your local time\n\"Activity\" mode: number of games per hour, in shades of blue\n\"Performance\" mode: score per hour, from red to green through yellow (at least 5 games per hour)\nBest and weakest time slots: one click shows them on the dial\nTap an hour to see its details in a bubble'**
  String get changelogV130;

  /// Nouveautés de la version 1.2.1, une par ligne.
  ///
  /// In en, this message translates to:
  /// **'Faster loading: each opponent\'s country is requested only once, several at a time, and remembered for a month in your browser'**
  String get changelogV121;

  /// Nouveautés de la version 1.2.0, une par ligne.
  ///
  /// In en, this message translates to:
  /// **'Countries map: new \"Performance\" map, from red (losses) to green (wins) through yellow (even)\nCountries with too few games in grey: 2 games minimum, 3 above 40 games in the month\nStrengths and weaknesses: markers on the map and a summary under the legend'**
  String get changelogV120;

  /// Nouveautés de la version 1.1.0, une par ligne.
  ///
  /// In en, this message translates to:
  /// **'Desktop display: statistics on two columns on large screens\nPage title centered on every page\nPlayed openings and opponents\' countries: paginated tables, 5 rows per page\nFooter with the version number and what\'s new'**
  String get changelogV110;

  /// Nouveautés de la version 1.0.0, une par ligne.
  ///
  /// In en, this message translates to:
  /// **'Current month statistics: by color, by opening, rating history, time management, loss causes\nStatistics by opponents\' country, with a world map\nLight / dark mode\nApp in English and French'**
  String get changelogV100;

  /// No description provided for @playingHours.
  ///
  /// In en, this message translates to:
  /// **'Playing hours'**
  String get playingHours;

  /// No description provided for @playingHoursModeActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get playingHoursModeActivity;

  /// No description provided for @playingHoursModePerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get playingHoursModePerformance;

  /// No description provided for @playingHoursHint.
  ///
  /// In en, this message translates to:
  /// **'Each slice is one hour, by the time the game started (your local time). Tap an hour to see the details.'**
  String get playingHoursHint;

  /// Heure autour du cadran, ex. 15 h.
  ///
  /// In en, this message translates to:
  /// **'{hour}:00'**
  String playingHoursHourLabel(int hour);

  /// Tranche d'une heure, ex. 15 h – 16 h.
  ///
  /// In en, this message translates to:
  /// **'{start}:00–{end}:00'**
  String playingHoursRange(int start, int end);

  /// Détail de l'heure touchée : tranche, puis chiffres.
  ///
  /// In en, this message translates to:
  /// **'{range} · {detail}'**
  String playingHoursDetail(String range, String detail);

  /// No description provided for @playingHoursPerformanceDetail.
  ///
  /// In en, this message translates to:
  /// **'{percent}% · {games, plural, =1{1 game} other{{games} games}} · W {wins} · D {draws} · L {losses}'**
  String playingHoursPerformanceDetail(
      int percent, int games, int wins, int draws, int losses);

  /// No description provided for @playingHoursNotEnoughDetail.
  ///
  /// In en, this message translates to:
  /// **'{games, plural, =0{0 games} =1{1 game} other{{games} games}}, not enough to rate ({minGames} minimum)'**
  String playingHoursNotEnoughDetail(int games, int minGames);

  /// No description provided for @playingHoursBandVeryLow.
  ///
  /// In en, this message translates to:
  /// **'Below 40%'**
  String get playingHoursBandVeryLow;

  /// No description provided for @playingHoursBandLow.
  ///
  /// In en, this message translates to:
  /// **'40–46%'**
  String get playingHoursBandLow;

  /// No description provided for @playingHoursBandEven.
  ///
  /// In en, this message translates to:
  /// **'46–54%'**
  String get playingHoursBandEven;

  /// No description provided for @playingHoursBandHigh.
  ///
  /// In en, this message translates to:
  /// **'54–60%'**
  String get playingHoursBandHigh;

  /// No description provided for @playingHoursBandVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Above 60%'**
  String get playingHoursBandVeryHigh;

  /// No description provided for @playingHoursBest.
  ///
  /// In en, this message translates to:
  /// **'Best time slot:'**
  String get playingHoursBest;

  /// No description provided for @playingHoursWorst.
  ///
  /// In en, this message translates to:
  /// **'Weakest time slot:'**
  String get playingHoursWorst;

  /// Meilleur ou moins bon créneau, ex. 14 h – 15 h (62 %, 34 parties).
  ///
  /// In en, this message translates to:
  /// **'{range} ({percent}%, {games, plural, =1{1 game} other{{games} games}})'**
  String playingHoursSlot(String range, int percent, int games);

  /// No description provided for @playingHoursNoneJudged.
  ///
  /// In en, this message translates to:
  /// **'No hour has enough games yet to rate your performance ({minGames} minimum).'**
  String playingHoursNoneJudged(int minGames);

  /// No description provided for @gamePhases.
  ///
  /// In en, this message translates to:
  /// **'Game phases'**
  String get gamePhases;

  /// No description provided for @gamePhasesLoading.
  ///
  /// In en, this message translates to:
  /// **'Analysing your games… {percent}'**
  String gamePhasesLoading(String percent);

  /// No description provided for @noPhaseData.
  ///
  /// In en, this message translates to:
  /// **'No analysed games for this time control'**
  String get noPhaseData;

  /// No description provided for @phaseEndTitle.
  ///
  /// In en, this message translates to:
  /// **'Where your games end'**
  String get phaseEndTitle;

  /// No description provided for @phaseOpening.
  ///
  /// In en, this message translates to:
  /// **'In the opening'**
  String get phaseOpening;

  /// No description provided for @phaseMiddlegame.
  ///
  /// In en, this message translates to:
  /// **'In the middlegame'**
  String get phaseMiddlegame;

  /// No description provided for @phaseEndgame.
  ///
  /// In en, this message translates to:
  /// **'In the endgame'**
  String get phaseEndgame;

  /// No description provided for @phaseTimeoutLosses.
  ///
  /// In en, this message translates to:
  /// **'Including {count} lost on time'**
  String phaseTimeoutLosses(int count);

  /// No description provided for @phaseClockTitle.
  ///
  /// In en, this message translates to:
  /// **'Time left'**
  String get phaseClockTitle;

  /// No description provided for @phaseClockMiddlegame.
  ///
  /// In en, this message translates to:
  /// **'End of the opening'**
  String get phaseClockMiddlegame;

  /// No description provided for @phaseClockEndgame.
  ///
  /// In en, this message translates to:
  /// **'Reaching the endgame'**
  String get phaseClockEndgame;

  /// No description provided for @phaseClockPlayer.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get phaseClockPlayer;

  /// No description provided for @phaseClockOpponent.
  ///
  /// In en, this message translates to:
  /// **'Opponent'**
  String get phaseClockOpponent;

  /// No description provided for @phaseClockNote.
  ///
  /// In en, this message translates to:
  /// **'Average, as a share of the starting time (timed games only).'**
  String get phaseClockNote;

  /// No description provided for @endgameMaterialTitle.
  ///
  /// In en, this message translates to:
  /// **'Your endgames by material'**
  String get endgameMaterialTitle;

  /// No description provided for @endgameMaterialAhead.
  ///
  /// In en, this message translates to:
  /// **'Material up'**
  String get endgameMaterialAhead;

  /// No description provided for @endgameMaterialEqual.
  ///
  /// In en, this message translates to:
  /// **'Material equal'**
  String get endgameMaterialEqual;

  /// No description provided for @endgameMaterialBehind.
  ///
  /// In en, this message translates to:
  /// **'Material down'**
  String get endgameMaterialBehind;

  /// No description provided for @endgameTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'By endgame type'**
  String get endgameTypeTitle;

  /// No description provided for @endgameTypePawn.
  ///
  /// In en, this message translates to:
  /// **'Pawn endgames'**
  String get endgameTypePawn;

  /// No description provided for @endgameTypeMinor.
  ///
  /// In en, this message translates to:
  /// **'Minor piece endgames'**
  String get endgameTypeMinor;

  /// No description provided for @endgameTypeRook.
  ///
  /// In en, this message translates to:
  /// **'Rook endgames'**
  String get endgameTypeRook;

  /// No description provided for @endgameTypeRookMinor.
  ///
  /// In en, this message translates to:
  /// **'Rooks and minor pieces'**
  String get endgameTypeRookMinor;

  /// No description provided for @endgameTypeQueen.
  ///
  /// In en, this message translates to:
  /// **'Queen endgames'**
  String get endgameTypeQueen;

  /// No description provided for @endgameTypeQueenOther.
  ///
  /// In en, this message translates to:
  /// **'Queens and other pieces'**
  String get endgameTypeQueenOther;

  /// No description provided for @phaseClockLegendPlayer.
  ///
  /// In en, this message translates to:
  /// **'Your time left (top half):'**
  String get phaseClockLegendPlayer;

  /// No description provided for @phaseClockLegendOpponent.
  ///
  /// In en, this message translates to:
  /// **'Opponent\'s time left (bottom half)'**
  String get phaseClockLegendOpponent;

  /// No description provided for @phaseClockLegendElapsed.
  ///
  /// In en, this message translates to:
  /// **'Time used'**
  String get phaseClockLegendElapsed;

  /// No description provided for @phaseClockLegendAhead.
  ///
  /// In en, this message translates to:
  /// **'More than your opponent (gap above 10% of the starting time)'**
  String get phaseClockLegendAhead;

  /// No description provided for @phaseClockLegendBalanced.
  ///
  /// In en, this message translates to:
  /// **'About the same as your opponent (gap of 10% or less)'**
  String get phaseClockLegendBalanced;

  /// No description provided for @phaseClockLegendBehind.
  ///
  /// In en, this message translates to:
  /// **'Less than your opponent (gap above 10% of the starting time)'**
  String get phaseClockLegendBehind;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
