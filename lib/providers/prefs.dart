import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:core';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs with ChangeNotifier {
  bool textDirection;
  bool imageEnabled;
  bool wolofVerseEnabled;
  bool wolofalVerseEnabled;
  bool showFavs;
  bool showOnboarding;

  UserPrefs({
    this.textDirection,
    this.imageEnabled,
    this.wolofVerseEnabled,
    this.wolofalVerseEnabled,
    this.showFavs,
    this.showOnboarding,
  });

  UserPrefs _userPrefs;

  UserPrefs get userPrefs {
    return _userPrefs;
  }

  Future<void> setupUserPrefs() async {
    //get the prefs
    final prefs = await SharedPreferences.getInstance();
    //if there's no userTheme, it's the first time they've run the app, so give them lightTheme
    //We're also grabbing other setup info here: language:

    if (!prefs.containsKey('userPrefs')) {
      UserPrefs defaultUserPrefs = UserPrefs(
        //Starting off LTR as in English - the relevant setting is PageView(reverse: false) = LTR
        textDirection: false,
        imageEnabled: true,
        wolofVerseEnabled: true,
        wolofalVerseEnabled: true,
        showFavs: false,
        showOnboarding: true,
      );
      //Set in-memory copy of prefs
      _userPrefs = defaultUserPrefs;
      //Save prefs to disk
      final _defaultUserPrefs = json.encode({
        'textDirection': false,
        'imageEnabled': true,
        'wolofVerseEnabled': true,
        'wolofalVerseEnabled': true,
        'showFavs': false,
        'showOnboarding': true,
      });
      prefs.setString('userPrefs', _defaultUserPrefs);
    } else {
      final jsonResponse =
          json.decode(prefs.getString('userPrefs')) as Map<String, Object>;
      _userPrefs = UserPrefs(
        textDirection: jsonResponse['textDirection'],
        imageEnabled: jsonResponse['imageEnabled'],
        wolofVerseEnabled: jsonResponse['wolofVerseEnabled'],
        wolofalVerseEnabled: jsonResponse['wolofalVerseEnabled'],
        showFavs: jsonResponse['showFavs'],
        showOnboarding: jsonResponse['showOnboarding'],
      );

      // notifyListeners();
    }
  }

  Future<void> savePref(String setting, userPref) async {
    //get the prefs
    final prefs = await SharedPreferences.getInstance();
    final jsonResponse =
        json.decode(prefs.getString('userPrefs')) as Map<String, Object>;
    var _tempUserPrefs = UserPrefs(
      textDirection: jsonResponse['textDirection'],
      imageEnabled: jsonResponse['imageEnabled'],
      wolofVerseEnabled: jsonResponse['wolofVerseEnabled'],
      wolofalVerseEnabled: jsonResponse['wolofalVerseEnabled'],
      showFavs: jsonResponse['showFavs'],
      showOnboarding: jsonResponse['showOnboarding'],
    );

    //set the incoming setting
    if (setting == 'textDirection') {
      _tempUserPrefs.textDirection = userPref;
    } else if (setting == 'imageEnabled') {
      _tempUserPrefs.imageEnabled = userPref;
    } else if (setting == 'wolofVerseEnabled') {
      _tempUserPrefs.wolofVerseEnabled = userPref;
    } else if (setting == 'wolofalVerseEnabled') {
      _tempUserPrefs.wolofalVerseEnabled = userPref;
    } else if (setting == 'showFavs') {
      _tempUserPrefs.showFavs = userPref;
    } else if (setting == 'showOnboarding') {
      _tempUserPrefs.showOnboarding = userPref;
    }

    //now set it in memory
    _userPrefs = _tempUserPrefs;
    // notifyListeners();
    //now save it to disk
    final _prefsToWrite = json.encode({
      'textDirection': _tempUserPrefs.textDirection,
      'imageEnabled': _tempUserPrefs.imageEnabled,
      'wolofVerseEnabled': _tempUserPrefs.wolofVerseEnabled,
      'wolofalVerseEnabled': _tempUserPrefs.wolofalVerseEnabled,
      'showFavs': _tempUserPrefs.showFavs,
      'showOnboarding': _tempUserPrefs.showOnboarding,
    });
    prefs.setString('userPrefs', _prefsToWrite);
  }
}
