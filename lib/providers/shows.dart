import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity/connectivity.dart';
// import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

    var temp = await getLastShowViewed();
    temp == null ? temp = 0 : _lastShowViewed = temp;

    notifyListeners();
  }

  Future<void> saveLastShowViewed(lastShowViewed) async {
    _lastShowViewed = lastShowViewed;
    final prefs = await SharedPreferences.getInstance();
    final jsonData = json.encode(lastShowViewed.toString());
    prefs.setString('lastShowViewed', jsonData);
    print('lastShowViewed');
    print(lastShowViewed);
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

  //Code accessible from multiple points
  Future<bool> get connectivityCheck async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }

  snackbarMessageNoInternet(BuildContext context) {
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.signal_wifi_off, size: 36),
        ],
      ),
      // action: SnackBarAction(
      //     label: "OK",
      //     onPressed: () {
      //       Scaffold.of(context).hideCurrentSnackBar();
      //     }),
    ));
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<bool> localAudioFileCheck(String filename) async {
    try {
      final path = await _localPath;

      final file = File('$path/$filename');
      if (await file.exists()) {
        print('Found the file');

        return true;
      } else {
        print('The file seems to not be there');

        return false;
      }
    } catch (e) {
      print('had an error checking if the file was there or not');
      return false;
    }
  }

  // ignore: unused_element
  Future<bool> waitForTesting() async {
    print('waiting');
    await Future<String>.delayed(const Duration(seconds: 5));
    print('done waiting');
    return true;
  }
}
