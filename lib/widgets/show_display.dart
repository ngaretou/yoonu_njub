import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity/connectivity.dart';

import 'dart:ui' as ui;
import '../providers/shows.dart';
import '../widgets/player_controls.dart';

class ShowDisplay extends StatefulWidget {
  @override
  _ShowDisplayState createState() => _ShowDisplayState();
}

class _ShowDisplayState extends State<ShowDisplay> {
  AudioPlayer _player;
  // bool _isPlaying = false;
  // bool _isDownloading = false;
  bool _fileIsDownloaded;
  bool _connected;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<bool> _localAudioFileCheck(String filename) async {
    try {
      final path = await _localPath;

      final file = File('$path/$filename');
      if (await file.exists()) {
        print('Found the file');
        _fileIsDownloaded = true;
        return true;
      } else {
        print('The file seems to not be there');
        _fileIsDownloaded = false;
        return false;
      }
    } catch (e) {
      print('had an error checking if the file was there or not');
      return false;
    }
  }

  Future<bool> _connectivityCheck() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      _connected = true;
      return true;
    } else {
      _connected = false;
      return false;
    }
  }

  // ignore: unused_element
  Future<bool> _waitForTesting() async {
    print('waiting');
    await Future<String>.delayed(const Duration(seconds: 5));
    print('done waiting');
    return true;
  }

  // Future<File> writeContent() async {
  //   final file = await _localFile;
  //   // Write the file
  //   return file.writeAsString('Hello Folk');
  // }

  _initializePlayer(String urlBase, String urlSnip, String filename) async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());

    //Loading the page with the player.
    //This waits for all the prelim checks to be done then gets to the next part
    Future.wait(
      [
        //Does the file we are looking for exist in Document folder?
        _localAudioFileCheck(filename),
        _connectivityCheck(),
        // _waitForTesting(),
      ],
    ).then((_) {
      print('done with Future.wait');
      //Now that we know if the file is downloaded already or not we can set the audio source
      if (_fileIsDownloaded) {
        //source is local
        print('_fileIsDownloaded');
      } else {
        //source is remote
        if (_connected) {
          _loadRemoteAudio('$urlBase/$urlSnip/$filename');
        }
      }
    }, onError: (error) {
      print(error);
    });

    //If so play it from the Documents folder.

    //Is it downloading already? Give some feedback.

    //If it does not, then we'll get set to stream from the web.
    //Do we have internet connection?
    //If yes, proceed, if no give a message.
    // _initializePlayer();

    // try {
    //   await _player.load(audioToLoad);
    // } catch (e) {
    //   // catch load errors: 404, invalid url ...
    //   print("An error occured $e");
    // }
  }

  _loadRemoteAudio(url) async {
    print('in _loadRemoteAudio');
    print(url);
    var source = AudioSource.uri(Uri.parse(url));
    try {
      await _player.load(source);
    } catch (e) {
      // catch load errors: 404, invalid url ...
      print("An error occured $e");
    }
  }

  // _loadLocalAudio(String urlSnip, String filename) async {
  //   try {
  //     await _player.load(
  //       AudioSource.(Uri.parse(url)),
  //     );
  //   } catch (e) {
  //     // catch load errors: 404, invalid url ...
  //     print("An error occured $e");
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Text Styles
    ui.TextDirection _rtlText = ui.TextDirection.rtl;
    ui.TextDirection _ltrText = ui.TextDirection.ltr;

    TextStyle _asStyle = TextStyle(
        // height: 1.3,
        color: Theme.of(context).textTheme.headline6.color,
        fontFamily: "Harmattan",
        fontSize: 40);

    TextStyle _rsStyle = TextStyle(
        // height: 1.3,
        color: Theme.of(context).textTheme.headline6.color,
        fontFamily: "Lato",
        fontSize: 30);

    //Data and preliminaries
    final shows = Provider.of<Shows>(context, listen: false);
    final urlBase = shows.urlBase;

    final PageController _pageController = PageController(
      // initialPage: shows.lastShowViewed,
      viewportFraction: 1,
      keepPage: true,
    );

    return PageView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        controller: _pageController,
        onPageChanged: (index) {
          //Here we want the user to be able to come back to the name they were on even if they
          //switch temporarily to favorites - so save lastpage viewed only when not viewing favs
          shows.saveLastShowViewed(index);
        },
        itemCount: shows.shows.length,
        itemBuilder: (context, i) {
          return Column(
            children: [
              Image.asset(
                'assets/images/${shows.shows[i].id}.jpg',
                fit: BoxFit.fitWidth,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Column(
                  children: [
                    Text(shows.shows[i].id,
                        textAlign: TextAlign.center,
                        style: _rsStyle.copyWith(fontSize: 12),
                        textDirection: _ltrText),
                    Text(shows.shows[i].showNameAS,
                        textAlign: TextAlign.center,
                        style: _asStyle,
                        textDirection: _rtlText),
                    Text(shows.shows[i].showNameRS,
                        textAlign: TextAlign.center,
                        style: _rsStyle,
                        textDirection: _ltrText),
                    Container(
                        child: FutureBuilder(
                      future: _initializePlayer(urlBase, shows.shows[i].urlSnip,
                          shows.shows[i].filename),
                      builder: (ctx, snapshot) =>
                          snapshot.connectionState == ConnectionState.waiting
                              ? Center(child: CircularProgressIndicator())
                              : ControlButtons(_player),
                    )),
                    StreamBuilder<Duration>(
                      stream: _player.durationStream,
                      builder: (context, snapshot) {
                        final duration = snapshot.data ?? Duration.zero;
                        return StreamBuilder<Duration>(
                          stream: _player.positionStream,
                          builder: (context, snapshot) {
                            var position = snapshot.data ?? Duration.zero;
                            if (position > duration) {
                              position = duration;
                            }
                            return SeekBar(
                              duration: duration,
                              position: position,
                              onChangeEnd: (newPosition) {
                                _player.seek(newPosition);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}
