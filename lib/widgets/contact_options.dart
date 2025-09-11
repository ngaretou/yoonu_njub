import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'dart:io';
import '../l10n/app_localizations.dart';
import 'deep_link.dart'; //for WhatsApp link below

class ContactOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                          )
                        : Icon(
                            icon,
                            size: 27,
                          ),
                    SizedBox(width: 25),
                    Expanded(
                        child: Text(title,
                            style: Theme.of(context).textTheme.titleLarge!)),
                  ],
                ))),
      );
    }

    return Column(
      children: [
        drawerTitle(
          AppLocalizations.of(context)!.settingsContactUsTelephone,
          Icons.phone,
          () async {
            const url = 'tel:221777758702';
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url));
            } else {
              throw 'Could not launch $url';
            }
            Navigator.of(context).pop();
          },
        ),

        // drawerTitle(
        //   AppLocalizations.of(context)!.settingsContactUsEmail,
        //   Icons.email,
        //   () async {
        //     const url = 'mailto:equipedevmbs@gmail.com';
        //     if (await canLaunchUrl(Uri.parse(url))) {
        //       await launchUrl(Uri.parse(url));
        //     } else {
        //       throw 'Could not launch $url';
        //     }
        //     Navigator.of(context).pop();
        //   },
        // ),
        drawerTitle(
          AppLocalizations.of(context)!.contactWhatsApp,
          FontAwesomeIcons.whatsapp,
          () async {
            launchDeepLink('whatsapp', '221777758702');
            Navigator.of(context).pop();
          },
        ),
        // drawerTitle(
        //   AppLocalizations.of(context)!.contactFBMessenger,
        //   FontAwesomeIcons.facebookMessenger,
        //   () async {
        //     launchDeepLink('fb', '107408064239821');
        //     Navigator.of(context).pop();
        //   },
        // ),
      ],
    );
  }
}
