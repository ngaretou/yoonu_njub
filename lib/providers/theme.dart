import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/shows.dart';
import '../locale/app_localization.dart';

ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: Color(0xff1f655d),
    accentColor: Color(0xff40bf7a),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Colors.white, backgroundColor: Colors.teal),
    iconTheme: IconThemeData(color: Colors.white70),
    textTheme: TextTheme(
        headline6:
            TextStyle(color: Colors.white70, fontFamily: 'Lato', fontSize: 20),
        subtitle2: TextStyle(color: Colors.white),
        subtitle1: TextStyle(color: Colors.white),
        bodyText2: TextStyle(color: Colors.white)),
    appBarTheme: AppBarTheme(
      elevation: 0,
      color: ThemeData.dark().scaffoldBackgroundColor,
      textTheme: TextTheme(
        headline6:
            TextStyle(color: Colors.white, fontFamily: "Lato", fontSize: 20),
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    buttonTheme: ButtonThemeData(
      minWidth: 80,
    ));

ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: Color(0xfff5f5f5),
    accentColor: Color(0xff40bf7a),
    cardColor: Colors.grey[200],
    scaffoldBackgroundColor: Colors.white,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        // foregroundColor: Colors.white, backgroundColor: Colors.black54),
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal),
    iconTheme: IconThemeData(color: Colors.black54),
    textTheme: TextTheme(
      headline6: TextStyle(color: Colors.black54, fontFamily: 'Lato'),
      subtitle2: TextStyle(color: Colors.black54),
      subtitle1: TextStyle(color: Colors.black54),
      bodyText2: TextStyle(color: Colors.black87),
    ),
    appBarTheme: AppBarTheme(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black54),
        textTheme: TextTheme(
          headline6: TextStyle(
              color: Colors.black54, fontFamily: "Lato", fontSize: 20),
        ),
        //     subtitle2: TextStyle(color: Colors.white),
        //     subtitle1: TextStyle(color: Colors.white)),
        color: Colors.white,
        actionsIconTheme: IconThemeData(color: Colors.black54)),
    buttonTheme: ButtonThemeData(minWidth: 80));

ThemeData blueTheme = ThemeData.light().copyWith(
    primaryColor: Colors.blueGrey,
    accentColor: Colors.blueAccent,
    backgroundColor: Colors.blue,
    scaffoldBackgroundColor: Colors.blue,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Colors.white, backgroundColor: Colors.blue[700]),
    iconTheme: IconThemeData(color: Colors.white),
    textTheme: TextTheme(
        headline6: TextStyle(color: Colors.white, fontFamily: 'Lato'),
        subtitle2: TextStyle(color: Colors.white),
        subtitle1: TextStyle(color: Colors.white),
        bodyText2: TextStyle(color: Colors.white)),
    appBarTheme: AppBarTheme(
        color: Colors.blueAccent,
        actionsIconTheme: IconThemeData(color: Colors.white)),
    buttonTheme: ButtonThemeData(minWidth: 80),
    dialogTheme: DialogTheme(
        contentTextStyle: TextStyle(color: Colors.black54),
        titleTextStyle: TextStyle(
            color: Colors.black54, fontFamily: 'Lato', fontSize: 20)));

ThemeData tealTheme = ThemeData.light().copyWith(
    primaryColor: Colors.tealAccent,
    accentColor: Color(0xff40bf7a),
    backgroundColor: Colors.teal,
    scaffoldBackgroundColor: Colors.teal,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Colors.white, backgroundColor: Colors.teal[800]),
    textTheme: TextTheme(
      headline6: TextStyle(color: Colors.black54, fontFamily: 'Lato'),
      subtitle2: TextStyle(color: Colors.black54),
      subtitle1: TextStyle(color: Colors.black54),
      bodyText2: TextStyle(color: Colors.black87),
    ),
    appBarTheme: AppBarTheme(
        color: Color(0xff1f655d),
        actionsIconTheme: IconThemeData(color: Colors.white)),
    buttonTheme: ButtonThemeData(
      minWidth: 80,
    ));

enum ThemeType { Light, Blue, Teal, Dark }

class ThemeModel extends ChangeNotifier {
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  // ignore: unused_field
  ThemeType _themeType;
  String userThemeName;
  ThemeData currentTheme;
  String userLang;

//Actually not doing that way anymore but leaving for reference
//this is the constructor, it runs setup to initialize currentTheme
//https://stackoverflow.com/questions/57662372/flutter-sharedpreferences-value-to-provider-on-applcation-start
  // ThemeModel() {
  //   print('ThemeModel setup');
  //   setupTheme();
  //   setupLang();
  // }

  Future<void> initialSetupAsync(context) async {
    Future.wait([
      Provider.of<Shows>(context, listen: false).getData(),
      setupTheme(),
      setupLang()
    ]);
  }

  Future<void> setupTheme() async {
    print('setupTheme');
    if (currentTheme != null) {
      return;
    }
    //get the prefs
    final prefs = await SharedPreferences.getInstance();
    //if there's no userTheme, it's the first time they've run the app, so give them lightTheme
    //We're also grabbing other setup info here: language:

    if (!prefs.containsKey('userThemeName')) {
      setLightTheme();
    } else {
      userThemeName = json.decode(prefs.getString('userThemeName')) as String;

      switch (userThemeName) {
        case 'darkTheme':
          {
            currentTheme = darkTheme;

            _themeType = ThemeType.Dark;
            break;
          }

        case 'lightTheme':
          {
            currentTheme = lightTheme;
            _themeType = ThemeType.Light;
            break;
          }
        case 'blueTheme':
          {
            currentTheme = blueTheme;
            _themeType = ThemeType.Blue;
            break;
          }
        case 'tealTheme':
          {
            currentTheme = tealTheme;
            _themeType = ThemeType.Teal;
            break;
          }
      }
    }
    notifyListeners();
  }

  void setDarkTheme() {
    currentTheme = darkTheme;
    _themeType = ThemeType.Dark;
    //get the theme name as a string for storage
    userThemeName = 'darkTheme';
    //send it for storage
    saveThemeToDisk(userThemeName);
    notifyListeners();
  }

  void setLightTheme() {
    currentTheme = lightTheme;
    _themeType = ThemeType.Light;
    userThemeName = 'lightTheme';
    saveThemeToDisk(userThemeName);
    notifyListeners();
  }

  void setTealTheme() {
    currentTheme = tealTheme;
    _themeType = ThemeType.Teal;
    userThemeName = 'tealTheme';
    saveThemeToDisk(userThemeName);
    notifyListeners();
  }

  void setBlueTheme() {
    currentTheme = blueTheme;
    _themeType = ThemeType.Blue;
    userThemeName = 'blueTheme';
    saveThemeToDisk(userThemeName);
    notifyListeners();
  }

  Future<void> saveThemeToDisk(userThemeName) async {
    //get prefs from disk
    final prefs = await SharedPreferences.getInstance();
    //save _themeName to disk
    final _userThemeName = json.encode(userThemeName);
    prefs.setString('userThemeName', _userThemeName);
  }

  //Language code:
  Future<void> setupLang() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userLang')) {
      // setLang('fr');
      setLang('en');
    } else {
      final savedUserLang = json.decode(prefs.getString('userLang')) as String;
      setLang(savedUserLang);
    }
  }

  Future<void> setLang(incomingLang) async {
    if (incomingLang == null) {
      return;
    } else {
      userLang = incomingLang;
      AppLocalization.load(Locale(userLang, ''));
      //get prefs from disk
      final prefs = await SharedPreferences.getInstance();
      //save userLang to disk
      final _userLang = json.encode(userLang);
      prefs.setString('userLang', _userLang);
    }
  }
}
