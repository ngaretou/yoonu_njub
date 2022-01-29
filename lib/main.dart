import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio_background/just_audio_background.dart';

import './providers/player_manager.dart';
import './providers/shows.dart';
import './providers/theme.dart';

import 'screens/main_player_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';

Future<void> main() async {
  //This helps avoid a SharedPreferences error: https://stackoverflow.com/questions/69123934/flutter-sharedpreferences-null-check-operator-used-on-a-null-value
  // WidgetsFlutterBinding.ensureInitialized();
  //Initialize the audio background service that allows the notification area playback controller widget
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (ctx) => Shows(),
      ),
      ChangeNotifierProvider(
        create: (ctx) => ThemeModel(),
      ),
      ChangeNotifierProvider(
        create: (ctx) => PlayerManager(),
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  MyApp();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //For the future builder
  late Future<int> _initialization;
  Future<bool>? _initializeBool;
  //To signal end of initialization process
  bool isInitialized = false;

  //Language code: Initialize the locale
  Future<void> setupLang() async {
    print('setupLang()');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Function setLocale =
        Provider.of<ThemeModel>(context, listen: false).setLocale;

    //If there is no lang pref (i.e. first run), set lang to Wolof
    if (!prefs.containsKey('userLang')) {
      // fr_CH is our Flutter 2.x stand-in for Wolof
      await setLocale('fr_CH');
    } else {
      //otherwise grab the saved setting
      String savedUserLang =
          json.decode(prefs.getString('userLang')!) as String;

      await setLocale(savedUserLang);
    }
    print('end setupLang()');
    //end language code
  }

  // Future<bool>? realInit() async {
  //   List<Future> futures = <Future>[
  //     Provider.of<ThemeModel>(context, listen: false).setupTheme(),
  //     Provider.of<Shows>(context, listen: false).getData(),
  //     setupLang()
  //   ];

  //   try {
  //     await Future.wait(futures).then((value) {
  //       return true;
  //     });
  //   } catch (e) {
  //     print(e);
  //   }

  //   // await Provider.of<ThemeModel>(context, listen: false).setupTheme();
  //   // await Provider.of<Shows>(context, listen: false).getData();
  //   // await setupLang();
  //   throw ('error: returning from realInit but not from completion');
  //   // print('returning from realInit but not from completion');
  // }

  // Future<bool> callInititalization() async {
  //   // await Future.delayed(const Duration(milliseconds: 500));
  //   await Provider.of<ThemeModel>(context, listen: false).setupTheme();
  //   await Provider.of<Shows>(context, listen: false).getData();
  //   await setupLang();
  //   print('normally all done with callInititalization');
  //   return true;
  // }
  Future<int> callInititalization() async {
    // await Future.delayed(const Duration(milliseconds: 500));
    // try {
    //   await realInit()!.then((value) {
    //     return value;
    //   });
    // } catch (err) {
    //   print(err.toString());
    // }

    int myInt = 0;
    List<Future> futures = <Future>[
      Provider.of<ThemeModel>(context, listen: false).setupTheme(),
      Provider.of<Shows>(context, listen: false).getData(),
      setupLang(),
      Future.delayed(Duration(milliseconds: 1500)),
    ];

    try {
      List returned = await Future.wait(futures);
      return returned.length;
    } catch (e) {
      print(e);
      return 0;
    }

    // if (myInt > 0) {
    //   print('returning from callInititalization');
    //   return true;
    // } else {
    //   return false;
    // }

    // return false;
  }

  @override
  void initState() {
    super.initState();
    /* https://blog.devgenius.io/understanding-futurebuilder-in-flutter-491501526373
    Now you must be wondering why we are doing this right? Can’t we directly assign _getContacts() 
    to the FutureBuilder directly instead of introducing another variable?
    If you go through the Flutter documentation, you will notice that the build method can get called 
    at any time. This would include setState() or on device orientation change. What this means is that 
    any change in device configuration or widget rebuilds would trigger your Future to fire multiple times. 
    In order to prevent that, we make sure that the Future is obtained in the initState() and not in the build() 
    method itself. This is something which you may notice in a lot of tutorials online where they assign the 
    Future method directly to the FutureBuilder and it’s factually wrong.*/
    print('before _initialization');

    // _initialization = callInititalization();
    _initialization = callInititalization();
    print('after _initialization');
  }

  @override
  Widget build(BuildContext context) {
    print('build method');
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

    ThemeData? theme = Provider.of<ThemeModel>(context).currentTheme;

    return MaterialApp(
      // theme: theme != null ? theme : ThemeData.dark(),
      theme: theme,
      debugShowCheckedModeBanner: false,
      title: 'Yoonu Njub',
      home: FutureBuilder(
          // future: _initialization,
          future: _initialization,
          // initialData: null,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              print('Future returned from _initialization');
              return MainPlayer();
            } else {
              print('snapshot.data ${snapshot.data}');
              return Center(child: CircularProgressIndicator());
            }
          }),
      routes: {
        MainPlayer.routeName: (ctx) => MainPlayer(),
        SettingsScreen.routeName: (ctx) => SettingsScreen(),
        AboutScreen.routeName: (ctx) => AboutScreen(),
      },
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('fr', 'FR'),
        // Unfortunately there is a ton of setup to add a new language
        // to Flutter post version 2.0 and intl 0.17.
        // The most doable way to stick with the official Flutter l10n method
        // is to use Swiss French as the main source for the translations
        // and add in the Wolof to the app_fr_ch.arb in the l10n folder.
        // So when we switch locale to fr_CH, that's Wolof.
        const Locale('fr', 'CH'),
      ],
      locale: Provider.of<ThemeModel>(context, listen: false).userLocale == null
          ? Locale('fr', 'CH')
          : Provider.of<ThemeModel>(context, listen: false).userLocale,
    );
  }
}
