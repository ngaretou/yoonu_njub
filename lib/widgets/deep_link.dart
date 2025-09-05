import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

//This gives a centralized way of handling deep links and urls
//For iOS, make sure the appURLSchemes are in Info.plist
Future<void> launchDeepLink(String appToLaunch, String identifier) async {
  late String url, urlPrefix, deepLink, appURLScheme, appURLSchemeCompleter;

  if (appToLaunch == 'youtube') {
    urlPrefix = 'https://youtu.be/';
    appURLScheme = 'youtube://';
    appURLSchemeCompleter = identifier;
  } else if (appToLaunch == 'whatsapp') {
    //If WhatsApp is not installed the train of events in iOS is a bit strange -
    //you open the wa.me link, that leads to the full api.whatsapp.com/ link,
    //and that tries to launch using a whatsapp://link, which fails if it's not installed
    //and gives you a funny error. This seems to be an iOS vs WhatsApp issue, not my issue.
    //If you click OK on the error you can still get to the page.
    urlPrefix = 'https://wa.me/';
    appURLScheme = 'whatsapp://';
    appURLSchemeCompleter = identifier;
  } else if (appToLaunch == 'fb') {
    urlPrefix = 'https://m.me/';
    appURLScheme = 'fb-messenger-public://';
    appURLSchemeCompleter = 'user-thread/' + identifier;
  } else {
    debugPrint('appToLaunch not found in deep_link.dart');
  }
  deepLink = appURLScheme + appURLSchemeCompleter;
  url = urlPrefix + identifier;

  //Plain vanilla url launch
  simpleLaunch() async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  //Now figure out what we need to do based on platform
  //If web or Android, a simple launch works well
  if (kIsWeb || Platform.isAndroid || Platform.isMacOS) {
    simpleLaunch();
  } else if (Platform.isIOS) {
    //for iOS you can specify the app to launch with
    //For Android the best way of handling it is to ask the user it seems - I may be wrong about this
    //but in any case
    var appInstalled = await canLaunchUrl(Uri.parse(appURLScheme));

    if (appInstalled) {
      //forceSafariVC is false to get it to open in the installed app
      await launchUrl(Uri.parse(deepLink));
    } else {
      //Launch the regular url in the Safari View Controller, which comes as a
      //layover on top of the app rather than zooming in and out of the app
      await launchUrl(Uri.parse(url));
    }
  } else {
    //none of the above three - eventual desktop version
    simpleLaunch();
  }
}
