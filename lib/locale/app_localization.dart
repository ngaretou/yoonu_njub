import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/messages_all.dart';

class AppLocalization {
  static Future<AppLocalization> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return AppLocalization();
    });
  }

  static AppLocalization of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  String get settingsTitle {
    return Intl.message(
      'Settings',
      name: 'settingsTitle',
      desc: 'Settings screen title',
    );
  }

  String get settingsTheme {
    return Intl.message(
      'Theme',
      name: 'settingsTheme',
      desc: 'settings: Theme section',
    );
  }

  String get settingsCardBackground {
    return Intl.message(
      'Card Background',
      name: 'settingsCardBackground',
      desc: 'settings: CardBackground section',
    );
  }

  String get settingsLanguage {
    return Intl.message(
      'Language',
      name: 'settingsLanguage',
      desc: 'settingsLanguage',
    );
  }

  String get settingsAbout {
    return Intl.message(
      'About & Copyright',
      name: 'settingsAbout',
      desc: 'settingsAbout',
    );
  }

  String get settingsCardDirection {
    return Intl.message(
      'Card Direction',
      name: 'settingsCardDirection',
      desc: 'settingsCardDirection',
    );
  }

  String get settingsLTR {
    return Intl.message(
      'LTR',
      name: 'settingsLTR',
      desc: 'settingsLTR',
    );
  }

  String get settingsRTL {
    return Intl.message(
      'RTL',
      name: 'settingsRTL',
      desc: 'settingsRTL',
    );
  }

  String get settingsVerseDisplay {
    return Intl.message(
      'Verse Display',
      name: 'settingsVerseDisplay',
      desc: 'settingsVerseDisplay title: Show verses in Wolof and/or Wolofal',
    );
  }

  String get settingsVerseinWolofal {
    return Intl.message(
      'Verse in Wolofal',
      name: 'settingsVerseinWolofal',
      desc: 'settingsVerseinWolofal',
    );
  }

  String get settingsVerseinWolof {
    return Intl.message(
      'Verse in Wolof',
      name: 'settingsVerseinWolof',
      desc: 'settingsVerseinWolof',
    );
  }

  String get settingsShowFavs {
    return Intl.message(
      'Show Favorites',
      name: 'settingsShowFavs',
      desc: 'settingsShowFavs',
    );
  }

  String get settingsFavorites {
    return Intl.message(
      'Favorites',
      name: 'settingsFavorites',
      desc: 'settingsFavorites',
    );
  }

  String get settingsTextAll {
    return Intl.message(
      'All',
      name: 'settingsTextAll',
      desc: 'settingsTextAll',
    );
  }

  String get settingsViewIntro {
    return Intl.message(
      'View intro again',
      name: 'settingsViewIntro',
      desc: 'settingsViewIntro',
    );
  }

  String get sharingTitle {
    return Intl.message(
      'Share a verse',
      name: 'sharingTitle',
      desc: 'sharingTitle',
    );
  }

  String get sharingMsg {
    return Intl.message(
      "Choose which script you'd like to share",
      name: 'sharingMsg',
      desc: 'sharingMsg',
    );
  }

  String get cancel {
    return Intl.message(
      "Cancel",
      name: 'cancel',
      desc: 'cancel',
    );
  }

  String get clickHereToReadMore {
    return Intl.message(
      "Click here to read more",
      name: 'clickHereToReadMore',
      desc: 'clickHereToReadMore',
    );
  }

  String get introPage1 {
    return Intl.message(
      "introPage1",
      name: 'introPage1',
      desc: 'introPage1',
    );
  }

  String get introPage2 {
    return Intl.message(
      "introPage2",
      name: 'introPage2',
      desc: 'introPage2',
    );
  }

  String get introPage3 {
    return Intl.message(
      "introPage3",
      name: 'introPage3',
      desc: 'introPage3',
    );
  }

  String get favsNoneYet {
    return Intl.message(
      "No favorites yet",
      name: 'favsNoneYet',
      desc: 'favsNoneYet',
    );
  }

  String get favsNoneYetInstructions {
    return Intl.message(
      "Click the heart icon on your favorite names to add some.",
      name: 'favsNoneYetInstructions',
      desc: 'favsNoneYetInstructions',
    );
  }

  String get settingsOK {
    return Intl.message(
      "OK",
      name: 'settingsOK',
      desc: 'OK',
    );
  }

//down to here
  String get addHolidays {
    return Intl.message(
      "Add Holidays to\nGoogle Calendar",
      name: 'addHolidays',
      desc: 'Add Holidays to Google Calendar',
    );
  }

  String get settingsContactUs {
    return Intl.message(
      'Contact us',
      name: 'settingsContactUs',
      desc: 'settingsContactUs',
    );
  }

  String get settingsContactUsEmail {
    return Intl.message(
      'Contact us via email',
      name: 'settingsContactUsEmail',
      desc: 'settingsContactUsEmail',
    );
  }

  String get contactWhatsApp {
    return Intl.message(
      "WhatsApp",
      name: 'contactWhatsApp',
      desc: 'Contact us on WhatsApp',
    );
  }

  String get contactFBMessenger {
    return Intl.message(
      "Facebook Messenger",
      name: 'contactFBMessenger',
      desc: 'Contact us on Facebook Messenger',
    );
  }

  String get shareAppLink {
    return Intl.message(
      "Share app",
      name: 'shareAppLink',
      desc: 'Share link to app on app store',
    );
  }

  String get moreApps {
    return Intl.message(
      "More apps",
      name: 'moreApps',
      desc: 'More apps',
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  final Locale overriddenLocale;

  const AppLocalizationDelegate(this.overriddenLocale);

  @override
  bool isSupported(Locale locale) =>
      ['en', 'fr', 'wo'].contains(locale.languageCode);

  @override
  Future<AppLocalization> load(Locale locale) => AppLocalization.load(locale);

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalization> old) => false;
}
