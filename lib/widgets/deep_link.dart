import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:url_launcher/url_launcher.dart';

//This gives a centralized way of handling deep links and urls
Future<void> launchDeepLink(String appToLaunch, String identifier) async {
  String url, urlPrefix, deepLink, appURLScheme;

  if (appToLaunch == 'youtube') {
    urlPrefix = 'https://youtu.be/';
    appURLScheme = 'youtube://';
  } else if (appToLaunch == 'whatsapp') {
    urlPrefix = 'https://wa.me/';
    appURLScheme = 'whatsapp://';
  } else if (appToLaunch == 'fb') {
    print('in fb');
    urlPrefix = 'https://m.me/';
    appURLScheme = 'fb-messenger-public://';
    identifier = 'user-thread/' + identifier;
    print(identifier);
  } else {
    print('appToLaunch not found in deep_link.dart');
  }
  deepLink = appURLScheme + identifier;
  url = urlPrefix + identifier;

  //Plain vanilla url launch
  simpleLaunch() async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  //Now figure out what we need to do based on platform
  //If web or Android, a simple launch works well
  if (kIsWeb || Platform.isAndroid) {
    simpleLaunch();
  } else if (Platform.isIOS) {
    //for iOS you can specify the app to launch with
    if (await canLaunch(appURLScheme)) {
      await launch(deepLink, forceSafariVC: false);
    } else {
      await launch(url, forceSafariVC: true);
    }
  } else {
    //none of the above three - eventual desktop version
    simpleLaunch();
  }
}
