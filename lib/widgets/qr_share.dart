import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart'; // the new Flutter 3.x localization method

enum ShareApp { android, iOS, web, windows, site }

List<ShareAppData> shareAppData = [
  ShareAppData(
      label: 'Google Play',
      shareApp: ShareApp.android,
      socialIcon: '\uf3ab',
      link: 'https://play.google.com/store/apps/details?id=org.sim.pbs'),
  ShareAppData(
      label: 'iOS & macOS',
      shareApp: ShareApp.iOS,
      socialIcon: '\uf179',
      link: 'https://apps.apple.com/us/app/livros/id6740412031'),
  ShareAppData(
      label: 'Windows',
      shareApp: ShareApp.windows,
      socialIcon: '\uF17a',
      link: 'https://apps.microsoft.com/detail/9n96dbz3vvvs'),
  ShareAppData(
      label: 'web',
      shareApp: ShareApp.web,
      socialIcon: '\uf268',
      link: 'https://go.livros.app'),
  ShareAppData(
      label: 'livros.app',
      shareApp: ShareApp.site,
      icon: Icons.public,
      link: 'https://livros.app'),
];

class ShareAppPanel extends StatefulWidget {
  const ShareAppPanel({super.key});

  @override
  State<ShareAppPanel> createState() => _ShareAppPanelState();
}

class _ShareAppPanelState extends State<ShareAppPanel> {
  ShareAppData currentShare = shareAppData[0];

  @override
  void initState() {
    try {
      if (kIsWeb) {
        currentShare = shareAppData
            .where((element) => element.shareApp == ShareApp.web)
            .first;
      } else if (Platform.isIOS || Platform.isMacOS) {
        currentShare = shareAppData
            .where((element) => element.shareApp == ShareApp.iOS)
            .first;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;
    Size size = MediaQuery.sizeOf(context);

    Color foregroundColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    List<ButtonSegment<ShareAppData>> segments =
        List.generate(shareAppData.length, (i) {
      return ButtonSegment<ShareAppData>(
        value: shareAppData[i],
        label: shareAppData[i].socialIcon != null
            ? Text(shareAppData[i].socialIcon!,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontFamily: 'SocialIcons'))
            : shareAppData[i].icon != null
                ? Icon(shareAppData[i].icon, size: 24, color: foregroundColor)
                : null,
      );
    });

    linkShare() async {
      // final size = MediaQuery.of(context).size;

      debugPrint(size.toString());
      if (!kIsWeb) {
        SharePlus.instance.share(ShareParams(
          text: currentShare.link,
          sharePositionOrigin:
              Rect.fromLTWH(0, 0, size.width, size.height * .33),
        ));
      } else {
        String url = "mailto:?subject=Livros&body=${currentShare.link}";

        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $url';
        }
      }
    }

    linkCopy() {
      try {
        Clipboard.setData(ClipboardData(text: currentShare.link));
        showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) => AlertDialog(
                  content: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50.0),
                    child: Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.green),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                        )),
                  ),
                ));
        Future.delayed(const Duration(seconds: 1), () {
          if (!context.mounted) return;
          Navigator.of(context).pop();
        });
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    return SingleChildScrollView(
        child: SizedBox(
      width: min(400, size.width),
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (size.height > 600)
                Image.asset('assets/icons/livros_icon_round.png',
                    width: 60, height: 60),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: QrImageView(
                  data: currentShare.link,
                  version: QrVersions.auto,
                  eyeStyle: QrEyeStyle(color: foregroundColor),
                  dataModuleStyle: QrDataModuleStyle(color: foregroundColor),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilledButton.icon(
                      onPressed: linkShare,
                      icon: const Icon(Icons.share),
                      label: Text(localizations.shareLink)),
                  FilledButton.tonalIcon(
                    onPressed: linkCopy,
                    icon: const Icon(Icons.copy),
                    label: Text(localizations.copyLink),
                  ),
                ],
              ),
              const Divider(height: 40),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  currentShare.label,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              SegmentedButton<ShareAppData>(
                // direction: Axis.vertical,
                segments: segments,
                showSelectedIcon: size.width > 300,
                selected: {currentShare},
                onSelectionChanged: (Set<ShareAppData> incoming) {
                  setState(() {
                    currentShare = incoming.first;
                  });
                },
              ),
              const SizedBox(height: 50),
              // Image.asset('assets/icons/livros_icon_round.png',
              //     width: 100, height: 100)
            ],
          )),
    ));
  }
}

class ShareAppData {
  String label;
  ShareApp shareApp;
  String? socialIcon;
  IconData? icon;
  String link;

  ShareAppData(
      {required this.label,
      required this.shareApp,
      this.socialIcon,
      this.icon,
      required this.link});
}
