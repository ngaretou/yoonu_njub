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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('fr', 'CH')
  ];

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// settings: Theme section
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// settings: CardBackground section
  ///
  /// In en, this message translates to:
  /// **'Card Background'**
  String get settingsCardBackground;

  /// settingsLanguage
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// settingsAbout
  ///
  /// In en, this message translates to:
  /// **'About & Copyright'**
  String get settingsAbout;

  /// settingsCardDirection
  ///
  /// In en, this message translates to:
  /// **'Card Direction'**
  String get settingsCardDirection;

  /// settingsLTR
  ///
  /// In en, this message translates to:
  /// **'LTR'**
  String get settingsLTR;

  /// settingsRTL
  ///
  /// In en, this message translates to:
  /// **'RTL'**
  String get settingsRTL;

  /// settingsVerseDisplay
  ///
  /// In en, this message translates to:
  /// **'Verse Display'**
  String get settingsVerseDisplay;

  /// settingsVerseinWolofal
  ///
  /// In en, this message translates to:
  /// **'Verse in Wolofal'**
  String get settingsVerseinWolofal;

  /// settingsVerseinWolof
  ///
  /// In en, this message translates to:
  /// **'Verse in Wolof'**
  String get settingsVerseinWolof;

  /// settingsShowFavs
  ///
  /// In en, this message translates to:
  /// **'Show Favorites'**
  String get settingsShowFavs;

  /// settingsFavorites
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get settingsFavorites;

  /// settingsTextAll
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get settingsTextAll;

  /// settingsViewIntro
  ///
  /// In en, this message translates to:
  /// **'View intro again'**
  String get settingsViewIntro;

  /// sharingTitle
  ///
  /// In en, this message translates to:
  /// **'Share a verse'**
  String get sharingTitle;

  /// sharingMsg
  ///
  /// In en, this message translates to:
  /// **'Choose which script you\'d like to share'**
  String get sharingMsg;

  /// cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// clickHereToReadMore
  ///
  /// In en, this message translates to:
  /// **'Click here to read more'**
  String get clickHereToReadMore;

  /// introPage1
  ///
  /// In en, this message translates to:
  /// **'introPage1'**
  String get introPage1;

  /// introPage2
  ///
  /// In en, this message translates to:
  /// **'introPage2'**
  String get introPage2;

  /// introPage3
  ///
  /// In en, this message translates to:
  /// **'introPage3'**
  String get introPage3;

  /// favsNoneYet
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favsNoneYet;

  /// favsNoneYetInstructions
  ///
  /// In en, this message translates to:
  /// **'Click the heart icon on your favorite names to add some.'**
  String get favsNoneYetInstructions;

  /// OK
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get settingsOK;

  /// Add Holidays to Google Calendar
  ///
  /// In en, this message translates to:
  /// **'Add Holidays to\nGoogle Calendar'**
  String get addHolidays;

  /// settingsContactUs
  ///
  /// In en, this message translates to:
  /// **'Contact us by: '**
  String get settingsContactUs;

  /// settingsContactUsEmail
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get settingsContactUsEmail;

  /// Contact us on WhatsApp
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get contactWhatsApp;

  /// Contact us on Facebook Messenger
  ///
  /// In en, this message translates to:
  /// **'Facebook Messenger'**
  String get contactFBMessenger;

  /// Share link to app on app store
  ///
  /// In en, this message translates to:
  /// **'Share app'**
  String get shareAppLink;

  /// Share link generic text
  ///
  /// In en, this message translates to:
  /// **'Share link'**
  String get shareLink;

  /// Copy link generic text
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// More apps
  ///
  /// In en, this message translates to:
  /// **'More apps'**
  String get moreApps;

  /// Download dialog title
  ///
  /// In en, this message translates to:
  /// **'Download audio'**
  String get downloadTitle;

  /// Would you like to download...
  ///
  /// In en, this message translates to:
  /// **'Would you like to download '**
  String get downloadMessage;

  /// Download automatically from now on
  ///
  /// In en, this message translates to:
  /// **'Do not ask, always download.'**
  String get approveDownloads;

  /// Delete previously downloaded items
  ///
  /// In en, this message translates to:
  /// **'Delete downloads'**
  String get deleteDownloads;

  /// Call on the telephone with a tel: link
  ///
  /// In en, this message translates to:
  /// **'Telephone'**
  String get settingsContactUsTelephone;

  /// adjust speed of playback
  ///
  /// In en, this message translates to:
  /// **'Adjust Speed'**
  String get adjustSpeed;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'fr': {
  switch (locale.countryCode) {
    case 'CH': return AppLocalizationsFrCh();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
