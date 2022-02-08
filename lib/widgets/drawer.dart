import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../screens/about_screen.dart';
import '../screens/settings_screen.dart';

import 'contact_options.dart';
import 'deep_link.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TextStyle drawerEntryStyle = Theme.of(context).textTheme.headline6!;
    // TextStyle whiteHeadline6 = drawerEntryStyle.copyWith(color: Colors.white);

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
                      style: Theme.of(context).textTheme.headline6,
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
                      title, style: Theme.of(context).textTheme.headline6,
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
      child: Container(
        width: MediaQuery.of(context).size.width * .8,
        //The color of the Drawer
        color: Theme.of(context).appBarTheme.backgroundColor,
        child: ListView(
          children: [
            //Main title
            Container(
                child: Padding(
                    padding: EdgeInsets.only(
                        top: 30, bottom: 20, left: 20, right: 20),
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.road,
                          size: 27,
                          // color: Theme.of(context).appBarTheme.iconTheme!.color,
                        ),
                        SizedBox(width: 25),
                        Text("Yoonu Njub",
                            style: Theme.of(context).textTheme.headline5)
                      ],
                    ))),
            Divider(
              thickness: 3,
            ),
            drawerTitle(
              AppLocalizations.of(context).settingsTitle,
              Icons.settings,
              () {
                Navigator.of(context).popAndPushNamed(SettingsScreen.routeName);
              },
            ),

            // Divider(
            //   thickness: 1,
            // ),

            drawerTitle(
              AppLocalizations.of(context).shareAppLink,
              Icons.share,
              () async {
                Navigator.of(context).pop();
                if (!kIsWeb) {
                  Share.share('https://sng.al/yn');
                } else {
                  const url =
                      "mailto:?subject=Yoonu Njub&body=Xoolal appli Yoonu Njub fii: https://sng.al/yn";
                  if (await canLaunch(url)) {
                    await launch(url);
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
              AppLocalizations.of(context).moreApps,
              Icons.apps,
              () async {
                const url = 'https://sng.al/app';
                if (await canLaunch(url)) {
                  await launch(url);
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
                          AppLocalizations.of(context).settingsContactUs,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ],
                    ))),

            // drawerTitle(
            //     AppLocalizations.of(context).settingsContactUs, null, null),
            ContactOptions(),

            Divider(
              thickness: 1,
            ),
            drawerTitle(
              AppLocalizations.of(context).settingsAbout,
              Icons.info,
              () {
                Navigator.of(context).popAndPushNamed(AboutScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}
