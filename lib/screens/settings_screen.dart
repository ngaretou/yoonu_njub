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
    int numberOfTaps = 0;
    final themeProvider = Provider.of<ThemeModel>(context, listen: false);
    final ThemeComponents? _userTheme = themeProvider.userTheme;
    final Locale userLocale = themeProvider.userLocale!;

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
          VerticalDivider(
            width: 10,
          ),
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
      List<Color> themeColors = [
        // Colors.red,
        // Colors.deepOrange,
        // Colors.amber,
        // Colors.lightGreen,
        Colors.green,
        Colors.teal,
        Colors.cyan,
        Colors.blue,
        // Colors.indigo,
        // Colors.deepPurple,
        // Colors.blueGrey,
        // Colors.brown,
        // Colors.grey
      ];

      List<DropdownMenuItem<String>> menuItems = [];

      for (var color in themeColors) {
        menuItems.add(DropdownMenuItem(
            child: Material(
              shape: CircleBorder(side: BorderSide.none),
              elevation: 2,
              child: Container(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                margin: EdgeInsets.all(0),
                width: 36,
              ),
            ),
            value: color.value.toString()));
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DropdownButton(
              itemHeight: 48,
              underline: SizedBox(),
              value: _userTheme!.color.value.toString(),
              items: menuItems,
              onChanged: (response) {
                int _colorValue = int.parse(response.toString());

                Color color = Color(_colorValue).withOpacity(1);

                ThemeComponents _themeToSet = ThemeComponents(
                    brightness: _userTheme.brightness, color: color);

                themeProvider.setTheme(_themeToSet);
              }),
          Container(
              height: 45,
              width: 1,
              color: Theme.of(context).colorScheme.outline),
          ElevatedButton(
            child: _userTheme.brightness == Brightness.light
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
              ThemeComponents _themeToSet = ThemeComponents(
                  brightness: Brightness.light, color: _userTheme.color);

              themeProvider.setTheme(_themeToSet);
            },
          ),
          ElevatedButton(
            child: _userTheme.brightness == Brightness.dark
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
              ThemeComponents _themeToSet = ThemeComponents(
                  brightness: Brightness.dark, color: _userTheme.color);

              themeProvider.setTheme(_themeToSet);
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
                onSelected: (bool selected) {
                  themeProvider.setLocale('fr');
                  print(AppLocalizations.of(context).addHolidays);
                },
              ),
              ChoiceChip(
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: userLocale.toString() == 'en' ? true : false,
                label: Text(
                  "English",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
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
      print(Theme.of(context).primaryColor);

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
          activeColor: Theme.of(context).colorScheme.primary,
          checkColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black87
              : Colors.white,
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
                      child: ElevatedButton(
                        child: Container(
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
                                    // style: Theme.of(context)
                                    //     .textTheme
                                    //     .headline6
                                  ),
                                ),
                              ],
                            )),
                        onPressed: () {
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

    Widget hiddenCheckShowsButton(BuildContext context) {
      //Having a button to verify the presence of all shows on the internet is great,
      //but not necessarily something all should see right off. This button is 'hidden' in that it is not visible,
      //tap 6 times and the function kicks off.
      return Container(
          height: 70,
          child: GestureDetector(
            onTap: () {
              numberOfTaps++;
              print(numberOfTaps);
              if (numberOfTaps == 6) {
                print('check all shows');
                Provider.of<Shows>(context, listen: false)
                    .checkAllShowsDialog(context);
                numberOfTaps = 0;
              }
            },
          ));
    }

    //This just gives a test button for messaging troubleshooting
    // ignore: unused_element
    // Widget messagingButton() {
    //   return Center(
    //     child: ElevatedButton(
    //         onPressed: () {
    //           Provider.of<Shows>(context, listen: false)
    //               .sendMessage('Test message');
    //         },
    //         child: Text('Test Messaging')),
    //   );
    // }

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
          //tablet/web version
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: ListView(
                children: [
                  settingRow(themeTitle(), themeSettings()),
                  Divider(),
                  settingRow(languageTitle(), languageSetting()),
                  Divider(),
                  if (!kIsWeb)
                    settingRow(
                        downloadPermissionTitle(), downloadPermissionSetting()),
                  if (!kIsWeb) clearDownloads(),
                  //Button to check all shows for current presence online
                  if (!kIsWeb) hiddenCheckShowsButton(context)
                ],
              ),
            )
          //phone view
          : ListView(
              children: [
                settingColumn(themeTitle(), themeSettings()),
                settingColumn(languageTitle(), languageSetting()),
                //A few things here that we do not need or that do not work correctly on web version:
                if (!kIsWeb)
                  settingColumn(
                      downloadPermissionTitle(), downloadPermissionSetting()),
                if (!kIsWeb) clearDownloads(),
                if (!kIsWeb) hiddenCheckShowsButton(context)
                // messagingButton(),
              ],
            ),
      // ),
    );
  }
}
