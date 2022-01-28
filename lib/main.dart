import 'dart:convert';

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
  }
  //end language code

  @override
  void initState() {
    super.initState();
    // Call the intitialization of the locale
    setupLang();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    print('MaterialApp');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yoonu Njub',
      home: FutureBuilder(
          future: Provider.of<ThemeModel>(context, listen: false)
              .initialSetupAsync(context),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              print('connectionstate  waiting');
              return Center(child: CircularProgressIndicator());
              // return Text('data');
            } else {
              print('connectionstate not waiting');
              return MainPlayer();
            }
          }),
      theme: Provider.of<ThemeModel>(context).currentTheme,
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
      locale: Provider.of<ThemeModel>(context, listen: false).userLocale,
    );
  }
}
