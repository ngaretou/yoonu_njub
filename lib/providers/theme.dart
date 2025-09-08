import 'package:flutter/material.dart';
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
    try {
      final oldPrefs = await SharedPreferences.getInstance();

      Future<void> migrateOne(String oldKey, {String? newKey}) async {
        if (oldPrefs.containsKey(oldKey)) {
          String storedValue = json.decode(oldPrefs.getString(oldKey)!);
          prefsBox.put(newKey ?? oldKey, storedValue);
        }
      }

      migrateOne('lastShowViewed');
      migrateOne('userLang');
      migrateOne('_downloadsApproved', newKey: 'downloadsApproved');

      if (oldPrefs.containsKey('userTheme')) {
        final List<String> savedTheme = oldPrefs.getStringList('userTheme') ??
            ["Brightness.light", "255,0,150,136"];
        prefsBox.put('brightness', savedTheme[0]);
        prefsBox.put('color', savedTheme[1]);
      }
    } catch (e) {
      debugPrint(e.toString());
      debugPrint('setting default preferences...');
      Map<String, String>? defaultPrefs = {
        'lastShowViewed': '0',
        'userLang': 'fr_CH',
        'downloadsApproved': 'false',
        'brightness': 'Brightness.light',
        'color': '255,0,150,136',
      };
      for (var key in defaultPrefs.keys) {
        prefsBox.put(key, defaultPrefs[key]);
      }
    }
  }

  //Language code: Initialize the locale
  Future<void> initializeLocale() async {
    debugPrint('setupLang()');

    //If there is no lang pref (i.e. first run), set lang to Wolof
    String? savedUserLang = prefsBox.get('userLang');

    if (savedUserLang == null) {
      // fr_CH is our Flutter 2.x stand-in for Wolof
      await setLocale('fr_CH');
    } else {
      //otherwise grab the saved setting
      await setLocale(savedUserLang);
    }
    debugPrint('end setupLang()');
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
    await migrateToHive();
    ThemeComponents defaultTheme =
        ThemeComponents(brightness: Brightness.light, color: Colors.teal);
    debugPrint('setupTheme');

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
    final downloadsApprovedString =
        prefsBox.get('downloadsApproved') ?? 'false';
    switch (downloadsApprovedString) {
      case 'true':
        _downloadsApproved = true;
        break;
      case 'false':
        _downloadsApproved = false;
        break;
      default:
        _downloadsApproved = false;
    }

    debugPrint('end of setup theme');
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
    debugPrint('allow downloading');
    // notifyListeners();
    return;
  }

  void denyDownloading() async {
    _downloadsApproved = false;
    //get prefs from disk

    prefsBox.put('downloadsApproved', false);
    debugPrint('deny downloading');
    return;
  }

  // void setDarkTheme({bool? refresh}) {
  //   currentTheme = darkTheme;
  //   _themeType = ThemeType.Dark;
  //   //get the theme name as a string for storage
  //   userThemeName = 'darkTheme';
  //   //send it for storage
  //   saveThemeToDisk(userThemeName);
  //   if (refresh == true || refresh == null) {
  //     notifyListeners();
  //   }
  // }

  // void setLightTheme({bool? refresh}) {
  //   currentTheme = lightTheme;
  //   _themeType = ThemeType.Light;
  //   userThemeName = 'lightTheme';
  //   saveThemeToDisk(userThemeName);
  //   if (refresh == true || refresh == null) {
  //     notifyListeners();
  //   }
  // }
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
