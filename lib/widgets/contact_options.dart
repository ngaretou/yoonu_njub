

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'deep_link.dart';

class ContactOptions extends StatelessWidget {
  final Brightness? contextualBrightness;
  ContactOptions([this.contextualBrightness]);

  @override
  Widget build(BuildContext context) {
    late Color? foregroundColor;

    if (contextualBrightness == null) {
      foregroundColor = Theme.of(context).textTheme.headline6!.color;
    } else {
      if (contextualBrightness == Brightness.dark) {
        foregroundColor = ThemeData.dark().textTheme.headline6!.color;
      } else {
        foregroundColor = ThemeData.light().textTheme.headline6!.color;
      }
    }

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
                        ? FaIcon(icon, size: 27, color: foregroundColor)
                        : Icon(
                            icon,
                            size: 27,
                            color: foregroundColor,
                          ),
                    SizedBox(width: 25),
                    Expanded(
                      child: Text(title,
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(color: foregroundColor)),
                    ),
                  ],
                ))),
      );
    }

    return Column(
      children: [
        drawerTitle(
          AppLocalizations.of(context).settingsContactUsEmail,
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
          AppLocalizations.of(context).contactWhatsApp,
          FontAwesomeIcons.whatsapp,
          () async {
            launchDeepLink('whatsapp', '221776427432');
            Navigator.of(context).pop();
          },
        ),
        drawerTitle(
          AppLocalizations.of(context).contactFBMessenger,
          FontAwesomeIcons.facebookMessenger,
          () async {
            launchDeepLink('fb', '107408064239821');
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
