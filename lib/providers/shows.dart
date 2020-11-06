import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:math';
import 'dart:async';
import 'dart:convert';

class Show {
  final String id;
  final String showNameRS;
  final String showNameAS;
  final String urlSnip;
  final String filename;
  const Show({
    @required this.id,
    @required this.showNameRS,
    @required this.showNameAS,
    @required this.urlSnip,
    @required this.filename,
  });
}

class Shows with ChangeNotifier {
  List<Show> _shows = [];

  List<Show> get shows {
    return [..._shows];
  }

  int _lastShowViewed;

  int get lastShowViewed {
    return _lastShowViewed;
  }

  String get urlBase {
    return 'https://bienvenueafricains.com/mp3/wolof/the-way-of-righteousness';
  }

  Future getData() async {
    //check if the current session still contains the shows - if so no need to rebuild
    if (_shows.length != 0) {
      return;
    }

    //temporary simple list for holding data
    final List<Show> loadedShowData = [];

    //Get the data from json file
    String showsJSON = await rootBundle.loadString("assets/shows.json");
    final showsData = json.decode(showsJSON) as List<dynamic>;

    //So we have the info but it's in the wrong format - here map it to our class
    showsData.forEach((show) {
      loadedShowData.add(
        Show(
            id: show['id'],
            showNameRS: show['showNameRS'],
            showNameAS: show['showNameAS'],
            urlSnip: show['urlSnip'],
            filename: show['filename']),
      );
    });

    _shows = loadedShowData;

    getLastShowViewed();

    notifyListeners();
  }

  Future<void> saveLastShowViewed(lastShowViewed) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = json.encode(lastShowViewed.toString());
    prefs.setString('lastShowViewed', jsonData);
  }

  Future<int> getLastShowViewed() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('lastShowViewed')) {
      return 0;
    } else {
      final storedValue = json.decode(prefs.getString('lastShowViewed'));
      int _lastShowViewed = int.parse(storedValue);
      return _lastShowViewed;
    }
  }
}
