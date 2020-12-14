import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../locale/app_localization.dart';

import '../screens/about_screen.dart';
import '../screens/settings_screen.dart';

import 'contact_options.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Main template for all titles
    Widget drawerTitle(String title, IconData icon, Function tapHandler) {
      return InkWell(
        onTap: tapHandler,
        child: Container(
            width: 300,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    icon.toString().startsWith("FontAwesomeIcons")
                        ? FaIcon(icon,
                            size: 27,
                            color:
                                Theme.of(context).appBarTheme.iconTheme.color)
                        : Icon(
                            icon,
                            size: 27,
                            color:
                                Theme.of(context).appBarTheme.iconTheme.color,
                          ),
                    SizedBox(width: 25),
                    Text(title,
                        style:
                            Theme.of(context).appBarTheme.textTheme.headline6),
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
                        ? FaIcon(icon,
                            size: 27,
                            color:
                                Theme.of(context).appBarTheme.iconTheme.color)
                        : Icon(
                            icon,
                            size: 27,
                            color:
                                Theme.of(context).appBarTheme.iconTheme.color,
                          ),
                    SizedBox(width: 25),
                    Text(title,
                        style:
                            (Theme.of(context).appBarTheme.textTheme.headline6)
                                .copyWith(fontStyle: FontStyle.italic)),
                  ],
                ))),
      );
    }

    return Drawer(
      elevation: 5.0,
      child: Container(
        width: MediaQuery.of(context).size.width * .8,
        color: Theme.of(context).appBarTheme.color,
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
                          color: Theme.of(context).appBarTheme.iconTheme.color,
                        ),
                        SizedBox(width: 25),
                        Text("Yoonu Njub",
                            style: Theme.of(context)
                                .appBarTheme
                                .textTheme
                                .headline6
                                .copyWith(
                                  fontSize: 24,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: -0.5,
                                ))
                      ],
                    ))),
            Divider(
              thickness: 3,
            ),
            drawerTitle(
              AppLocalization.of(context).settingsTitle,
              Icons.settings,
              () {
                Navigator.of(context).popAndPushNamed(SettingsScreen.routeName);
              },
            ),

            Divider(
              thickness: 1,
            ),

            drawerTitle(
              AppLocalization.of(context).shareAppLink,
              Icons.share,
              () async {
                Navigator.of(context).pop();
                Share.share('https://sng.al/yn');
              },
            ),

            Divider(
              thickness: 1,
            ),
            drawerTitle(
              AppLocalization.of(context).moreApps,
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
            Divider(
              thickness: 1,
            ),
            //Buuru Ndam

            drawerTileWithFormatting(
              "Buuru Ndam",
              Icons.ondemand_video,
              () async {
                const url = 'https://youtu.be/99McEuAtRkk';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            //Contact Us section
            Divider(
              thickness: 2,
            ),

            Container(
                width: 300,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Text(AppLocalization.of(context).settingsContactUs,
                            style: Theme.of(context)
                                .appBarTheme
                                .textTheme
                                .headline6),
                      ],
                    ))),

            // drawerTitle(
            //     AppLocalization.of(context).settingsContactUs, null, null),
            ContactOptions(),
            Divider(
              thickness: 2,
            ),
            drawerTitle(
              AppLocalization.of(context).settingsAbout,
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
