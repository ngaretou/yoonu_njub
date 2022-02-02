import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import 'dart:typed_data';
import 'package:image/image.dart' as imageLib;

import '../providers/shows.dart';
import '../providers/player_manager.dart';
import 'download_button.dart';

class ControlButtons extends StatefulWidget {
  final Show show;
  final Function jumpPrevNext;

  ControlButtons({
    Key? key,
    required this.show,
    required this.jumpPrevNext,
  }) : super(key: key);

  @override
  ControlButtonsState createState() => ControlButtonsState();
}

class ControlButtonsState extends State<ControlButtons> {
  late bool _playerIsInitialized;

  @override
  void initState() {
    super.initState();
    _playerIsInitialized = false;
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final playerManager = Provider.of<PlayerManager>(context, listen: false);
    final player = playerManager.player;

//Pre player manager
    //only keep playing if it's the show we are looking at and it's actually playing
    //This is in the case the user has swiped rather than used the buttons
    // if (Provider.of<PlayerManager>(context, listen: true).showToPlay !=
    //         widget.show.id &&
    //     _player.playing) {
    //   print('sending signal to stop');
    //   gracefulStopInBuild();
    //   // _player.stop();
    // }

    final showsProvider = Provider.of<Shows>(context, listen: false);

    //This is to refresh the main view after downloads are clear
    if (Provider.of<Shows>(context, listen: true).reloadMainPage == true) {
      showsProvider.setReloadMainPage(false);
    }

    final urlBase = showsProvider.urlBase;

    Future<Uri> _getImageURI(String image) async {
      final Directory docsDirectory = await getApplicationDocumentsDirectory();
      String docsDirPathString = join(docsDirectory.path, "$image.jpg");

      //Set notification area playback widget image
      //Problem here is that you can't reference an asset image directly as a URI
      //But the notification area needs it as a URI so you have to
      //temporarily write the image outside the asset bundle. Yuck.

      //Get image from assets in ByteData
      ByteData imageByteData =
          await rootBundle.load("assets/images/$image.jpg");

      //Set up the write & write it to the file as bytes:
      // Get the ByteData into the format List<int>
      List<int> bytes = imageByteData.buffer.asUint8List(
          imageByteData.offsetInBytes, imageByteData.lengthInBytes);
      //Load the bytes as an image & resize the image
      imageLib.Image? imageSquared =
          imageLib.copyResizeCropSquare(imageLib.decodeImage(bytes)!, 400);

      //Write the bytes to disk for use
      // print('Write the bytes to disk for use');
      await File(docsDirPathString)
          .writeAsBytes(imageLib.encodeJpg(imageSquared));

      return Uri.file(docsDirPathString);
    }

    Future _loadRemoteAudio(Show show) async {
      //Get the image URI set up
      Uri? imageURI;
      //If web, the notification area code does not work, so
      kIsWeb ? imageURI = null : imageURI = await _getImageURI(show.image);
      print('setting audio source');
      //This is the audio source
      AudioSource source = AudioSource.uri(
        Uri.parse('$urlBase/${show.urlSnip}/${show.filename}'),
        //The notification area setup
        tag: MediaItem(
            // Specify a unique ID for each media item:
            id: show.id,

            // Metadata to display in the notification:
            album: "Yoonu Njub",
            title: show.showNameRS,
            artUri: imageURI),
      );

      //Set the player source
      try {
        print('setting player to play ${show.id}');
        // await player.setAudioSource(source);
        playerManager.changePlaylist(source: source);
        return;
      } catch (e) {
        print("Unable to stream remote audio. Error message: $e");
        //If we get past the connectivitycheck above but there's a problem wiht the source url; example the site is down,
        //we can get an error. If that happens, show the snackbar but also refresh the page using the below code
        //to get rid of the circular progress indicator (there is a listener for that value that will rebuild)
        showsProvider.snackbarMessageNoInternet(context);
        Provider.of<Shows>(context, listen: false).setReloadMainPage(true);
        return;
      }
    }

    Future _loadLocalAudio(Show show) async {
      print('loading local audio');
      //Get the image URI set up
      Uri? imageURI = await _getImageURI(show.image);

      //Audio source init
      final Directory docsDirectory = await getApplicationDocumentsDirectory();
      AudioSource source = ProgressiveAudioSource(
        Uri.file('${docsDirectory.path}/${show.filename}'),
        tag: MediaItem(
          // Specify a unique ID for each media item:
          id: show.id,

          // Metadata to display in the notification:
          album: "Yoonu Njub",
          title: show.showNameRS,
          artUri: imageURI,
        ),
      );
      try {
        // await player.setAudioSource(source);

        playerManager.changePlaylist(source: source);
      } catch (e) {
        // catch load errors: 404, invalid url ...
        print("Unable to load local audio. Error message: $e");
      }
    }

    Future _initializePlayer(String urlBase, Show show) async {
      //This checks to see if the player has already been initialized.
      //If it already has, we know where our audio is coming from and can just play (see button code below).
      //But if not, check to see if we're ready to rock.
      print('_playerIsInitialized $_playerIsInitialized');
      if (_playerIsInitialized) {
        // we've been here already; player is initialized, just return true to play
        return true;
      } else if (!_playerIsInitialized) {
        //This waits for all the prelim checks to be done then gets to the next part
        if (await showsProvider.localAudioFileCheck(show.filename)) {
          //source is local
          print('File is downloaded');
          await _loadLocalAudio(show);
          _playerIsInitialized = true;
          return true;
        } else {
          //file is not downloaded; source is remote:
          //check if connected:
          bool? connected = await showsProvider.connectivityCheck;

          //check if file exists; this does not work on web app because of CORS
          //https://stackoverflow.com/questions/65630743/how-to-solve-flutter-web-api-cors-error-only-with-dart-code,
          //so check if connected, but not if the file is there.
          //Hopefully Flutter web handling of CORS will be better in the future.
          late List<String> showExists;
          !kIsWeb
              //If not web, continue as normal
              ? showExists = await showsProvider.checkShows(show)
              //If web, return this dummy data that indicates no error
              : showExists = [];

          //Now if we're good start playing - if not then give a message
          if (connected! && showExists.length == 0) {
            //We're connected to internet and the show can be found
            await _loadRemoteAudio(show);
            print('returning true after loadRemoteAudio');
            _playerIsInitialized = true;
            return true;
          } else if (connected && showExists.length != 0) {
            print(connected);
            print(showExists.length);
            //We're connected to internet but the show can NOT be found
            //Note showExists returns the list of shows that have *errors* - a list length of 0 is good news
            _playerIsInitialized = false;
            showsProvider.snackbarMessageError(context);
            return false;
          } else {
            //Do this if file is not downloaded and we're not connected
            //The player is not initialized because there's nothing to play;
            //if you get here there's no local file and no internet connection.
            _playerIsInitialized = false;
            showsProvider.snackbarMessageNoInternet(context);
            return false;
          }
        }
      }
    }

    return Column(
      children: [
        //SeekBar
        StreamBuilder<Duration?>(
          stream: player.durationStream,
          builder: (context, snapshot) {
            final Duration duration = snapshot.data ?? Duration.zero;
            return StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, snapshot) {
                var position = snapshot.data ?? Duration.zero;
                if (position > duration) {
                  position = duration;
                }
                return SeekBar(
                  duration: duration,
                  position: position,
                  onChangeEnd: (newPosition) {
                    player.seek(newPosition);
                  },
                );
              },
            );
          },
        ),
        //This row is the control buttons.
        Row(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          children: [
            !kIsWeb
                ? Container(
                    width: 40,
                    child: DownloadButton(widget.show),
                  )
                : SizedBox(width: 40, height: 10),
            //Previous button
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: IconButton(
                  icon: Icon(Icons.skip_previous),
                  onPressed: () {
                    //communicating back up the widget tree here
                    widget.jumpPrevNext('back');
                  }),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: StreamBuilder<PlayerState>(
                stream: player.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;

                  if (playing != true) {
                    return IconButton(
                      icon: Icon(Icons.play_arrow),
                      iconSize: 64.0,
                      onPressed: () {
                        _initializePlayer(urlBase, widget.show)
                            .then((shouldPlay) {
                          // print(player);
                          print('shouldPlay $shouldPlay');
                          if (shouldPlay) {
                            player.setVolume(1);
                            player.play();
                          } else {
                            print('shouldPlay false');
                          }
                        });
                      },
                    );
                  } else if (processingState == ProcessingState.buffering ||
                      processingState == ProcessingState.loading) {
                    // if (processingState == ProcessingState.buffering) {
                    print('processingState is buffering or loading something');
                    return Container(
                      margin: EdgeInsets.all(08.0),
                      width: 64.0,
                      height: 64.0,
                      child: CircularProgressIndicator(),
                    );
                  } else if (processingState != ProcessingState.completed) {
                    return IconButton(
                      icon: Icon(Icons.pause),
                      iconSize: 64.0,
                      onPressed: player.pause,
                    );
                  } else {
                    return IconButton(
                      icon: Icon(Icons.replay),
                      iconSize: 64.0,
                      onPressed: () => player.seek(Duration.zero, index: 0),
                    );
                  }
                },
              ),
            ),
            //Next button
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: IconButton(
                  icon: Icon(Icons.skip_next),
                  onPressed: () async {
                    //communicating back up the widget tree here
                    widget.jumpPrevNext('next');
                  }),
            ),
            StreamBuilder<double>(
              stream: player.speedStream,
              builder: (context, snapshot) {
                late String? speed;
                if (snapshot.data != null) {
                  speed = snapshot.data?.toStringAsFixed(1);
                } else {
                  speed = '1.0';
                }

                return GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("${speed}x",
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(fontWeight: FontWeight.bold)),
                  ),
                  onTap: () {
                    _showSliderDialog(
                      context: context,
                      title: "Adjust speed",
                      divisions: 10,
                      min: 0.5,
                      max: 1.5,
                      stream: player.speedStream,
                      onChanged: player.setSpeed,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  SeekBar({
    required this.duration,
    required this.position,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Slider(
          min: 0.0,
          max: widget.duration.inMilliseconds.toDouble(),
          value: min(_dragValue ?? widget.position.inMilliseconds.toDouble(),
              widget.duration.inMilliseconds.toDouble()),
          onChanged: (value) {
            setState(() {
              _dragValue = value;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(Duration(milliseconds: value.round()));
            }
          },
          onChangeEnd: (value) {
            if (widget.onChangeEnd != null) {
              widget.onChangeEnd!(Duration(milliseconds: value.round()));
            }
            _dragValue = null;
          },
        ),
        Positioned(
          right: 16.0,
          bottom: 0.0,
          // child: Text('here'),
          child: widget.duration == Duration.zero
              //Before load, this will appear; you can choose Text(''), Text('-:--') etc
              ? Text('')
              //After the audio loads, there will be a duration, so show the time remaining
              : Text(
                  RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                          .firstMatch("$_remaining")
                          ?.group(1) ??
                      '$_remaining',
                  style: Theme.of(context).textTheme.subtitle2),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}

_showSliderDialog({
  required BuildContext context,
  String? title,
  int? divisions,
  double? min,
  double? max,
  String valueSuffix = '',
  Stream<double>? stream,
  ValueChanged<double>? onChanged,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title!, textAlign: TextAlign.center),
      content: StreamBuilder<double>(
        stream: stream,
        builder: (context, snapshot) => Container(
          height: 100.0,
          child: Column(
            children: [
              Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                  style: TextStyle(
                    fontFamily: 'Fixed',
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  )),
              Slider(
                divisions: divisions,
                min: min!,
                max: max!,
                value: snapshot.data ?? 1.0,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
