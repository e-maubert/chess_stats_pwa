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
  /// **'Win statistics'**
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

  /// No description provided for @timeTimeout.
  ///
  /// In en, this message translates to:
  /// **'Lost on time'**
  String get timeTimeout;

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

  /// Nouveautés de la version 1.6.0, une par ligne.
  ///
  /// In en, this message translates to:
  /// **'Your monthly recap as slides, the first time you look up a player, and to replay from the stats page\nShared filters at the top of the page: time control, colour and opening\nOpening names translated and grouped more accurately\nOne rating curve per time control, and by colour'**
  String get changelogV160;

  /// Nouveautés de la version 1.5.0, une par ligne.
  ///
  /// In en, this message translates to:
  /// **'New \"Game phases\" card: see where your games are decided, from the opening to the endgame\nYour time left against your opponent\'s, at a glance, after the opening and in the endgame\nYour endgame results by material and by type of endgame\nFaster page: the longest stats show up a moment later'**
  String get changelogV150;

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

  /// No description provided for @colorFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Color played'**
  String get colorFilterLabel;

  /// No description provided for @colorFilterBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get colorFilterBoth;

  /// No description provided for @colorFilterWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorFilterWhite;

  /// No description provided for @colorFilterBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get colorFilterBlack;

  /// No description provided for @allGames.
  ///
  /// In en, this message translates to:
  /// **'All games'**
  String get allGames;

  /// No description provided for @resultRateWithCount.
  ///
  /// In en, this message translates to:
  /// **'{rate} ({count})'**
  String resultRateWithCount(String rate, int count);

  /// No description provided for @ratingTrendWhite.
  ///
  /// In en, this message translates to:
  /// **'Rating points won or lost with white'**
  String get ratingTrendWhite;

  /// No description provided for @ratingTrendBlack.
  ///
  /// In en, this message translates to:
  /// **'Rating points won or lost with black'**
  String get ratingTrendBlack;

  /// No description provided for @ratingTrendPoints.
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String ratingTrendPoints(String points);

  /// No description provided for @ratingTrendGames.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{over 1 game} other{over {count} games}}'**
  String ratingTrendGames(int count);

  /// No description provided for @ratingTrendNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Not enough rated games to compute the trend'**
  String get ratingTrendNotEnough;

  /// Nom d'une famille d'ouvertures ; family = famille sans tirets (ex. SicilianDefense), fallback = nom anglais lisible si la famille n'est pas connue.
  ///
  /// In en, this message translates to:
  /// **'{family, select, QueensPawn{Queen\'s Pawn Game} QueensGambit{Queen\'s Gambit} SicilianDefense{Sicilian Defense} RuyLopez{Ruy Lopez} EnglishOpening{English Opening} FrenchDefense{French Defense} DutchDefense{Dutch Defense} KingsGambit{King\'s Gambit} CaroKann{Caro-Kann Defense} ViennaGame{Vienna Game} TwoKnights{Two Knights Defense} GiuocoPiano{Giuoco Piano} ItalianGame{Italian Game} AlekhinesDefense{Alekhine\'s Defense} RetiOpening{Réti Opening} RetiAccepted{Réti Accepted} PircDefense{Pirc Defense} KingsPawn{King\'s Pawn Game} FourKnights{Four Knights Game} PetrovDefense{Petrov\'s Defense} PetrovsDefense{Petrov\'s Defense} KingsKnights{King\'s Knight Opening} KingsIndian{King\'s Indian} QueensIndian{Queen\'s Indian Defense} NimzoIndian{Nimzo-Indian Defense} BogoIndian{Bogo-Indian Defense} IndianGame{Indian Game} CenterGame{Center Game} BishopsOpening{Bishop\'s Opening} BirdsOpening{Bird\'s Opening} ScotchGame{Scotch Game} ScandinavianDefense{Scandinavian Defense} RobatschDefense{Modern Defense (Robatsch)} ModernDefense{Modern Defense} PhilidorDefense{Philidor Defense} NimzowitschLarsen{Nimzowitsch-Larsen Attack} AnderssenOpening{Anderssen\'s Opening} LondonSystem{London System} ColleSystem{Colle System} TrompowskyAttack{Trompowsky Attack} GrunfeldDefense{Grünfeld Defense} SlavDefense{Slav Defense} SemiSlav{Semi-Slav Defense} CatalanOpening{Catalan Opening} BenoniDefense{Benoni Defense} BenkoGambit{Benko Gambit} OwensDefense{Owen\'s Defense} PolishOpening{Polish Opening} ZukertortOpening{Zukertort Opening} PonzianiOpening{Ponziani Opening} EvansGambit{Evans Gambit} DanishGambit{Danish Gambit} UnknownOpening{Unknown opening} UncommonOpening{Uncommon Opening} KingsIndianAttack{King\'s Indian Attack} BudapestGambit{Budapest Gambit} OldIndian{Old Indian Defense} KingsKnight{King\'s Knight Opening} ThreeKnights{Three Knights Game} VeresovAttack{Veresov Attack} TorreAttack{Torre Attack} other{{fallback}}}'**
  String openingFamilyName(String family, String fallback);

  /// No description provided for @openingFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Opening'**
  String get openingFilterLabel;

  /// No description provided for @openingFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All openings'**
  String get openingFilterAll;

  /// No description provided for @openingFilterOthers.
  ///
  /// In en, this message translates to:
  /// **'Other openings'**
  String get openingFilterOthers;

  /// No description provided for @openingOptionCount.
  ///
  /// In en, this message translates to:
  /// **'{name} ({count})'**
  String openingOptionCount(String name, int count);

  /// No description provided for @ratingTrendSelection.
  ///
  /// In en, this message translates to:
  /// **'Rating points won or lost in the selected games'**
  String get ratingTrendSelection;

  /// No description provided for @slidesPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get slidesPrevious;

  /// No description provided for @slidesNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get slidesNext;

  /// No description provided for @recapSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get recapSkip;

  /// No description provided for @recapSeeStats.
  ///
  /// In en, this message translates to:
  /// **'See all stats'**
  String get recapSeeStats;

  /// No description provided for @recapIntroLabel.
  ///
  /// In en, this message translates to:
  /// **'Your month on chess.com'**
  String get recapIntroLabel;

  /// No description provided for @recapIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'{username}, here are your last 30 days'**
  String recapIntroTitle(String username);

  /// No description provided for @recapIntroHint.
  ///
  /// In en, this message translates to:
  /// **'Tap or swipe to continue'**
  String get recapIntroHint;

  /// No description provided for @recapGamesLabel.
  ///
  /// In en, this message translates to:
  /// **'Games played'**
  String get recapGamesLabel;

  /// No description provided for @recapWins.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} win} other{{count} wins}}'**
  String recapWins(num count);

  /// No description provided for @recapDraws.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} draw} other{{count} draws}}'**
  String recapDraws(num count);

  /// No description provided for @recapLosses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} loss} other{{count} losses}}'**
  String recapLosses(num count);

  /// No description provided for @recapScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Your results'**
  String get recapScoreLabel;

  /// No description provided for @recapScoreCaption.
  ///
  /// In en, this message translates to:
  /// **'of points won'**
  String get recapScoreCaption;

  /// No description provided for @recapReplay.
  ///
  /// In en, this message translates to:
  /// **'Replay the monthly recap'**
  String get recapReplay;

  /// No description provided for @recapTimeClassLabel.
  ///
  /// In en, this message translates to:
  /// **'Your favourite time control'**
  String get recapTimeClassLabel;

  /// No description provided for @recapTimeClassDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get recapTimeClassDaily;

  /// No description provided for @recapGamesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} game} other{{count} games}}'**
  String recapGamesCount(num count);

  /// No description provided for @recapRatingChange.
  ///
  /// In en, this message translates to:
  /// **'Rating: {change} over the month'**
  String recapRatingChange(String change);

  /// No description provided for @recapPeakRating.
  ///
  /// In en, this message translates to:
  /// **'Peak: {rating}'**
  String recapPeakRating(int rating);

  /// No description provided for @recapStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Longest winning streak'**
  String get recapStreakLabel;

  /// No description provided for @recapStreakCaption.
  ///
  /// In en, this message translates to:
  /// **'wins in a row'**
  String get recapStreakCaption;

  /// No description provided for @recapStreakCaptionHot.
  ///
  /// In en, this message translates to:
  /// **'wins in a row. Unstoppable!'**
  String get recapStreakCaptionHot;

  /// No description provided for @recapOpeningLabel.
  ///
  /// In en, this message translates to:
  /// **'Your go-to opening'**
  String get recapOpeningLabel;

  /// No description provided for @recapOpeningCaption.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} game} other{{count} games}} · {percent} of points'**
  String recapOpeningCaption(num count, String percent);

  /// No description provided for @recapBestOpeningLabel.
  ///
  /// In en, this message translates to:
  /// **'Your secret weapon'**
  String get recapBestOpeningLabel;

  /// No description provided for @recapHourLabel.
  ///
  /// In en, this message translates to:
  /// **'Your favourite time to play'**
  String get recapHourLabel;

  /// No description provided for @recapHourValue.
  ///
  /// In en, this message translates to:
  /// **'{hour}:00'**
  String recapHourValue(int hour);

  /// No description provided for @recapBusiestDay.
  ///
  /// In en, this message translates to:
  /// **'Busiest day: {date}, {count, plural, one{{count} game} other{{count} games}}'**
  String recapBusiestDay(String date, num count);

  /// No description provided for @recapOpponentLabel.
  ///
  /// In en, this message translates to:
  /// **'Your most-faced opponent'**
  String get recapOpponentLabel;

  /// No description provided for @recapOpponentCaption.
  ///
  /// In en, this message translates to:
  /// **'{count} games together · {wins} W, {draws} D, {losses} L'**
  String recapOpponentCaption(int count, int wins, int draws, int losses);

  /// No description provided for @recapWeakOpeningLabel.
  ///
  /// In en, this message translates to:
  /// **'The opening that gives you trouble'**
  String get recapWeakOpeningLabel;

  /// No description provided for @recapOutroLabel.
  ///
  /// In en, this message translates to:
  /// **'That\'s your month'**
  String get recapOutroLabel;

  /// No description provided for @recapOutroTitle.
  ///
  /// In en, this message translates to:
  /// **'Want to dig deeper?'**
  String get recapOutroTitle;

  /// No description provided for @recapEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No games in the last 30 days'**
  String get recapEmptyTitle;

  /// No description provided for @recapHourEarlyBird.
  ///
  /// In en, this message translates to:
  /// **'Early bird: chess before coffee!'**
  String get recapHourEarlyBird;

  /// No description provided for @recapHourMorning.
  ///
  /// In en, this message translates to:
  /// **'You start the day with a game.'**
  String get recapHourMorning;

  /// No description provided for @recapHourLunch.
  ///
  /// In en, this message translates to:
  /// **'A game over your lunch break?'**
  String get recapHourLunch;

  /// No description provided for @recapHourAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoons are your time.'**
  String get recapHourAfternoon;

  /// No description provided for @recapHourEvening.
  ///
  /// In en, this message translates to:
  /// **'Your evening game is sacred.'**
  String get recapHourEvening;

  /// No description provided for @recapHourNightOwl.
  ///
  /// In en, this message translates to:
  /// **'A true night owl!'**
  String get recapHourNightOwl;

  /// No description provided for @recapVolumeCasual.
  ///
  /// In en, this message translates to:
  /// **'Easy does it: a game now and then.'**
  String get recapVolumeCasual;

  /// No description provided for @recapVolumeRegular.
  ///
  /// In en, this message translates to:
  /// **'A steady pace, about {count} a week.'**
  String recapVolumeRegular(int count);

  /// No description provided for @recapVolumeEveryDay.
  ///
  /// In en, this message translates to:
  /// **'You play almost every day!'**
  String get recapVolumeEveryDay;

  /// No description provided for @recapVolumeEnthusiast.
  ///
  /// In en, this message translates to:
  /// **'A real enthusiast: {count} games a day on average.'**
  String recapVolumeEnthusiast(int count);

  /// No description provided for @recapVolumeNonStop.
  ///
  /// In en, this message translates to:
  /// **'Your board never gets cold.'**
  String get recapVolumeNonStop;

  /// No description provided for @recapScoreDominant.
  ///
  /// In en, this message translates to:
  /// **'You\'re crushing the competition.'**
  String get recapScoreDominant;

  /// No description provided for @recapScoreWinning.
  ///
  /// In en, this message translates to:
  /// **'More wins than losses: well played!'**
  String get recapScoreWinning;

  /// No description provided for @recapScoreBalanced.
  ///
  /// In en, this message translates to:
  /// **'Evenly matched: every game comes down to the wire.'**
  String get recapScoreBalanced;

  /// No description provided for @recapScoreTough.
  ///
  /// In en, this message translates to:
  /// **'A tough month, the next one will be better.'**
  String get recapScoreTough;

  /// No description provided for @recapScoreLearning.
  ///
  /// In en, this message translates to:
  /// **'A month for learning: every loss is a lesson.'**
  String get recapScoreLearning;
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
