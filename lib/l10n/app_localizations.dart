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

  /// No description provided for @countryStatsPeriod.
  ///
  /// In en, this message translates to:
  /// **'Games of the current month'**
  String get countryStatsPeriod;

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

  /// No description provided for @timeClassAll.
  ///
  /// In en, this message translates to:
  /// **'All games'**
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

  /// No description provided for @ratingSinceMonthStart.
  ///
  /// In en, this message translates to:
  /// **'since the first game of the month'**
  String get ratingSinceMonthStart;

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
