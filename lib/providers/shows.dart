import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import 'package:image/image.dart' as image_lib;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:just_audio/just_audio.dart';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:yoonu_njub/providers/player_manager.dart';

import '../providers/messaging.dart';

import 'dart:async';
import 'dart:convert';

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

  Future<void> getData(BuildContext context) async {
    debugPrint('start getData');

    //check if the current session still contains the shows - if so no need to rebuild
    if (_shows.isNotEmpty) {
      return;
    }

    //temporary simple list for holding data
    final List<Show> loadedShowData = [];
    List<AudioSource> playlist = [];

    //Get the data from json file
    String showsJSON = await rootBundle.loadString("assets/shows.json");
    final showsData = json.decode(showsJSON) as List<dynamic>;

    //So we have the info but it's in the wrong format - here map it to our class
    for (var show in showsData) {
      // add it to the show info
      loadedShowData.add(
        Show(
            id: show['id'],
            showNameRS: show['showNameRS'],
            showNameAS: show['showNameAS'],
            urlSnip: show['urlSnip'],
            filename: show['filename'],
            image: show['image']),
      );

      // and add it to the playlist

      //Get the image URI set up
      Uri? imageURI;
      //If web, the notification area code does not work, so
      kIsWeb ? imageURI = null : imageURI = await _getImageURI(show['image']);

      //  check to see if it's downloaded
      bool downloaded = await localAudioFileCheck(show['filename']);
      if (downloaded) {
        final Directory docsDirectory =
            await getApplicationDocumentsDirectory();
        final uri = '${docsDirectory.path}/${show['filename']}';
        AudioSource source = AudioSource.file(
          uri,
          tag: MediaItem(
            // Specify a unique ID for each media item:
            id: show['id'],
            // Metadata to display in the notification:
            album: "Yoonu Njub",
            title: show['showNameRS'],
            artUri: imageURI,
          ),
        );

        playlist.add(source);
      } else {
        //This is the audio source
        final uri = '$urlBase/${show['urlSnip']}/${show['filename']}';
        AudioSource source = AudioSource.uri(
          Uri.parse(uri),
          //The notification area setup
          tag: MediaItem(
              // Specify a unique ID for each media item:
              id: show['id'],
              // Metadata to display in the notification:
              album: "Yoonu Njub",
              title: show['showNameRS'],
              artUri: imageURI),
        );

        playlist.add(source);
      }
    }

    _shows = loadedShowData;

    _lastShowViewed = await getLastShowViewed();

    // await PlayerManager().loadPlaylist(_playlist, _lastShowViewed);
    if (!context.mounted) return;
    await Provider.of<PlayerManager>(context, listen: false)
        .initializeSession();
    if (!context.mounted) return;
    await Provider.of<PlayerManager>(context, listen: false)
        .loadPlaylist(playlist, _lastShowViewed);

    debugPrint('end getData');
    return;
  }

  Future<Uri> _getImageURI(String image) async {
    /*Set notification area playback widget image:
      Problem here is that you can't reference an asset image directly as a URI
      But the notification area needs it as a URI so you have to
      temporarily write the image outside the asset bundle. Yuck.*/

    final Directory docsDirectory = await getApplicationDocumentsDirectory();
    String docsDirPathString = join(docsDirectory.path, "$image.jpg");

    bool exists = await File(docsDirPathString).exists();

    if (!exists) {
      //Get image from assets in ByteData
      ByteData imageByteData =
          await rootBundle.load("assets/images/$image.jpg");

      //Set up the write & write it to the file as bytes:
      // Get the ByteData into the format List<int>
      Uint8List bytes = imageByteData.buffer.asUint8List(
          imageByteData.offsetInBytes, imageByteData.lengthInBytes);

      //Load the bytes as an image & resize the image
      image_lib.Image? imageSquared = image_lib
          .copyResizeCropSquare(image_lib.decodeImage(bytes)!, size: 400);

      //Write the bytes to disk for use
      await File(docsDirPathString)
          .writeAsBytes(image_lib.encodeJpg(imageSquared));
    }

    return Uri.file(docsDirPathString);
  }

  Future<int> getLastShowViewed() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('lastShowViewed')) {
      return 0;
    } else {
      final storedValue = json.decode(prefs.getString('lastShowViewed')!);
      int lastShowViewed = int.parse(storedValue);
      return lastShowViewed;
    }
  }

  Future<bool?> get connectivityCheck async {
    bool? connected;
    if (kIsWeb) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
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
      debugPrint(filename);
      final file = File('$path/$filename');
      if (await file.exists()) {
        debugPrint('Found the file');

        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('had an error checking if the file was there or not');
      return false;
    }
  }

////////////////////////
//Begin show verification

  Future<List<String>> checkShows([Show? showToCheck]) async {
    debugPrint('checkShows');

    //temp list of shows to work with
    List<Show> showsToCheck = [];

    //Did we recieve a certain show to check?
    //If not, check all shows.
    //If so, just check that one.
    showToCheck == null ? showsToCheck = shows : showsToCheck.add(showToCheck);

    //here set up the list which we'll return
    List<String> showsWithErrors = [];

    //Note shows.forEach doesn't await, it just runs, which messes everything up, stick with 'for'
    for (var show in showsToCheck) {
      try {
        final url = '$urlBase/${show.urlSnip}/${show.filename}';
        debugPrint(url);
        http.Response r = await http.head(Uri.parse(url));
        final total = r.headers["content-length"];
        debugPrint("show ${show.id} total size: $total");
      } catch (e) {
        debugPrint('Error checking show ${show.id}');
        debugPrint(e.toString());
        showsWithErrors.add(show.id.toString());
      }
    }
    //Now we have the problem shows in the list showsWithErrors -
    //First, if there are errors, get an async process going
    //sending a message to the dev
    if (showsWithErrors.isNotEmpty) {
      String messageText = "Errors in show(s) ";
      for (var showID in showsWithErrors) {
        messageText = "$messageText $showID";
      }
      sendMessage(messageText);
    }
    //return the list of shows that have errors - a list length of 0 is good news
    return showsWithErrors;
  }

  Future checkAllShowsDialog(BuildContext context) async {
    // ignore: unused_element
    // Future<List<String>> checkShowTest() async {
    //   List<String> temp = [];
    //   final url = "http://audio.sng.al/CBB/CBB01.mp3";

    //   try {
    //     final http.Response r = await http.head(Uri.parse(url));
    //     final _total = r.headers["content-length"]!;
    //     // final _totalAsInt = double.parse(_total);

    //     debugPrint(_total);
    //     temp.add('worked');
    //   } catch (e) {
    //     debugPrint('Error checking url ' + url);
    //     temp.add('error');
    //   }
    //   return temp;
    // }

    // Starting with the end - this is the result AlertDialog that gets called after the check completes.
    Widget checkResultMessage(List<String> errorList) {
      late String message;
      //if no errors
      if (errorList.isEmpty) {
        message = "No errors detected";
        //This if uncommented sends a no errors detected email
        // sendMessage(message);
      } else {
        String errorListString = "Errors in shows: ";
        for (var element in errorList) {
          errorListString = "$errorListString $element";
        }
        message = errorListString;
        //Let dev know about the errors
        sendMessage(message);
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

    startChecking() {
      //The function that actually kicks this off - call CheckShows and then give us the
      //result with checkResultMessage
      showDialog(
          context: context,
          builder: (BuildContext context) {
            //first get the size of the download so as to pass to the dialog
            return FutureBuilder(
                // future: checkShows(),
                future: checkShows(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    //AbsorbPointer makes the screen nonresponsive til the future completes
                    return AbsorbPointer(
                        absorbing: true,
                        // child: Center(child: CircularProgressIndicator()));
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                flex: 0, child: CircularProgressIndicator()),
                            // Container(
                            //   height: 50,
                            // ),
                            // Expanded(
                            //   flex: 0,
                            //   child: Text(
                            //     "Checking episodes on the web... ",
                            //     style: Theme.of(context).textTheme.titleLarge,
                            //   ),
                            // ),
                          ],
                        ));
                  } else {
                    return checkResultMessage(snapshot.data as List<String>);
                  }
                });
          });
    }

    //This is the first thing actually run here, confirms the user wants to check
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //first get the size of the download so as to pass to the dialog

          return AlertDialog(
            title: Text(
              'Check Result',
            ),
            content: Text(
              'Check availability of shows on internet?',
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
                      startChecking();
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
          );
        });
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
      debugPrint('Message sent: $sendReport');
    } on MailerException catch (e) {
      debugPrint('Message not sent.');
      for (var p in e.problems) {
        debugPrint('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  //End show verification
}
