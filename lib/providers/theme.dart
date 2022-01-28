import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/shows.dart';

// ThemeData darkTheme = ThemeData.dark().copyWith(
//     primaryColor: Color(0xff1f655d),
//     accentColor: Color(0xff40bf7a),
//     floatingActionButtonTheme: FloatingActionButtonThemeData(
//         foregroundColor: Colors.white, backgroundColor: Colors.teal),
//     iconTheme: IconThemeData(color: Colors.white70),
//     textTheme: TextTheme(
//         headline6:
//             TextStyle(color: Colors.white70, fontFamily: 'Lato', fontSize: 20),
//         subtitle2: TextStyle(color: Colors.white),
//         subtitle1: TextStyle(color: Colors.white),
//         bodyText2: TextStyle(color: Colors.white)),
//     appBarTheme: AppBarTheme(
//       elevation: 0,
//       color: ThemeData.dark().scaffoldBackgroundColor,
//       textTheme: TextTheme(
//         headline6:
//             TextStyle(color: Colors.white, fontFamily: "Lato", fontSize: 20),
//       ),
//       iconTheme: IconThemeData(color: Colors.white),
//     ),
//     buttonTheme: ButtonThemeData(
//       minWidth: 80,
//     ));

// ThemeData lightTheme = ThemeData.light().copyWith(
//     primaryColor: Color(0xfff5f5f5),
//     accentColor: Color(0xff40bf7a),
//     cardColor: Colors.grey[200],
//     scaffoldBackgroundColor: Colors.white,
//     floatingActionButtonTheme: FloatingActionButtonThemeData(
//         // foregroundColor: Colors.white, backgroundColor: Colors.black54),
//         foregroundColor: Colors.white,
//         backgroundColor: Colors.teal),
//     iconTheme: IconThemeData(color: Colors.black54),
//     textTheme: TextTheme(
//       headline6: TextStyle(color: Colors.black54, fontFamily: 'Lato'),
//       subtitle2: TextStyle(color: Colors.black54),
//       subtitle1: TextStyle(color: Colors.black54),
//       bodyText2: TextStyle(color: Colors.black87),
//     ),
//     appBarTheme: AppBarTheme(
//         elevation: 0,
//         iconTheme: IconThemeData(color: Colors.black54),
//         textTheme: TextTheme(
//           headline6: TextStyle(
//               color: Colors.black54, fontFamily: "Lato", fontSize: 20),
//         ),
//         //     subtitle2: TextStyle(color: Colors.white),
//         //     subtitle1: TextStyle(color: Colors.white)),
//         color: Colors.grey[100],
//         actionsIconTheme: IconThemeData(color: Colors.black54)),
//     buttonTheme: ButtonThemeData(minWidth: 80));

// ThemeData blueTheme = ThemeData.light().copyWith(
//     primaryColor: Colors.blueGrey,
//     accentColor: Colors.blueAccent,
//     backgroundColor: Colors.blue,
//     scaffoldBackgroundColor: Colors.blue,
//     floatingActionButtonTheme: FloatingActionButtonThemeData(
//         foregroundColor: Colors.white, backgroundColor: Colors.blue[700]),
//     iconTheme: IconThemeData(color: Colors.white),
//     textTheme: TextTheme(
//         headline6: TextStyle(color: Colors.white, fontFamily: 'Lato'),
//         subtitle2: TextStyle(color: Colors.white),
//         subtitle1: TextStyle(color: Colors.white),
//         bodyText2: TextStyle(color: Colors.white)),
//     appBarTheme: AppBarTheme(
//         color: Colors.blueAccent,
//         actionsIconTheme: IconThemeData(color: Colors.white)),
//     buttonTheme: ButtonThemeData(minWidth: 80),
//     dialogTheme: DialogTheme(
//         contentTextStyle: TextStyle(color: Colors.black54),
//         titleTextStyle: TextStyle(
//             color: Colors.black54, fontFamily: 'Lato', fontSize: 20)));

// ThemeData tealTheme = ThemeData.light().copyWith(
//     primaryColor: Colors.tealAccent,
//     accentColor: Color(0xff40bf7a),
//     backgroundColor: Colors.teal,
//     scaffoldBackgroundColor: Colors.teal,
//     floatingActionButtonTheme: FloatingActionButtonThemeData(
//         foregroundColor: Colors.white, backgroundColor: Colors.teal[800]),
//     textTheme: TextTheme(
//       headline6: TextStyle(color: Colors.black54, fontFamily: 'Lato'),
//       subtitle2: TextStyle(color: Colors.black54),
//       subtitle1: TextStyle(color: Colors.black54),
//       bodyText2: TextStyle(color: Colors.black87),
//     ),
//     appBarTheme: AppBarTheme(
//         color: Color(0xff1f655d),
//         actionsIconTheme: IconThemeData(color: Colors.white)),
//     buttonTheme: ButtonThemeData(
//       minWidth: 80,
//     ));

// Primary is all of the raised text and buttons: Button color,
//text of OK/Cancel buttons, highlights in calendar picker.
//Secondary ends up being only the color of holidays
ThemeData darkTheme = ThemeData(
  fontFamily: 'Lato',
  colorScheme: ColorScheme.dark()
      .copyWith(primary: Colors.teal[300], secondary: Colors.teal[850]),
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
      .copyWith(primary: Colors.teal[300], secondary: Colors.teal[100]),
  appBarTheme: AppBarTheme(
      backgroundColor: Colors.teal[800],
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: ThemeData.dark().appBarTheme.titleTextStyle),
  // buttonTheme: ButtonThemeData(buttonColor: Colors.teal),
);

ThemeData blueTheme = ThemeData(
  fontFamily: 'Lato',
  primarySwatch: Colors.blue,
  backgroundColor: Colors.teal,
  colorScheme: ColorScheme.light()
      .copyWith(primary: Colors.blue, secondary: Colors.blue[100]),
  scaffoldBackgroundColor: Colors.blue[50],
  appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue[800],
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: ThemeData.dark().appBarTheme.titleTextStyle),
  // buttonTheme: ButtonThemeData(buttonColor: Colors.blue),
);

ThemeData tealTheme = ThemeData(
  fontFamily: 'Lato',
  primarySwatch: Colors.teal,
  colorScheme: ColorScheme.light()
      .copyWith(primary: Colors.teal, secondary: Colors.teal[100]),
  scaffoldBackgroundColor: Colors.teal[50],
  appBarTheme: AppBarTheme(
      backgroundColor: Colors.teal[800],
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: ThemeData.dark().appBarTheme.titleTextStyle),
  // buttonTheme: ButtonThemeData(buttonColor: Colors.teal),
);

//////////////////////
enum ThemeType { Light, Blue, Teal, Dark }

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
  }

  //called as we're setting up and showing a circular indicator
  Future<void> initialSetupAsync(context) async {
    print('initialSetupAsync');
    await Provider.of<Shows>(context, listen: false).getData();
    await setupTheme();
    print('end initialSetupAsync');
    return;
  }

  Future<void> setupTheme() async {
    print('setupThemeNew');
    if (currentTheme != null) {
      return;
    }
    //get the prefs
    final prefs = await SharedPreferences.getInstance();
    //if there's no userTheme, it's the first time they've run the app, so give them lightTheme

    if (!prefs.containsKey('userThemeName')) {
      setLightTheme();
    } else {
      userThemeName = json.decode(prefs.getString('userThemeName')!) as String?;

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
    // notifyListeners();
  }

  void approveDownloading() async {
    _downloadsApproved = true;
    //get prefs from disk
    final prefs = await SharedPreferences.getInstance();

    final tempJSONtrue = json.encode('true');
    prefs.setString('_downloadsApproved', tempJSONtrue);
    print('allow downloading');
    // notifyListeners();
  }

  void denyDownloading() async {
    _downloadsApproved = false;
    //get prefs from disk
    final prefs = await SharedPreferences.getInstance();

    final tempJSONfalse = json.encode('false');
    prefs.setString('_downloadsApproved', tempJSONfalse);
    print('deny downloading');
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
}
