import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:path_provider/path_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/theme.dart';
import '../providers/shows.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings-screen';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  //The individual setting headings

  //Main Settings screen construction:
  @override
  Widget build(BuildContext context) {
    final userThemeName =
        Provider.of<ThemeModel>(context, listen: false).userThemeName;
    final themeProvider = Provider.of<ThemeModel>(context, listen: false);
    Locale userLocale =
        Provider.of<ThemeModel>(context, listen: false).userLocale!;

    //Widgets
    //Main template for all setting titles
    Widget settingTitle(String title, IconData icon, Function? tapHandler) {
      return InkWell(
        onTap: tapHandler as void Function()?,
        child: Container(
            width: 300,
            child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 27,
                      color: Theme.of(context).textTheme.headline6!.color,
                    ),
                    SizedBox(width: 25),
                    Text(title, style: Theme.of(context).textTheme.headline6),
                  ],
                ))),
      );
    }

//Main section layout types
    Widget settingRow(title, setting) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          title,
          VerticalDivider(width: 10, color: Colors.white),
          Expanded(
            child: setting,
          )
          // setting,
        ],
      );
    }

    Widget settingColumn(title, setting) {
      return Column(
        //This aligns titles to the left
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          setting,
          Divider(),
        ],
      );
    }

    //Now individual implementations of it
    Widget themeTitle() {
      return settingTitle(AppLocalizations.of(context).settingsTheme,
          Icons.settings_brightness, null);
    }

    Widget languageTitle() {
      return settingTitle(
          AppLocalizations.of(context).settingsLanguage, Icons.translate, null);
    }

    Widget themeSettings() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            child: userThemeName == 'lightTheme'
                ? Icon(
                    Icons.check,
                    color: Colors.black,
                  )
                : null,
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
              padding: EdgeInsets.all(0),
              shape: CircleBorder(),
            ),
            onPressed: () {
              themeProvider.setLightTheme();
            },
          ),
          ElevatedButton(
            child: userThemeName == 'darkTheme'
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                  )
                : null,
            style: ElevatedButton.styleFrom(
              primary: Colors.black,
              padding: EdgeInsets.all(0),
              shape: CircleBorder(),
            ),
            onPressed: () {
              themeProvider.setDarkTheme();
            },
          ),
        ],
      );
    }

    Widget languageSetting() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Wrap(
            direction: Axis.horizontal,
            spacing: 15,
            children: [
              ChoiceChip(
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: userLocale.toString() == 'fr_CH' ? true : false,
                label: Text(
                  "Wolof",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                // backgroundColor: Theme.of(context).primaryColor,

                onSelected: (bool selected) {
                  themeProvider.setLocale('fr_CH');
                },
              ),
              ChoiceChip(
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: userLocale.toString() == 'fr' ? true : false,

                label: Text(
                  "Français",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                // backgroundColor: Theme.of(context).primaryColor,
                // selectedColor: Theme.of(context).accentColor,
                onSelected: (bool selected) {
                  themeProvider.setLocale('fr');
                  print(AppLocalizations.of(context)!.addHolidays);
                },
              ),
              ChoiceChip(
                padding: EdgeInsets.symmetric(horizontal: 10),

                selected: userLocale.toString() == 'en' ? true : false,
                label: Text(
                  "English",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                // backgroundColor: Theme.of(context).primaryColor,
                // selectedColor: Theme.of(context).accentColor,
                onSelected: (bool selected) {
                  themeProvider.setLocale('en');
                },
              ),
            ],
          ),
        ],
      );
    }

    Widget downloadPermissionTitle() {
      return settingTitle(AppLocalizations.of(context).downloadTitle,
          Icons.download_sharp, null);
    }

    Widget downloadPermissionSetting() {
      bool approved = themeProvider.downloadsApproved!;

      return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        SizedBox(
          width: 20,
        ),
        Expanded(
          child: Text(
            AppLocalizations.of(context).approveDownloads,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
        Checkbox(
          value: approved,
          onChanged: (response) {
            if (response!) {
              themeProvider.approveDownloading();
            } else {
              themeProvider.denyDownloading();
            }
            setState(() {
              approved = response;
            });
          },
        )
      ]);
    }

    Future<String> _getSizeOfAllDownloads() async {
      final directory = await getApplicationDocumentsDirectory();
      int _counter = 0;
      var myStream = directory.list(recursive: false, followLinks: false);
      await for (var element in myStream) {
        if (element is File) {
          _counter += await element.length();
        }
      }
      return (_counter / 1000000).toStringAsFixed(2);
    }

    Future<String> _deleteAllDownloads() async {
      final directory = await getApplicationDocumentsDirectory();
      int _counter = 0;
      var myStream = directory.list(recursive: false, followLinks: false);
      await for (var element in myStream) {
        if (element is File) {
          element.delete();
        }
      }
      return (_counter / 1000000).toStringAsFixed(2);
    }

    Widget clearDownloads() {
      return FutureBuilder(
          future: _getSizeOfAllDownloads(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: LinearProgressIndicator());
            } else {
              return snapshot.data != '0.00'
                  ? Padding(
                      padding: EdgeInsets.only(left: 20, right: 10),
                      child: GestureDetector(
                        child: Container(
                            color: Theme.of(context).cardColor,
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.delete_sweep_sharp),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Text(
                                      AppLocalizations.of(context)
                                              .deleteDownloads +
                                          ' (' +
                                          snapshot.data.toString() +
                                          ' Mb)',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1),
                                ),
                              ],
                            )),
                        onTap: () {
                          _deleteAllDownloads();
                          Provider.of<Shows>(context, listen: false)
                              .setReloadMainPage(true);
                          setState(() {});
                        },
                      ),
                    )
                  : SizedBox(
                      width: 20,
                    );
            }
          });
    }

///////////////////////////////
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).settingsTitle,
        ),
      ),
      //If the width of the screen is greater or equal to 730 (whether or not _isPhone is true)
      //show the wide view
      body: MediaQuery.of(context).size.width >= 730
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: ListView(
                children: [
                  settingRow(themeTitle(), themeSettings()),
                  Divider(),
                  // settingRow(backgroundTitle(), backgroundSettings()),
                  // Divider(),
                  // settingRow(directionTitle(), directionSettings()),
                  // Divider(),
                  // scriptPickerTitle(),
                  // asScriptPicker(),
                  // rsScriptPicker(),
                  // Divider(),
                  settingRow(languageTitle(), languageSetting()),
                  Divider(),
                  if (!kIsWeb)
                    settingRow(
                        downloadPermissionTitle(), downloadPermissionSetting()),
                  if (!kIsWeb) clearDownloads(),
                ],
              ),
            )
          : ListView(
              children: [
                settingColumn(themeTitle(), themeSettings()),
                // settingColumn(backgroundTitle(), backgroundSettings()),
                // settingColumn(directionTitle(), directionSettings()),
                // scriptPickerTitle(),
                // asScriptPicker(),
                // rsScriptPicker(),

                settingColumn(languageTitle(), languageSetting()),

                if (!kIsWeb)
                  settingColumn(
                      downloadPermissionTitle(), downloadPermissionSetting()),
                if (!kIsWeb) clearDownloads(),
              ],
            ),
      // ),
    );
  }
}
