import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

//New Material 3 versions
// final lightTheme = ThemeData(colorSchemeSeed: Colors.teal);
// final darkTheme = ThemeData(colorSchemeSeed: Colors.teal, brightness: Brightness.dark, ...);

// Primary is all of the raised text and buttons: Button color,
//text of OK/Cancel buttons, highlights in calendar picker.
//Secondary ends up being only the color of holidays
ThemeData darkTheme = ThemeData(
  fontFamily: 'Lato',
  primarySwatch: Colors.teal,
  colorScheme: ColorScheme.dark().copyWith(
    primary: Colors.teal[300],
    secondary: Colors.teal[800],
  ),
  checkboxTheme:
      CheckboxThemeData(checkColor: MaterialStateProperty.all(Colors.black87)),
  chipTheme: ChipThemeData(
    selectedColor: Colors.teal[800],
    backgroundColor: Colors.teal[400],
  ),
  appBarTheme: AppBarTheme(
      backgroundColor: Colors.teal[800],
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: ThemeData.dark().appBarTheme.titleTextStyle),
  // buttonTheme: ButtonThemeData(buttonColor: Colors.teal),
);

ThemeData lightTheme = ThemeData(
  fontFamily: 'Lato',
  primarySwatch: Colors.teal,
  colorScheme: ColorScheme.light()
      .copyWith(primary: Colors.teal[400], secondary: Colors.teal[300]),
  appBarTheme: AppBarTheme(
      backgroundColor: Colors.teal[800],
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: ThemeData.dark().appBarTheme.titleTextStyle),
  // buttonTheme: ButtonThemeData(buttonColor: Colors.teal),
);

//////////////////////
enum ThemeType { Light, Dark }
enum ThemeColor { Color, Color2 }

class ThemeModel extends ChangeNotifier {
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  // ignore: unused_field
  ThemeType? /*late*/ _themeType;
  String? /*late*/ userThemeName;
  ThemeData? /*late*/ currentTheme;
  Locale? /*late*/ userLocale;
  bool? /*late*/ _downloadsApproved;

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

  Future<void> setupTheme() async {
    print('setupTheme');
    if (currentTheme != null) {
      return;
    }

    //get the prefs
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //if there's no userTheme, it's the first time they've run the app, so give them lightTheme
    if (!prefs.containsKey('userThemeName')) {
      setLightTheme(refresh: false);
    } else {
      userThemeName = json.decode(prefs.getString('userThemeName')!) as String?;

      switch (userThemeName) {
        case 'darkTheme':
          {
            setDarkTheme(refresh: false);
            break;
          }

        case 'lightTheme':
          {
            setDarkTheme(refresh: false);
            break;
          }
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
    notifyListeners();
    return;
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

  void setDarkTheme({bool? refresh}) {
    currentTheme = darkTheme;
    _themeType = ThemeType.Dark;
    //get the theme name as a string for storage
    userThemeName = 'darkTheme';
    //send it for storage
    saveThemeToDisk(userThemeName);
    if (refresh == true || refresh == null) {
      notifyListeners();
    }
  }

  void setLightTheme({bool? refresh}) {
    currentTheme = lightTheme;
    _themeType = ThemeType.Light;
    userThemeName = 'lightTheme';
    saveThemeToDisk(userThemeName);
    if (refresh == true || refresh == null) {
      notifyListeners();
    }
  }

  Future<void> saveThemeToDisk(userThemeName) async {
    //get prefs from disk
    final prefs = await SharedPreferences.getInstance();
    //save _themeName to disk
    final _userThemeName = json.encode(userThemeName);
    prefs.setString('userThemeName', _userThemeName);
  }
}
