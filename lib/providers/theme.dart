import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

//New Material 3 version

class ThemeComponents {
  Brightness brightness;
  Color color;

  ThemeComponents({
    required this.brightness,
    required this.color,
  });
}

class ThemeModel extends ChangeNotifier {
  ThemeComponents? userTheme;
  ThemeData? currentTheme;
  Locale? userLocale;
  late bool _downloadsApproved;

  bool? get downloadsApproved {
    return _downloadsApproved;
  }

  Future<void> migrateToHive() async {
    // migrating from SharedPreferences to Hive
    if (prefsBox.get('hiveMigrationComplete') == true) {
      return;
    }
    final oldPrefs = await SharedPreferences.getInstance();
    try {
      if (oldPrefs.containsKey('userLang')) {
        String storedValue = json.decode(oldPrefs.getString('userLang')!);
        prefsBox.put('userLang', storedValue);
      }

      if (oldPrefs.containsKey('_downloadsApproved')) {
        try {
          String storedValue =
              json.decode(oldPrefs.getString('_downloadsApproved')!);
          switch (storedValue) {
            case 'true':
              prefsBox.put('downloadsApproved', true);
              break;
            case 'false':
              prefsBox.put('downloadsApproved', false);
              break;
            default:
              prefsBox.put('downloadsApproved', false);
          }
        } catch (e) {
          if (kDebugMode) debugPrint(e.toString());
          prefsBox.put('downloadsApproved', false);
        }
      }

      // lastShowViewed is an int in hive
      if (oldPrefs.containsKey('lastShowViewed')) {
        int storedValue =
            int.parse(json.decode(oldPrefs.getString('lastShowViewed') ?? '0'));
        prefsBox.put('lastShowViewed', storedValue);
      }
      // userTheme is a List of Strings so let's separate for the hive version
      if (oldPrefs.containsKey('userTheme')) {
        final List<String> savedTheme = oldPrefs.getStringList('userTheme') ??
            ["Brightness.light", "255,0,150,136"];
        prefsBox.put('brightness', savedTheme[0]);
        prefsBox.put('color', savedTheme[1]);
      }
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
      if (kDebugMode) debugPrint('setting default preferences...');
      Map<String, dynamic>? defaultPrefs = {
        'lastShowViewed': 0,
        'userLang': 'fr_CH',
        'downloadsApproved': false,
        'brightness': 'Brightness.light',
        'color': '255,0,150,136',
      };
      for (var key in defaultPrefs.keys) {
        prefsBox.put(key, defaultPrefs[key]);
      }
    }
    await oldPrefs.clear();
    prefsBox.put('hiveMigrationComplete', true);
  }

  //Language code: Initialize the locale
  Future<void> initializeLocale() async {
    if (kDebugMode) debugPrint('setupLang()');

    //If there is no lang pref (i.e. first run), set lang to Wolof
    String? savedUserLang = prefsBox.get('userLang');

    if (savedUserLang == null) {
      // fr_CH is our Flutter 2.x stand-in for Wolof
      await setLocale('fr_CH');
    } else {
      //otherwise grab the saved setting
      await setLocale(savedUserLang);
    }
    if (kDebugMode) debugPrint('end setupLang()');
    //end language code
  }

  //called in initState of main.dart
  Future<void> setLocale(String incomingLocale) async {
    switch (incomingLocale) {
      case 'en':
        userLocale = Locale('en', '');
        notifyListeners();
        break;
      case 'fr':
        userLocale = Locale('fr', '');
        notifyListeners();
        break;
      case 'fr_CH':
        userLocale = Locale('fr', 'CH');
        notifyListeners();
        break;
      default:
    }
    return;
  }

  Future<void> setupTheme() async {
    // migrate old SharedPreferences to Hive
    print('setupTheme');
    try {
      await migrateToHive();
    } catch (e) {
      print(e.toString());
    }

    ThemeComponents defaultTheme =
        ThemeComponents(brightness: Brightness.light, color: Colors.teal);
    if (kDebugMode) debugPrint('setupTheme');

    //get the prefs

    //if there's no userTheme, it's the first time they've run the app, so give them lightTheme with teal
    String? storedBrightness = prefsBox.get('brightness');

    //We save the color as String so have to convert it to Color:
    String? themeColorValue = prefsBox.get('color');

    //check if a color is set by user - if not use default color
    Color color = themeColorValue != null
        ? colorFromString(themeColorValue)
        : Colors.teal;

    if (storedBrightness == null || themeColorValue == null) {
      setTheme(defaultTheme, refresh: false);
    } else {
      late Brightness brightness;
      //Try this out - if there's a version problem where the variable doesn't fit,
      //the default theme is used
      try {
        switch (storedBrightness) {
          case "Brightness.light":
            {
              brightness = Brightness.light;
              break;
            }

          case "Brightness.dark":
            {
              brightness = Brightness.dark;
              break;
            }
        }

        ThemeComponents componentsToSet =
            ThemeComponents(brightness: brightness, color: color);
        setTheme(componentsToSet, refresh: false);
      } catch (e) {
        setTheme(defaultTheme, refresh: false);
      }
    }

    //initializing the ask to download setting
    _downloadsApproved = prefsBox.get('downloadsApproved') ?? false;

    if (kDebugMode) debugPrint('end of setup theme');
    return;
  }

  void setTheme(ThemeComponents theme, {bool? refresh}) {
    //Set incoming theme
    userTheme = theme;
    currentTheme = ThemeData(
        brightness: theme.brightness,
        colorSchemeSeed: theme.color,
        fontFamily: 'Lato');
    //send it for storage
    saveThemeToDisk(theme);
    if (refresh == true || refresh == null) {
      notifyListeners();
    }
  }

  Future<void> saveThemeToDisk(ThemeComponents theme) async {
    prefsBox.put('brightness', theme.brightness.toString());
    prefsBox.put('color', colorToString(theme.color));
  }

  void approveDownloading() async {
    _downloadsApproved = true;
    //get prefs from disk
    prefsBox.put('downloadsApproved', true);
    if (kDebugMode) debugPrint('allow downloading');
    // notifyListeners();
    return;
  }

  void denyDownloading() async {
    _downloadsApproved = false;
    //get prefs from disk

    prefsBox.put('downloadsApproved', false);
    if (kDebugMode) debugPrint('deny downloading');
    return;
  }
}

String colorToString(Color color) {
  return [
    (color.a * 255).round(),
    (color.r * 255).round(),
    (color.g * 255).round(),
    (color.b * 255).round()
  ].join(',');
}

Color colorFromString(String string) {
  List<String> vals = string.split(',');
  List<int> argblist = List.generate(vals.length, (i) => int.parse(vals[i]));
  return Color.fromARGB(argblist[0], argblist[1], argblist[2], argblist[3]);
}
