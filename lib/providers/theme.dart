import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  ThemeComponents? userTheme;
  ThemeData? currentTheme;
  Locale? userLocale;
  late bool _downloadsApproved;

  bool? get downloadsApproved {
    return _downloadsApproved;
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

  Future<void> setupTheme() async {
    ThemeComponents _defaultTheme =
        ThemeComponents(brightness: Brightness.light, color: Colors.teal);
    print('setupTheme');

    //get the prefs
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //if there's no userTheme, it's the first time they've run the app, so give them lightTheme with teal
    if (!prefs.containsKey('userTheme')) {
      setTheme(_defaultTheme, refresh: false);
    } else {
      final List<String>? _savedTheme = prefs.getStringList('userTheme');
      late Brightness _brightness;
      //Try this out - if there's a version problem where the variable doesn't fit,
      //the default theme is used
      try {
        switch (_savedTheme?[0]) {
          case "Brightness.light":
            {
              _brightness = Brightness.light;
              break;
            }

          case "Brightness.dark":
            {
              _brightness = Brightness.dark;
              break;
            }
        }
        int _colorValue = int.parse(_savedTheme![1]);

        Color color = Color(_colorValue);

        ThemeComponents _componentsToSet =
            ThemeComponents(brightness: _brightness, color: color);
        setTheme(_componentsToSet, refresh: false);
      } catch (e) {
        setTheme(_defaultTheme, refresh: false);
      }
    }

    //initializing the ask to download setting
    if (!prefs.containsKey('_downloadsApproved')) {
      _downloadsApproved = false;
      denyDownloading();
    } else {
      final temp =
          json.decode(prefs.getString('_downloadsApproved')!) as String?;

      if (temp == 'true') {
        _downloadsApproved = true;
      } else {
        _downloadsApproved = false;
      }
    }
    print('end of setup theme');
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
    //get prefs from disk
    final prefs = await SharedPreferences.getInstance();
    //save _themeName to disk
    // final _userTheme = json.encode(theme);

    await prefs.setStringList('userTheme',
        <String>[theme.brightness.toString(), colorToString(theme.color)]);
  }

  void approveDownloading() async {
    _downloadsApproved = true;
    //get prefs from disk
    final prefs = await SharedPreferences.getInstance();

    final tempJSONtrue = json.encode('true');
    prefs.setString('_downloadsApproved', tempJSONtrue);
    print('allow downloading');
    // notifyListeners();
    return;
  }

  void denyDownloading() async {
    _downloadsApproved = false;
    //get prefs from disk
    final prefs = await SharedPreferences.getInstance();

    final tempJSONfalse = json.encode('false');
    prefs.setString('_downloadsApproved', tempJSONfalse);
    print('deny downloading');
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