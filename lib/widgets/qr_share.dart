import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart'; // the new Flutter 3.x localization method

void showQrShare(
    BuildContext context, List<ShareAppData> shareData, String appName,
    {Widget? appIcon, double heightPercentage = .9}) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,

    // color must be set in the container below as when theme changes that does change
    // but this doesn't and we have theme change button in this sheet at times
    // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    // scrollControlDisabledMaxHeightRatio: heightPercentage,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
          expand: false,
          snap: true,
          snapSizes: [heightPercentage],
          initialChildSize: heightPercentage,
          minChildSize: .2,
          // no way to get SafeArea consistently so go to 95%
          // don't want handle to get hidden behind state bar
          maxChildSize: .95,
          shouldCloseOnMinExtent: true,
          builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              child: ShareAppPanel(
                appName,
                shareData,
                appIcon: appIcon,
              )));
    },
  );
}

enum ShareApp { android, iOS, web, windows, site }

// List<ShareAppData> shareAppData = [
//   ShareAppData(
//       label: 'Google Play',
//       shareApp: ShareApp.android,
//       socialIcon: '\uf3ab',
//       link: 'https://play.google.com/store/apps/details?id=org.sim.pbs'),
//   ShareAppData(
//       label: 'iOS & macOS',
//       shareApp: ShareApp.iOS,
//       socialIcon: '\uf179',
//       link: 'https://apps.apple.com/us/app/livros/id6740412031'),
//   ShareAppData(
//       label: 'Windows',
//       shareApp: ShareApp.windows,
//       socialIcon: '\uF17a',
//       link: 'https://apps.microsoft.com/detail/9n96dbz3vvvs'),
//   ShareAppData(
//       label: 'web',
//       shareApp: ShareApp.web,
//       socialIcon: '\uf268',
//       link: 'https://go.livros.app'),
//   ShareAppData(
//       label: 'livros.app',
//       shareApp: ShareApp.site,
//       icon: Icons.public,
//       link: 'https://livros.app'),
// ];

class ShareAppPanel extends StatefulWidget {
  final String appName;
  final List<ShareAppData> shareAppData;
  final Widget? appIcon;

  const ShareAppPanel(this.appName, this.shareAppData,
      {this.appIcon, super.key});

  @override
  State<ShareAppPanel> createState() => _ShareAppPanelState();
}

class _ShareAppPanelState extends State<ShareAppPanel> {
  late ShareAppData currentShare;

  @override
  void initState() {
    currentShare = widget.shareAppData[0];
    try {
      if (kIsWeb) {
        currentShare = widget.shareAppData
            .where((element) => element.shareApp == ShareApp.web)
            .first;
      } else if (Platform.isIOS || Platform.isMacOS) {
        currentShare = widget.shareAppData
            .where((element) => element.shareApp == ShareApp.iOS)
            .first;
      } else if (Platform.isAndroid) {
        currentShare = widget.shareAppData
            .where((element) => element.shareApp == ShareApp.android)
            .first;
      }
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
      currentShare = widget.shareAppData[0];
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
        List.generate(widget.shareAppData.length, (i) {
      return ButtonSegment<ShareAppData>(
        value: widget.shareAppData[i],
        label: widget.shareAppData[i].socialIcon != null
            ? Text(widget.shareAppData[i].socialIcon!,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontFamily: 'SocialIcons'))
            : widget.shareAppData[i].icon != null
                ? Icon(widget.shareAppData[i].icon,
                    size: 24, color: foregroundColor)
                : null,
      );
    });

    linkShare() async {
      if (!kIsWeb) {
        SharePlus.instance.share(ShareParams(
          text: currentShare.link,
          sharePositionOrigin:
              Rect.fromLTWH(0, 0, size.width, size.height * .33),
        ));
      } else {
        String url =
            "mailto:?subject=${widget.appName}&body=${currentShare.link}";

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
        if (kDebugMode) debugPrint(e.toString());
      }
    }

    // if single share don't show the different platform chooser
    bool singleShare = widget.shareAppData.length == 1;
    print(size.height);
    return SingleChildScrollView(
        child: SizedBox(
      width: min(500, size.width),
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (size.height > 700)
                SizedBox(
                  height: 60,
                  width: 60,
                  child: ClipOval(child: widget.appIcon),
                ),
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
              if (!singleShare) const Divider(height: 40),
              if (!singleShare)
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
              if (!singleShare)
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
