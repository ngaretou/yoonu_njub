import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:provider/provider.dart';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import '../providers/messaging.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';

class Show {
  final String id;
  final String showNameRS;
  final String showNameAS;
  final String urlSnip;
  final String filename;
  final String image;
  const Show({
    required this.id,
    required this.showNameRS,
    required this.showNameAS,
    required this.urlSnip,
    required this.filename,
    required this.image,
  });
}

class Shows with ChangeNotifier {
  List<Show> _shows = [];

  List<Show> get shows {
    return [..._shows];
  }

  late int _lastShowViewed;

  int get lastShowViewed {
    return _lastShowViewed;
  }

  String get urlBase {
    return 'https://bienvenueafricains.com/mp3/wolof/the-way-of-righteousness';
  }

//reloadMainPage is necessary when the user clears downloads - it has the screen reload to check if it has a download on device or not
  bool _reloadMainPage = false;

  bool get reloadMainPage {
    return _reloadMainPage;
  }

//This is called from clear downloads in settings screen
  void setReloadMainPage(bool value) {
    _reloadMainPage = value;
    if (value == true) {
      notifyListeners();
    }
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
            filename: show['filename'],
            image: show['image']),
      );
    });

    _shows = loadedShowData;

    _lastShowViewed = await getLastShowViewed();

    // temp == null ? temp = 0 : _lastShowViewed = temp;

    return true;
  }

  Future<void> saveLastShowViewed(lastShowViewed) async {
    _lastShowViewed = lastShowViewed;
    final prefs = await SharedPreferences.getInstance();
    final jsonData = json.encode(lastShowViewed.toString());
    prefs.setString('lastShowViewed', jsonData);
  }

  Future<int> getLastShowViewed() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('lastShowViewed')) {
      return 0;
    } else {
      final storedValue = json.decode(prefs.getString('lastShowViewed')!);
      int _lastShowViewed = int.parse(storedValue);
      return _lastShowViewed;
    }
  }

  //Code accessible from multiple points
  Future<bool?> get connectivityCheck async {
    bool? connected;
    if (kIsWeb) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        connected = true;
      } else {
        connected = false;
      }
    } else {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          connected = true;
        }
      } on SocketException catch (_) {
        connected = false;
      }
    }

    return connected;
  }

  snackbarMessageNoInternet(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      // Scaffold.of(context).hideCurrentSnackBar();
      // Scaffold.of(context).showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.signal_wifi_off,
            size: 36,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    ));
  }

  snackbarMessageError(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      // Scaffold.of(context).hideCurrentSnackBar();
      // Scaffold.of(context).showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: 36,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
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
        // print('The file seems to not be there');

        return false;
      }
    } catch (e) {
      print('had an error checking if the file was there or not');
      return false;
    }
  }

/////////

  Future<List<String>> checkShows([Show? showToCheck]) async {
    //temp list of shows to work with
    List<Show> showsToCheck = [];
    //Did we recieve a certain show to check?
    //If not, check all shows.
    //If so, just check that one.
    showToCheck == null ? showsToCheck = shows : showsToCheck.add(showToCheck);

    //here set up the list which we'll return
    List<String> showsWithErrors = [];

    //shows.forEach doesn't await, it just runs, which messes everything up, stick with for
    for (var show in showsToCheck) {
      try {
        final url = urlBase + '/' + show.urlSnip + '/' + show.filename;
        final http.Response r = await http.head(Uri.parse(url));
        final _total = r.headers["content-length"]!;
        print(_total);
      } catch (e) {
        print('Error checking show ' + show.id.toString());
        showsWithErrors.add(show.id.toString());
      }
    }
    //Now we have the problem shows in the list showsWithErrors -
    //First, if there are errors, get an async process going
    //sending a message to the dev
    if (showsWithErrors.length != 0) {
      String messageText = "Errors in show(s) ";
      for (var showID in showsWithErrors) {
        messageText = messageText + " " + showID;
      }
      sendMessage(messageText);
    }

    return showsWithErrors;
  }

  Future<bool> checkAllShowsDialog(BuildContext context) async {
    // ignore: unused_element
    // Future<List<String>> checkShowTest() async {
    //   List<String> temp = [];
    //   final url = "http://audio.sng.al/CBB/CBB01.mp3";

    //   try {
    //     final http.Response r = await http.head(Uri.parse(url));
    //     final _total = r.headers["content-length"]!;
    //     // final _totalAsInt = double.parse(_total);

    //     print(_total);
    //     temp.add('worked');
    //   } catch (e) {
    //     print('Error checking url ' + url);
    //     temp.add('error');
    //   }
    //   return temp;
    // }

    Widget checkResultMessage(List<String> errorList) {
      late String message;
      //if no errors
      if (errorList.length == 0) {
        message = "No errors detected";
      } else {
        String errorListString = "Errors in shows: ";
        errorList.forEach((element) {
          errorListString = errorListString + " " + element;
        });
        message = errorListString;
        //Let dev know about the errors
        Provider.of<Shows>(context, listen: false).sendMessage(message);
      }

      return AlertDialog(
        title: Text(
          'Check Result',
        ),
        content: Text(
          message,
        ),
        actions: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
              TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context, false);
                  }),
            ],
          ),
        ],
        // ),
      );
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          //first get the size of the download so as to pass to the dialog
          return FutureBuilder(
              future: checkShows(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return checkResultMessage(snapshot.data as List<String>);
                }
              });
        }).then((responseFromDialog) async {
      //if response is true, download. If not, nothing happens.
      if (responseFromDialog) {
        print(responseFromDialog);
        //do something
      }
    });
    try {
      return true;
    } catch (e) {
      print('had an error checking if the file was there or not');
      return false;
    }
  }

  Future<void> sendMessage(String messageText) async {
    final smtpServer = hotmail(emailAddress, emailPassword);

    // Create our message.
    final message = Message()
      ..from = Address(emailAddress, 'Yoonu Njub Error Reporting')
      ..recipients.add(recipientAddress)
      ..subject = 'Yoonu Njub Error Report'
      ..text = messageText;

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
