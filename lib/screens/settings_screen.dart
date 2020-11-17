import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../locale/app_localization.dart';
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
    final userLang = Provider.of<ThemeModel>(context, listen: false).userLang;

    //Widgets
    //Main template for all setting titles
    Widget settingTitle(String title, IconData icon, Function tapHandler) {
      return InkWell(
        onTap: tapHandler,
        child: Container(
            width: 300,
            child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 27,
                      color: Theme.of(context).textTheme.headline6.color,
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
      return settingTitle(AppLocalization.of(context).settingsTheme,
          Icons.settings_brightness, null);
    }

    Widget languageTitle() {
      return settingTitle(
          AppLocalization.of(context).settingsLanguage, Icons.translate, null);
    }

    Widget themeSettings() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          RaisedButton(
            padding: EdgeInsets.all(0),
            child: userThemeName == 'lightTheme' ? Icon(Icons.check) : null,
            shape: CircleBorder(),
            color: Colors.white,
            onPressed: () {
              themeProvider.setLightTheme();
            },
          ),
          // RaisedButton(
          //   padding: EdgeInsets.all(0),
          //   child: userThemeName == 'blueTheme' ? Icon(Icons.check) : null,
          //   shape: CircleBorder(),
          //   color: Colors.blue,
          //   onPressed: () {
          //     themeProvider.setBlueTheme();
          //   },
          // ),
          // RaisedButton(
          //     padding: EdgeInsets.all(0),
          //     child: userThemeName == 'tealTheme' ? Icon(Icons.check) : null,
          //     shape: CircleBorder(),
          //     color: Colors.teal,
          //     onPressed: () {
          //       themeProvider.setTealTheme();
          //     }),
          RaisedButton(
            padding: EdgeInsets.all(0),
            child: userThemeName == 'darkTheme' ? Icon(Icons.check) : null,
            shape: CircleBorder(),
            color: Colors.black,
            onPressed: () {
              setState(() {
                themeProvider.setDarkTheme();
              });
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
                selected: userLang == 'wo' ? true : false,
                label: Text(
                  "Wolof",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                backgroundColor: Theme.of(context).primaryColor,
                selectedColor: Theme.of(context).accentColor,
                onSelected: (bool selected) {
                  setState(() {
                    Provider.of<ThemeModel>(context, listen: false)
                        .setLang('wo');
                  });
                },
              ),
              ChoiceChip(
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: userLang == 'fr' ? true : false,
                label: Text(
                  "Français",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                backgroundColor: Theme.of(context).primaryColor,
                selectedColor: Theme.of(context).accentColor,
                onSelected: (bool selected) {
                  setState(() {
                    Provider.of<ThemeModel>(context, listen: false)
                        .setLang('fr');
                  });
                },
              ),
              ChoiceChip(
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: userLang == 'en' ? true : false,
                label: Text(
                  "English",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                backgroundColor: Theme.of(context).primaryColor,
                selectedColor: Theme.of(context).accentColor,
                onSelected: (bool selected) {
                  setState(() {
                    Provider.of<ThemeModel>(context, listen: false)
                        .setLang('en');
                  });
                },
              ),
            ],
          ),
        ],
      );
    }

    Widget downloadPermissionTitle() {
      return settingTitle(AppLocalization.of(context).downloadTitle,
          Icons.download_sharp, null);
    }

    Widget downloadPermissionSetting() {
      bool approved = themeProvider.downloadsApproved;

      return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        SizedBox(
          width: 20,
        ),
        Expanded(
          child: Text(
            AppLocalization.of(context).approveDownloads,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
        Checkbox(
          value: approved,
          onChanged: (response) {
            if (response) {
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
                  ? Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      FlatButton.icon(
                        color: Theme.of(context).cardColor,
                        icon: Icon(Icons.delete_sweep_sharp),
                        label: Text(
                            'Delete downloads (' +
                                snapshot.data.toString() +
                                ' Mb)',
                            style: Theme.of(context).textTheme.subtitle1),
                        onPressed: () {
                          print('clear all downloads');
                          _deleteAllDownloads();
                          Provider.of<Shows>(context, listen: false)
                              .setReloadMainPage(true);
                          setState(() {});
                        },
                      ),
                      SizedBox(
                        width: 20,
                      )
                    ])
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
          AppLocalization.of(context).settingsTitle,
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
                  settingRow(
                      downloadPermissionTitle(), downloadPermissionSetting()),
                  clearDownloads(),
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

                settingColumn(
                    downloadPermissionTitle(), downloadPermissionSetting()),
                clearDownloads(),
              ],
            ),
      // ),
    );
  }
}
