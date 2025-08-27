import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as imageLib;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:yoonu_njub/l10n/app_localizations.dart'; // the new Flutter 3.x localization method

import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import '../providers/shows.dart';
import '../providers/player_manager.dart';
import 'show_display.dart';
import 'download_button.dart';
// import '../widgets/contact_options.dart';

enum ManualPlayerState { Uninitialized, Initializing, Initialized }

class ControlButtons extends StatefulWidget {
  final Show show;
  final Function jumpPrevNext; //parent method will be called from this child
  final Function showPlayList; //parent method will be called from this child
  final ChildController childController; //child method called via this
  final int wideVersionBreakPoint;

  const ControlButtons(
      {Key? key,
      required this.show,
      required this.jumpPrevNext,
      required this.showPlayList,
      required this.childController,
      required this.wideVersionBreakPoint})
      : super(key: key);

  @override
  ControlButtonsState createState() => ControlButtonsState(childController);
}

class ControlButtonsState extends State<ControlButtons> {
  ControlButtonsState(ChildController childController) {
    childController.childMethod = ffOrRew;
  }

  late ManualPlayerState manualPlayerStatus;

  late PlayerManager playerManager;
  late AudioPlayer player = playerManager.player;

  @override
  void initState() {
    super.initState();
    manualPlayerStatus = ManualPlayerState.Uninitialized;
  }

  void ffOrRew(String input) {
    print('called child method from parent $input');
    if (input == 'rew') {
      //check to make sure we're landing in the duration
      int newPosition = player.position.inSeconds - 10;

      if (newPosition > 0) {
        player.seek(Duration(seconds: player.position.inSeconds - 10));
      }
    } else if (input == 'ff') {
      //check to make sure we're landing in the duration

      if (player.duration != null) {
        int newPosition = player.position.inSeconds + 10;

        if (newPosition < player.duration!.inSeconds) {
          player.seek(Duration(seconds: player.position.inSeconds + 10));
        } else {
          //jump to next show
          widget.jumpPrevNext('next');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('player_controls build');

    playerManager = Provider.of<PlayerManager>(context, listen: false);
    player = playerManager.player;

    final mediaQuery = MediaQuery.of(context).size;
    //Smallest iPhone is UIKit 320 x 480 = 800.
    //Biggest (12 pro max) is 428 x 926 = 1354.
    //Android biggest phone I can find is is 480 x 853 = 1333
    //For tablets the smallest I can find is 768 x 1024
    final bool _isPhone = (mediaQuery.width + mediaQuery.height) <= 1400;

    final bool showPlaylist =
        _isPhone || mediaQuery.width < widget.wideVersionBreakPoint;

    final mainRowIconSize = 36.0;
    final showsProvider = Provider.of<Shows>(context, listen: false);

    //This is to refresh the main view after downloads are clear
    if (Provider.of<Shows>(context, listen: true).reloadMainPage == true) {
      showsProvider.setReloadMainPage(false);
    }

    final urlBase = showsProvider.urlBase;

    Future<Uri> _getImageURI(String image) async {
      /*Set notification area playback widget image:
      Problem here is that you can't reference an asset image directly as a URI
      But the notification area needs it as a URI so you have to
      temporarily write the image outside the asset bundle. Yuck.*/

      final Directory docsDirectory = await getApplicationDocumentsDirectory();
      String docsDirPathString = join(docsDirectory.path, "$image.jpg");

      //Get image from assets in ByteData
      ByteData imageByteData =
          await rootBundle.load("assets/images/$image.jpg");

      //Set up the write & write it to the file as bytes:
      // Get the ByteData into the format List<int>
      Uint8List bytes = imageByteData.buffer.asUint8List(
          imageByteData.offsetInBytes, imageByteData.lengthInBytes);

      //Load the bytes as an image & resize the image
      imageLib.Image? imageSquared = imageLib
          .copyResizeCropSquare(imageLib.decodeImage(bytes)!, size: 400);

      //Write the bytes to disk for use
      await File(docsDirPathString)
          .writeAsBytes(imageLib.encodeJpg(imageSquared));

      return Uri.file(docsDirPathString);
    }

    Future _loadRemoteAudio(Show show) async {
      //Get the image URI set up
      Uri? imageURI;
      //If web, the notification area code does not work, so
      kIsWeb ? imageURI = null : imageURI = await _getImageURI(show.image);

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
        await playerManager.changePlaylist(source: source);
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

      //Audio source initialization
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
        await playerManager.changePlaylist(source: source);
      } catch (e) {
        // catch load errors: 404, invalid url ...
        print("Unable to load local audio. Error message: $e");
      }
    }

    Future _initializePlayer(String urlBase, Show show) async {
      //This checks to see if the player has already been initialized.
      //If it already has, we know where our audio is coming from and can just play (see button code below).
      //But if not, check to see if we're ready to rock.
      if (manualPlayerStatus == ManualPlayerState.Initialized) {
        // we've been here already; player is initialized, just return true to play
        return true;
      } else if (manualPlayerStatus == ManualPlayerState.Uninitialized) {
        manualPlayerStatus = ManualPlayerState.Initializing;
        //This waits for all the prelim checks to be done then gets to the next part
        if (await showsProvider.localAudioFileCheck(show.filename)) {
          //source is local
          print('File is downloaded');
          await _loadLocalAudio(show);
          manualPlayerStatus = ManualPlayerState.Initialized;
          return true;
        } else {
          //file is not downloaded; source is remote:
          //check if connected:
          bool? connected = await showsProvider.connectivityCheck;

          //check if file exists; this does not work on web app because of CORS
          //https://stackoverflow.com/questions/65630743/how-to-solve-flutter-web-api-cors-error-only-with-dart-code,
          //so check if connected, but not if the file is reachable on the internet at this point.
          //Hopefully Flutter web handling of CORS will be better in the future or I will find another solution for a good check here.

          List<String> showExists = [];
          !kIsWeb
              //If not web, continue as normal
              ? showExists = await showsProvider.checkShows(show)
              //If web, return this dummy data that indicates no error
              : showExists = [];

          //Now if we're good start playing - if not then give a message
          if (connected! && showExists.length == 0) {
            //We're connected to internet and the show can be found
            await _loadRemoteAudio(show);
            manualPlayerStatus = ManualPlayerState.Initialized;
            return true;
          } else if (connected && showExists.length != 0) {
            //We're connected to internet but the show can NOT be found
            //Note showExists returns the list of shows that have *errors* - a list length of 0 is good news
            manualPlayerStatus = ManualPlayerState.Uninitialized;
            showsProvider.snackbarMessageError(context);
            return false;
          } else {
            //Do this if file is not downloaded and we're not connected
            //The player is not initialized because there's nothing to play;
            //if you get here there's no local file and no internet connection.
            manualPlayerStatus = ManualPlayerState.Uninitialized;
            showsProvider.snackbarMessageNoInternet(context);
            return false;
          }
        }
      }
    }

    Widget playButton() {
      return IconButton(
        icon: Icon(
          Icons.play_arrow_rounded,
        ),
        iconSize: 64.0,
        onPressed: () async {
          bool shouldPlay = await _initializePlayer(urlBase, widget.show);

          if (shouldPlay) {
            player.setVolume(1);
            player.play();
          }
        },
      );
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
                  playerIsInitialized:
                      manualPlayerStatus == ManualPlayerState.Uninitialized
                          ? false
                          : true,
                );
              },
            );
          },
        ),

        //This row is the control buttons.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //Previous button
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: IconButton(
                  icon: Icon(
                    Icons.skip_previous_rounded,
                    size: mainRowIconSize,
                  ),
                  onPressed: () {
                    //communicating back up the widget tree here
                    widget.jumpPrevNext('back');
                  }),
            ),

            //back 10 seconds button
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: IconButton(
                  icon: Icon(
                    Icons.replay_10,
                    size: mainRowIconSize,
                  ),
                  onPressed: () => ffOrRew('rew')),
            ),

            // Play button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: StreamBuilder<PlayerState>(
                stream: player.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;

                  /*original version of the if stmt here. With the player manager code 
                  in changePlaylist to dismiss the notification and building screens on 
                  either side of the main player, it gets a bit confused so doing a 
                  manual status for now. */
                  // if (processingState == ProcessingState.buffering ||
                  //     (processingState == ProcessingState.loading)) {

                  if (manualPlayerStatus == ManualPlayerState.Initializing) {
                    return Container(
                      margin: EdgeInsets.all(08.0),
                      width: 64.0,
                      height: 64.0,
                      child: CircularProgressIndicator(),
                    );
                  } else if (playing != true) {
                    return playButton();
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

            //forward 10 seconds button
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: IconButton(
                  icon: Icon(
                    Icons.forward_10,
                    size: mainRowIconSize,
                  ),
                  onPressed: () => ffOrRew('ff')),
            ),

            //Next button
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: IconButton(
                  icon: Icon(
                    Icons.skip_next_rounded,
                    size: mainRowIconSize,
                  ),
                  onPressed: () async {
                    //communicating back up the widget tree here
                    widget.jumpPrevNext('next');
                  }),
            ),
          ],
        ),
        //Second row of control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //download button
            !kIsWeb
                ? Container(
                    width: 40,
                    child: DownloadButton(widget.show),
                  )
                : SizedBox(width: 40, height: 10),

            showPlaylist
                ? GestureDetector(
                    child: Icon(Icons.playlist_play),
                    onTap: () => widget.showPlayList(),
                    onVerticalDragStart: (_) => widget.showPlayList())
                : SizedBox(width: 40, height: 10), //playback speed button

            //show playlist button
            // showPlaylist
            //     ? IconButton(
            // onPressed: () => widget.showPlayList(),
            //         icon: Icon(Icons.playlist_play),
            //       )
            //     : SizedBox(width: 40, height: 10), //playback speed button

            StreamBuilder<double>(
              stream: player.speedStream,
              builder: (context, snapshot) {
                late String? speed;
                if (snapshot.data != null) {
                  speed = snapshot.data?.toStringAsFixed(1);
                } else {
                  speed = '1.0';
                }

                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("${speed}x",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(fontWeight: FontWeight.bold)),
                    ),
                    onTap: () {
                      _showSliderDialog(
                        context: context,
                        title: AppLocalizations.of(context)!.adjustSpeed,
                        divisions: 10,
                        min: 0.5,
                        max: 1.5,
                        stream: player.speedStream,
                        onChanged: player.setSpeed,
                      );
                    },
                  ),
                );
              },
            ),
            // IconButton(
            //   icon: Icon(Icons.help_outline),
            //   onPressed: () {
            //     //open the contact us possibilities
            //     showDialog(
            //       context: context,
            //       builder: (BuildContext context) {
            //         return SimpleDialog(
            //           title: Text(
            //             AppLocalizations.of(context)!.settingsContactUs,
            //           ),
            //           children: [ContactOptions()],
            //         );
            //       },
            //     );
            //   },
            // ),
          ],
        )
      ],
    );
  }
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;
  final bool playerIsInitialized;

  SeekBar(
      {required this.duration,
      required this.position,
      this.onChanged,
      this.onChangeEnd,
      required this.playerIsInitialized});

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
          // If the player is not yet initialized....
          child: !widget.playerIsInitialized
              //Before load, this will appear; you can choose Text(''), Text('-:--') etc
              ? Text('')
              //After the audio loads, there will be a duration, so show the time remaining
              : Text(
                  RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                          .firstMatch("$_remaining")
                          ?.group(1) ??
                      '$_remaining',
                  style: Theme.of(context).textTheme.titleSmall),
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
