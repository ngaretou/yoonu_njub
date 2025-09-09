import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:path_provider/path_provider.dart';

import 'package:yoonu_njub/l10n/app_localizations.dart'; // the new Flutter 3.x localization method
import '../providers/theme.dart';
import '../providers/shows.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings-screen';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  //The individual setting headings

  //Main Settings screen construction:
  @override
  Widget build(BuildContext context) {
    int numberOfTaps = 0;
    final themeProvider = Provider.of<ThemeModel>(context, listen: false);
    final ThemeComponents? userTheme = themeProvider.userTheme;
    final Locale userLocale = themeProvider.userLocale ?? Locale('en');

    //Widgets
    //Main template for all setting titles
    Widget settingTitle(String title, IconData icon, Function? tapHandler) {
      return InkWell(
        onTap: tapHandler as void Function()?,
        child: SizedBox(
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
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
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
      return settingTitle(AppLocalizations.of(context)!.settingsTheme,
          Icons.settings_brightness, null);
    }

    Widget languageTitle() {
      return settingTitle(AppLocalizations.of(context)!.settingsLanguage,
          Icons.translate, null);
    }

    Widget themeSettings() {
      List<Color> themeColors = [
        // Colors.red,
        // Colors.deepOrange,
        // Colors.amber,
        Colors.lightGreen,
        Colors.green,
        Colors.teal,
        Colors.cyan,
        Colors.blue,
        Colors.indigo,
        Colors.deepPurple,
        Colors.blueGrey,
        // Colors.brown,
        // Colors.grey
      ];

      List<DropdownMenuItem<String>> menuItems = [];

      for (var color in themeColors) {
        menuItems.add(DropdownMenuItem(
            value: colorToString(color),
            child: Material(
              shape: CircleBorder(side: BorderSide.none),
              elevation: 2,
              child: Container(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                margin: EdgeInsets.all(0),
                width: 36,
              ),
            )));
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DropdownButton(
              itemHeight: 48,
              underline: SizedBox(),
              value: colorToString(userTheme?.color ?? Colors.teal),
              items: menuItems,
              onChanged: (response) {
                Color color = colorFromString(response.toString());

                ThemeComponents themeToSet = ThemeComponents(
                    brightness: userTheme?.brightness ?? Brightness.light,
                    color: color);

                themeProvider.setTheme(themeToSet);
              }),
          Container(
              height: 45,
              width: 1,
              color: Theme.of(context).colorScheme.outline),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.all(0),
              shape: CircleBorder(),
            ),
            onPressed: () {
              ThemeComponents themeToSet = ThemeComponents(
                  brightness: Brightness.light,
                  color: userTheme?.color ?? Colors.teal);

              themeProvider.setTheme(themeToSet);
            },
            child: userTheme?.brightness == Brightness.light
                ? Icon(
                    Icons.check,
                    color: Colors.black,
                  )
                : null,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: EdgeInsets.all(0),
              shape: CircleBorder(),
            ),
            onPressed: () {
              ThemeComponents themeToSet = ThemeComponents(
                  brightness: Brightness.dark,
                  color: userTheme?.color ?? Colors.teal);

              themeProvider.setTheme(themeToSet);
            },
            child: userTheme?.brightness == Brightness.dark
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                  )
                : null,
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
                  style: Theme.of(context).textTheme.titleMedium,
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onSelected: (bool selected) {
                  themeProvider.setLocale('fr');
                  debugPrint(AppLocalizations.of(context)!.addHolidays);
                },
              ),
              ChoiceChip(
                padding: EdgeInsets.symmetric(horizontal: 10),
                selected: userLocale.toString() == 'en' ? true : false,
                label: Text(
                  "English",
                  style: Theme.of(context).textTheme.titleMedium,
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
      return settingTitle(AppLocalizations.of(context)!.downloadTitle,
          Icons.download_sharp, null);
    }

    Widget downloadPermissionSetting() {
      bool approved = themeProvider.downloadsApproved ?? false;
      debugPrint(Theme.of(context).primaryColor.toString());

      return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        SizedBox(
          width: 20,
        ),
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.approveDownloads,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Checkbox(
          activeColor: Theme.of(context).colorScheme.primary,
          checkColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black87
              : Colors.white,
          value: approved,
          onChanged: (response) {
            if (response == null) return;

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

    Future<String> getSizeOfAllDownloads() async {
      final directory = await getApplicationDocumentsDirectory();
      int counter = 0;
      var myStream = directory.list(recursive: false, followLinks: false);
      await for (var element in myStream) {
        if (element is File) {
          counter += await element.length();
        }
      }
      return (counter / 1000000).toStringAsFixed(2);
    }

    Future<void> deleteAllDownloads() async {
      final directory = await getApplicationDocumentsDirectory();
      int counter = 0;
      var myStream = directory.list(recursive: false, followLinks: false);
      await for (var element in myStream) {
        if (element is File) {
          element.delete();
        }
      }
      downloadedBox.clear();
    }

    Widget clearDownloads() {
      return FutureBuilder(
          future: getSizeOfAllDownloads(),
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
                                    '${AppLocalizations.of(context)!.deleteDownloads} (${snapshot.data} Mb)',
                                    // style: Theme.of(context)
                                    //     .textTheme
                                    //     .titleLarge
                                  ),
                                ),
                              ],
                            )),
                        onPressed: () {
                          deleteAllDownloads();

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
      return SizedBox(
          height: 70,
          child: GestureDetector(
            onTap: () {
              numberOfTaps++;
              debugPrint(numberOfTaps.toString());
              if (numberOfTaps == 6) {
                debugPrint('check all shows');
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
          AppLocalizations.of(context)!.settingsTitle,
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
