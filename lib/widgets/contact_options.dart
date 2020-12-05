import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../locale/app_localization.dart';

class ContactOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                    Expanded(
                      child: Text(title,
                          style: Theme.of(context)
                              .appBarTheme
                              .textTheme
                              .headline6),
                    ),
                  ],
                ))),
      );
    }

    return Column(
      children: [
        drawerTitle(
          AppLocalization.of(context).settingsContactUsEmail,
          Icons.email,
          () async {
            const url = 'mailto:equipedevmbs@gmail.com';
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
            Navigator.of(context).pop();
          },
        ),
        drawerTitle(
          AppLocalization.of(context).contactWhatsApp,
          FontAwesomeIcons.whatsapp,
          () async {
            const url = 'https://wa.me/221776427432';
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
            Navigator.of(context).pop();
          },
        ),
        drawerTitle(
          AppLocalization.of(context).contactFBMessenger,
          FontAwesomeIcons.facebookMessenger,
          () async {
            const url = 'https://m.me/kaddugyallagi/';
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
