import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:yoonu_njub/l10n/app_localizations.dart'; // the new Flutter 3.x localization method

import '../screens/settings_screen.dart';
import '../screens/about_screen.dart';

import 'contact_options.dart';
import 'deep_link.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TextStyle drawerEntryStyle = Theme.of(context).textTheme.titleLarge!;
    // TextStyle whitetitleLarge = drawerEntryStyle.copyWith(color: Colors.white);

    // TextStyle drawerEntryStyle = Theme.of(context)
    //     .appBarTheme
    //     .titleTextStyle /*!*/ .copyWith(color: Colors.white);

    //Main template for all titles
    Widget drawerTitle(String title, IconData icon, Function tapHandler) {
      return InkWell(
        onTap: tapHandler as void Function()?,
        child: Container(
            width: 300,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    icon.toString().startsWith("FontAwesomeIcons")
                        ? FaIcon(
                            icon,
                            size: 27,

                            // color:
                            //     Theme.of(context).appBarTheme.iconTheme!.color
                          )
                        : Icon(
                            icon,
                            size: 27,
                            // color:
                            //     Theme.of(context).appBarTheme.iconTheme!.color,
                          ),
                    SizedBox(width: 25),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ))),
      );
    }

    Widget drawerTileWithFormatting(title, icon, tapHandler) {
      return InkWell(
        onTap: tapHandler,
        child: Container(
            width: 300,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    icon.toString().startsWith("FontAwesomeIcons")
                        ? FaIcon(
                            icon,
                            size: 27,
                            // color:
                            //     Theme.of(context).appBarTheme.iconTheme!.color
                          )
                        : Icon(
                            icon,
                            size: 27,
                            // color:
                            //     Theme.of(context).appBarTheme.iconTheme!.color,
                          ),
                    SizedBox(width: 25),
                    Text(
                      title, style: Theme.of(context).textTheme.titleLarge,
                      // style:
                      //     (Theme.of(context).appBarTheme.titleTextStyle) /*!*/
                      //         .copyWith(fontStyle: FontStyle.italic)),
                      // style:
                      //     (Theme.of(context).appBarTheme.titleTextStyle) /*!*/
                      // ),
                    ),
                    // )
                  ],
                ))),
      );
    }

    return Drawer(
      elevation: 5.0,
      child: ListView(
        children: [
          //Main title
          Container(
              child: Padding(
                  padding:
                      EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
                  child: Row(
                    children: [
                      Container(
                        // child: Image.asset('assets/icons/icon.png'),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/icons/icon.png"),
                          ),
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                        ),
                      ),
                      SizedBox(width: 25),
                      Text("Yoonu Njub",
                          style: Theme.of(context).textTheme.titleLarge)
                    ],
                  ))),
          Divider(
            thickness: 3,
          ),
          drawerTitle(
            AppLocalizations.of(context)!.settingsTitle,
            Icons.settings,
            () {
              Navigator.of(context).popAndPushNamed(SettingsScreen.routeName);
            },
          ),

          // Divider(
          //   thickness: 1,
          // ),

          drawerTitle(
            AppLocalizations.of(context)!.shareAppLink,
            Icons.share,
            () async {
              Navigator.of(context).pop();
              if (!kIsWeb) {
                SharePlus.instance
                    .share(ShareParams(text: 'https://sng.al/yn'));
              } else {
                const url =
                    "mailto:?subject=Yoonu Njub&body=Xoolal appli Yoonu Njub fii: https://sng.al/yn";
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                } else {
                  throw 'Could not launch $url';
                }
              }
            },
          ),

          // Divider(
          //   thickness: 1,
          // ),
          drawerTitle(
            AppLocalizations.of(context)!.moreApps,
            Icons.apps,
            () async {
              const url = 'https://sng.al/app';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              } else {
                throw 'Could not launch $url';
              }
            },
          ),
          // Divider(
          //   thickness: 1,
          // ),

          //Buuru Ndam
          drawerTileWithFormatting(
            "Buuru Ndam",
            Icons.ondemand_video,
            () async {
              launchDeepLink('youtube', '99McEuAtRkk');
            },
          ),
          //Contact Us section
          Divider(
            thickness: 1,
          ),

          Container(
              width: 300,
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.settingsContactUs,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ))),

          // drawerTitle(
          //     AppLocalizations.of(context)!.settingsContactUs, null, null),
          ContactOptions(),

          Divider(
            thickness: 1,
          ),
          drawerTitle(
            AppLocalizations.of(context)!.settingsAbout,
            Icons.info,
            () {
              Navigator.of(context).pop();
              showAbout(context);
            },
          ),
        ],
      ),
    );
  }
}

void showAbout(BuildContext context) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text(packageInfo.appName),
          content: SingleChildScrollView(
              child: ListBody(children: [
            Row(
              children: [
                Container(
                  // child: Image.asset('assets/icons/icon.png'),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/icons/icon.png"),
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: Text(
                        packageInfo.appName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Text(
                        'Version ${packageInfo.version} (${packageInfo.buildNumber})'),
                    const Text('© 2023 Foundational'),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            RichText(
                text: TextSpan(
              children: [
                TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge,
                  text: 'Emissions ',
                ),
                TextSpan(
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontStyle: FontStyle.italic),
                  text: 'Yoonu Njub',
                ),
                TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge,
                  text: ' © 2020 ROCK International.',
                ),
              ],
            )),
          ])),
          actions: <Widget>[
            OutlinedButton(
              child: const Text('Copyrights'),
              onPressed: () {
                Navigator.of(context).pushNamed(AboutScreen.routeName);
              },
            ),
            OutlinedButton(
              child: const Text('Licenses'),
              onPressed: () {
                // Navigator.of(context).pop();
                showLicenses(context,
                    appName: packageInfo.appName,
                    appVersion:
                        '${packageInfo.version} (${packageInfo.buildNumber})');
              },
            ),
            OutlinedButton(
              child: Text(AppLocalizations.of(context)!.settingsOK),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}

void showLicenses(BuildContext context, {String? appName, String? appVersion}) {
  void showLicensePage({
    required BuildContext context,
    String? applicationName,
    String? applicationVersion,
    Widget? applicationIcon,
    String? applicationLegalese,
    bool useRootNavigator = false,
  }) {
    // assert(context != null);
    // assert(useRootNavigator != null);
    Navigator.of(context, rootNavigator: useRootNavigator)
        .push(MaterialPageRoute<void>(
      builder: (BuildContext context) => LicensePage(
        applicationName: applicationName,
        applicationVersion: applicationVersion,
        applicationIcon: applicationIcon,
        applicationLegalese: applicationLegalese,
      ),
    ));
  }

  showLicensePage(
      context: context,
      applicationVersion: appVersion,
      applicationName: appName,
      useRootNavigator: true);
}
