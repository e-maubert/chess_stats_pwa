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
  /// **'Chess Stats PWA'**
  String get appTitle;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter Chess.com username'**
  String get enterUsername;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get pleaseEnterUsername;

  /// No description provided for @playerStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics for {username}'**
  String playerStats(String username);

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @forceRefresh.
  ///
  /// In en, this message translates to:
  /// **'Force refresh'**
  String get forceRefresh;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @errorLoadingStats.
  ///
  /// In en, this message translates to:
  /// **'Error loading statistics: {error}'**
  String errorLoadingStats(String error);

  /// No description provided for @errorForceRefresh.
  ///
  /// In en, this message translates to:
  /// **'Error during force refresh: {error}'**
  String errorForceRefresh(String error);

  /// No description provided for @globalStats.
  ///
  /// In en, this message translates to:
  /// **'Global Statistics'**
  String get globalStats;

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

  /// No description provided for @winRate.
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get winRate;

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

  /// No description provided for @topOpenings.
  ///
  /// In en, this message translates to:
  /// **'Top 5 Openings'**
  String get topOpenings;

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

  /// No description provided for @winRatePercent.
  ///
  /// In en, this message translates to:
  /// **'{rate}%'**
  String winRatePercent(double rate);

  /// No description provided for @winCount.
  ///
  /// In en, this message translates to:
  /// **'{wins} ({rate}%)'**
  String winCount(int wins, double rate);

  /// No description provided for @lossCount.
  ///
  /// In en, this message translates to:
  /// **'{losses} ({rate}%)'**
  String lossCount(int losses, double rate);

  /// No description provided for @drawCount.
  ///
  /// In en, this message translates to:
  /// **'{draws} ({rate}%)'**
  String drawCount(int draws, double rate);

  /// No description provided for @countryStatsLink.
  ///
  /// In en, this message translates to:
  /// **'See statistics by opponent country'**
  String get countryStatsLink;

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
  /// **'When you lose, this is your average clock gap with the opponent at the end of the game'**
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

  /// No description provided for @countryKZ.
  ///
  /// In en, this message translates to:
  /// **'Kazakhstan'**
  String get countryKZ;

  /// No description provided for @countryUS.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get countryUS;

  /// No description provided for @countryFR.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get countryFR;

  /// No description provided for @countryBR.
  ///
  /// In en, this message translates to:
  /// **'Brazil'**
  String get countryBR;

  /// No description provided for @countryDE.
  ///
  /// In en, this message translates to:
  /// **'Germany'**
  String get countryDE;

  /// No description provided for @countryIN.
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get countryIN;

  /// No description provided for @countryAR.
  ///
  /// In en, this message translates to:
  /// **'Argentina'**
  String get countryAR;

  /// No description provided for @countryCO.
  ///
  /// In en, this message translates to:
  /// **'Colombia'**
  String get countryCO;

  /// No description provided for @countryDZ.
  ///
  /// In en, this message translates to:
  /// **'Algeria'**
  String get countryDZ;

  /// No description provided for @countryID.
  ///
  /// In en, this message translates to:
  /// **'Indonesia'**
  String get countryID;

  /// No description provided for @countryUZ.
  ///
  /// In en, this message translates to:
  /// **'Uzbekistan'**
  String get countryUZ;

  /// No description provided for @countryJO.
  ///
  /// In en, this message translates to:
  /// **'Jordan'**
  String get countryJO;

  /// No description provided for @countryEG.
  ///
  /// In en, this message translates to:
  /// **'Egypt'**
  String get countryEG;

  /// No description provided for @countryMD.
  ///
  /// In en, this message translates to:
  /// **'Moldova'**
  String get countryMD;

  /// No description provided for @countryTN.
  ///
  /// In en, this message translates to:
  /// **'Tunisia'**
  String get countryTN;

  /// No description provided for @countryNP.
  ///
  /// In en, this message translates to:
  /// **'Nepal'**
  String get countryNP;

  /// No description provided for @countryGB.
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get countryGB;

  /// No description provided for @countryCH.
  ///
  /// In en, this message translates to:
  /// **'Switzerland'**
  String get countryCH;

  /// No description provided for @countryDK.
  ///
  /// In en, this message translates to:
  /// **'Denmark'**
  String get countryDK;

  /// No description provided for @countryMX.
  ///
  /// In en, this message translates to:
  /// **'Mexico'**
  String get countryMX;

  /// No description provided for @countryBE.
  ///
  /// In en, this message translates to:
  /// **'Belgium'**
  String get countryBE;

  /// No description provided for @countrySY.
  ///
  /// In en, this message translates to:
  /// **'Syria'**
  String get countrySY;

  /// No description provided for @countrySA.
  ///
  /// In en, this message translates to:
  /// **'Saudi Arabia'**
  String get countrySA;

  /// No description provided for @countryHR.
  ///
  /// In en, this message translates to:
  /// **'Croatia'**
  String get countryHR;

  /// No description provided for @countrySZ.
  ///
  /// In en, this message translates to:
  /// **'Eswatini'**
  String get countrySZ;

  /// No description provided for @countryPT.
  ///
  /// In en, this message translates to:
  /// **'Portugal'**
  String get countryPT;

  /// No description provided for @countryXW.
  ///
  /// In en, this message translates to:
  /// **'Wales'**
  String get countryXW;

  /// No description provided for @countryPH.
  ///
  /// In en, this message translates to:
  /// **'Philippines'**
  String get countryPH;

  /// No description provided for @countryUA.
  ///
  /// In en, this message translates to:
  /// **'Ukraine'**
  String get countryUA;

  /// No description provided for @countryPL.
  ///
  /// In en, this message translates to:
  /// **'Poland'**
  String get countryPL;

  /// No description provided for @countryPE.
  ///
  /// In en, this message translates to:
  /// **'Peru'**
  String get countryPE;

  /// No description provided for @countryXX.
  ///
  /// In en, this message translates to:
  /// **'International'**
  String get countryXX;

  /// No description provided for @countryNL.
  ///
  /// In en, this message translates to:
  /// **'Netherlands'**
  String get countryNL;

  /// No description provided for @countryTH.
  ///
  /// In en, this message translates to:
  /// **'Thailand'**
  String get countryTH;
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
