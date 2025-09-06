import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:rxdart/rxdart.dart';
import 'package:yoonu_njub/l10n/app_localizations.dart'; // the new Flutter 3.x localization method

import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';

import '../providers/shows.dart';
import '../providers/player_manager.dart';
import 'download_button.dart';
// import '../widgets/contact_options.dart';

enum ManualPlayerState { Uninitialized, Initializing, Initialized }

class ControlButtons extends StatefulWidget {
  final Function showPlayList; //parent method will be called from this child
  final int wideVersionBreakPoint;

  const ControlButtons(
      {Key? key,
      required this.showPlayList,
      required this.wideVersionBreakPoint})
      : super(key: key);

  @override
  ControlButtonsState createState() => ControlButtonsState();
}

class ControlButtonsState extends State<ControlButtons> {
  late PlayerManager playerManager;
  late AudioPlayer player;
  // void ffOrRew(String input) {
  //   debugPrint('called child method from parent $input');
  //   if (input == 'rew') {
  //     //check to make sure we're landing in the duration
  //     int newPosition = player.position.inSeconds - 10;

  //     if (newPosition > 0) {
  //       player.seek(Duration(seconds: player.position.inSeconds - 10));
  //     }
  //   } else if (input == 'ff') {
  //     //check to make sure we're landing in the duration

  //     if (player.duration != null) {
  //       int newPosition = player.position.inSeconds + 10;

  //       if (newPosition < player.duration!.inSeconds) {
  //         player.seek(Duration(seconds: player.position.inSeconds + 10));
  //       } else {
  //         //jump to next show
  //         widget.jumpPrevNext('next');
  //       }
  //     }
  //   }
  // }

  @override
  void initState() {
    playerManager = Provider.of<PlayerManager>(context, listen: false);
    player = playerManager.player;
    super.initState();
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest2<Duration, Duration?, PositionData>(
          playerManager.player.positionStream,
          playerManager.player.durationStream, (position, reportedDuration) {
        final duration = reportedDuration ?? Duration.zero;
        return PositionData(position, duration);
      });

  @override
  Widget build(BuildContext context) {
    debugPrint('player_controls build');

    /// Collects the data useful for displaying in a seek bar, using a handy
    /// feature of rx_dart to combine the 3 streams of interest into one.

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
    // if (Provider.of<Shows>(context, listen: true).reloadMainPage == true) {
    //   showsProvider.setReloadMainPage(false);
    // }

    // Future _initializePlayer(String urlBase, Show show) async {
    //   //This checks to see if the player has already been initialized.
    //   //If it already has, we know where our audio is coming from and can just play (see button code below).
    //   //But if not, check to see if we're ready to rock.
    //   if (manualPlayerStatus == ManualPlayerState.Initialized) {
    //     // we've been here already; player is initialized, just return true to play
    //     return true;
    //   } else if (manualPlayerStatus == ManualPlayerState.Uninitialized) {
    //     manualPlayerStatus = ManualPlayerState.Initializing;
    //     //This waits for all the prelim checks to be done then gets to the next part
    //     if (await showsProvider.localAudioFileCheck(show.filename)) {
    //       //source is local
    //       debugPrint('File is downloaded');

    //       // await _loadLocalAudio(show);
    //       manualPlayerStatus = ManualPlayerState.Initialized;
    //       return true;
    //     } else {
    //       //file is not downloaded; source is remote:
    //       //check if connected:
    //       bool? connected = await showsProvider.connectivityCheck;

    //       //check if file exists; this does not work on web app because of CORS
    //       //https://stackoverflow.com/questions/65630743/how-to-solve-flutter-web-api-cors-error-only-with-dart-code,
    //       //so check if connected, but not if the file is reachable on the internet at this point.
    //       //Hopefully Flutter web handling of CORS will be better in the future or I will find another solution for a good check here.

    //       List<String> showExists = [];
    //       !kIsWeb
    //           //If not web, continue as normal
    //           ? showExists = await showsProvider.checkShows(show)
    //           //If web, return this dummy data that indicates no error
    //           : showExists = [];

    //       //Now if we're good start playing - if not then give a message
    //       if (connected! && showExists.length == 0) {
    //         //We're connected to internet and the show can be found

    //         // await _loadRemoteAudio(show);
    //         manualPlayerStatus = ManualPlayerState.Initialized;
    //         return true;
    //       } else if (connected && showExists.length != 0) {
    //         //We're connected to internet but the show can NOT be found
    //         //Note showExists returns the list of shows that have *errors* - a list length of 0 is good news
    //         manualPlayerStatus = ManualPlayerState.Uninitialized;
    //         showsProvider.snackbarMessageError(context);
    //         return false;
    //       } else {
    //         //Do this if file is not downloaded and we're not connected
    //         //The player is not initialized because there's nothing to play;
    //         //if you get here there's no local file and no internet connection.
    //         manualPlayerStatus = ManualPlayerState.Uninitialized;
    //         showsProvider.snackbarMessageNoInternet(context);
    //         return false;
    //       }
    //     }
    //   }
    // }

    // Widget playButton() {
    //   return IconButton(
    //     icon: Icon(
    //       Icons.play_arrow_rounded,
    //     ),
    //     iconSize: 64.0,
    //     onPressed: () async {
    //       bool shouldPlay = await _initializePlayer(urlBase, widget.show);

    //       if (shouldPlay) {
    //         player.setVolume(1);
    //         player.play();
    //       }
    //     },
    //   );
    // }

    return Column(
      children: [
        //SeekBar
        StreamBuilder<PositionData>(
          stream: _positionDataStream,
          builder: (context, snapshot) {
            final positionData = snapshot.data;
            return SeekBar(
              duration: positionData?.duration ?? Duration.zero,
              position: positionData?.position ?? Duration.zero,
              onChangeEnd: (newPosition) {
                player.seek(newPosition);
              },
            );
          },
        ),
        // StreamBuilder<Duration?>(
        //   stream: player.durationStream,
        //   builder: (context, snapshot) {
        //     final Duration duration = snapshot.data ?? Duration.zero;

        //     return StreamBuilder<Duration>(
        //       stream: player.positionStream,
        //       builder: (context, snapshot) {
        //         var position = snapshot.data ?? Duration.zero;
        //         if (position > duration) {
        //           position = duration;
        //         }
        //         return SeekBar(
        //           duration: duration,
        //           position: position,
        //           onChangeEnd: (newPosition) {
        //             player.seek(newPosition);
        //           },
        //         );
        //       },
        //     );
        //   },
        // ),

        //This row is the control buttons.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //Previous button
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: StreamBuilder<SequenceState?>(
                stream: player.sequenceStateStream,
                builder: (context, snapshot) => IconButton(
                  icon: Icon(
                    Icons.skip_previous_rounded,
                    size: mainRowIconSize,
                  ),
                  onPressed: player.hasPrevious ? player.seekToPrevious : null,
                ),
              ),
            ),

            //back 10 seconds button
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: StreamBuilder<PositionData>(
                stream: _positionDataStream,
                builder: (context, snapshot) {
                  final positionData = snapshot.data;
                  final position = positionData?.position ?? Duration.zero;
                  return IconButton(
                      icon: Icon(
                        Icons.replay_10,
                        size: mainRowIconSize,
                      ),
                      onPressed: position > Duration(seconds: 11)
                          ? () => player.seek(position - Duration(seconds: 10))
                          : null);
                },
              ),
            ),

            // Play button
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child:

                    /// This StreamBuilder rebuilds whenever the player state changes, which
                    /// includes the playing/paused state and also the
                    /// loading/buffering/ready state. Depending on the state we show the
                    /// appropriate button or loading indicator.
                    StreamBuilder<PlayerState>(
                  stream: player.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final processingState = playerState?.processingState;
                    final playing = playerState?.playing;
                    if (processingState == ProcessingState.loading ||
                        processingState == ProcessingState.buffering) {
                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        width: 64.0,
                        height: 64.0,
                        child: const CircularProgressIndicator(),
                      );
                    } else if (playing != true) {
                      return IconButton(
                        icon: const Icon(Icons.play_arrow),
                        iconSize: 64.0,
                        onPressed: player.play,
                      );
                    } else if (processingState != ProcessingState.completed) {
                      return IconButton(
                        icon: const Icon(Icons.pause),
                        iconSize: 64.0,
                        onPressed: player.pause,
                      );
                    } else {
                      return IconButton(
                        icon: const Icon(Icons.replay),
                        iconSize: 64.0,
                        onPressed: () => player.seek(Duration.zero),
                      );
                    }
                  },
                )),

            //forward 10 seconds button
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: IconButton(
                  icon: Icon(
                    Icons.forward_10,
                    size: mainRowIconSize,
                  ),
                  onPressed: () {
                    // TODO
                    // final duration = positionData
                    // ffOrRew('ff');
                  }),
            ),

            //Next button
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: IconButton(
                  icon: Icon(
                    Icons.skip_next_rounded,
                    size: mainRowIconSize,
                  ),
                  onPressed: player.seekToNext),
            ),
          ],
        ),
        //Second row of control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //download button
            !kIsWeb
                ? StreamBuilder(
                    stream: player.sequenceStateStream,
                    builder: (context, snapshot) {
                      final state = snapshot.data;
                      if (state?.sequence.isEmpty ?? true) {
                        return const SizedBox();
                      }
                      final metadata = state!.currentSource!.tag as MediaItem;

                      int id = int.parse(metadata.id);

                      return Container(
                        width: 60,
                        child: DownloadButton(showsProvider.shows[id]),
                      );
                    })
                : SizedBox(width: 40, height: 10),
            Expanded(
              child: SizedBox(width: 40, height: 10),
            ),
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 24),
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
          // If the player is not yet initialized....
          child: Text(
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

class PositionData {
  final Duration position;

  final Duration duration;

  PositionData(this.position, this.duration);
}
