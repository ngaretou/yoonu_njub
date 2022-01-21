import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:path_provider/path_provider.dart';
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

class ControlButtonsState extends State<ControlButtons>
    with WidgetsBindingObserver {
  final _player = AudioPlayer();
  late bool _playerIsInitialized;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _initializeSession();
    _playerIsInitialized = false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _player.dispose();
    super.dispose();
  }

  Future _initializeSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
  }

  @override
  Widget build(BuildContext context) {
    void gracefulStopInBuild() async {
      //Gradually turn down volume
      for (var i = 10; i >= 0; i--) {
        _player.setVolume(i / 10);
        await Future.delayed(Duration(milliseconds: 100));
      }
      _player.pause();
    }

    //only keep playing if it's the show we are looking at and it's actually playing
    if (Provider.of<PlayerManager>(context, listen: true).showToPlay !=
            widget.show.id &&
        _player.playing) {
      gracefulStopInBuild();
    }

    final showsProvider = Provider.of<Shows>(context, listen: false);

    //This is to refresh the main view after downloads are clear
    if (Provider.of<Shows>(context, listen: true).reloadMainPage == true) {
      showsProvider.setReloadMainPage(false);
    }

    final urlBase = showsProvider.urlBase;

    Future _loadRemoteAudio(url) async {
      print('streaming remote audio');
      AudioSource source = AudioSource.uri(Uri.parse(url));
      print(source);
      try {
        await _player.setAudioSource(source);
      } catch (e) {
        // catch load errors: 404, invalid url ...
        print("Unable to stream remote audio. Error message: $e");
        //If we get past the connectivitycheck above but there's a problem wiht the source url; example the site is down,
        //we can get an error. If that happens, show the snackbar but also refresh the page using the below code
        //to get rid of the circular progress indicator (there is a listener for that value that will rebuild)
        showsProvider.snackbarMessageNoInternet(context);
        Provider.of<Shows>(context, listen: false).setReloadMainPage(true);
        return;
      }
    }

    Future _loadLocalAudio(String filename) async {
      print('loading local audio');
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;

      var myUri = Uri.parse('$path/$filename');
      print(myUri);
      // AudioSource source = AudioSource.uri(myUri);
      AudioSource source = ProgressiveAudioSource(Uri.file('$path/$filename'));
      try {
        await _player.setAudioSource(source);
      } catch (e) {
        // catch load errors: 404, invalid url ...
        print("Unable to load local audio. Error message: $e");
      }
    }

    Future _initializePlayer(String urlBase, Show show) async {
      //This checks to see if the player has already been initialized.
      //If it already has, we know where our audio is coming from and can just play (see button code below).
      //But if not, check to see if we're ready to rock.

      if (_playerIsInitialized) {
        // we've been here already; player is initialized, just return true to play
        return true;
      } else if (!_playerIsInitialized) {
        _playerIsInitialized = true;

        //This waits for all the prelim checks to be done then gets to the next part
        if (await showsProvider.localAudioFileCheck(show.filename)) {
          //source is local
          print('File is downloaded');
          _loadLocalAudio(show.filename);
          return true;
        } else {
          //file is not downloaded; source is remote:
          //check if connected:
          bool? connected = await showsProvider.connectivityCheck;
          //check if file exists
          List<String> showExists = await showsProvider.checkShows(show);

          //Now if we're good start playing - if not then give a message
          if (connected! && showExists.length == 0) {
            //We're connected to internet and the show can be found
            _loadRemoteAudio('$urlBase/${show.urlSnip}/${show.filename}');
            return true;
          } else if (connected && showExists.length != 0) {
            //We're connected to internet but the show can NOT be found
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
          stream: _player.durationStream,
          builder: (context, snapshot) {
            print('in streambuilder for ' + widget.show.filename);

            final Duration duration = snapshot.data ?? Duration.zero;
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
                    widget.jumpPrevNext('back');
                  }),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;

                  if (processingState == ProcessingState.buffering ||
                      processingState == ProcessingState.loading) {
                    return Container(
                      margin: EdgeInsets.all(08.0),
                      width: 64.0,
                      height: 64.0,
                      child: CircularProgressIndicator(),
                    );
                  } else if (playing != true) {
                    return IconButton(
                      icon: Icon(Icons.play_arrow),
                      iconSize: 64.0,
                      onPressed: () {
                        _initializePlayer(urlBase, widget.show)
                            .then((shouldPlay) {
                          if (shouldPlay) {
                            _player.setVolume(1);
                            _player.play();
                          } else {
                            print('shouldPlay false');
                          }
                        });
                      },
                    );
                  } else if (processingState != ProcessingState.completed) {
                    return IconButton(
                      icon: Icon(Icons.pause),
                      iconSize: 64.0,
                      onPressed: _player.pause,
                    );
                  } else {
                    return IconButton(
                      icon: Icon(Icons.replay),
                      iconSize: 64.0,
                      onPressed: () => _player.seek(Duration.zero, index: 0),
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
                  onPressed: () {
                    widget.jumpPrevNext('next');
                  }),
            ),
            StreamBuilder<double>(
              stream: _player.speedStream,
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
                      stream: _player.speedStream,
                      onChanged: _player.setSpeed,
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
