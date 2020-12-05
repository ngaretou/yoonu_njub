import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/shows.dart';
import 'download_button.dart';

class ControlButtons extends StatefulWidget {
  final Show show;
  final Function jumpPrevNext;
  ControlButtons(this.show, this.jumpPrevNext);

  @override
  _ControlButtonsState createState() => _ControlButtonsState();
}

class _ControlButtonsState extends State<ControlButtons> {
  AudioPlayer _player;
  bool _playerIsInitialized;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initializeSession();
    _playerIsInitialized = false;
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future _initializeSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<Shows>(context, listen: true).reloadMainPage == true) {
      // setState(() {});
      Provider.of<Shows>(context, listen: false).setReloadMainPage(false);
    }
    final shows = Provider.of<Shows>(context, listen: false);
    final urlBase = shows.urlBase;

    Future _loadRemoteAudio(url) async {
      print('streaming remote audio');
      AudioSource source = AudioSource.uri(Uri.parse(url));
      try {
        await _player.load(source);
        // await _player.setUrl(url);
      } catch (e) {
        // catch load errors: 404, invalid url ...
        print("An error occured $e");
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
        await _player.load(source);
        // await _player.setAsset('$path/$filename');
      } catch (e) {
        // catch load errors: 404, invalid url ...
        print("An error occured $e");
      }
    }

    Future _initializePlayer(
        String urlBase, String urlSnip, String filename) async {
      //This checks to see if the player has already been initialized.
      //If it already has, we know where our audio is coming from and can just play (see button code below).
      //But if not, check to see if we're ready to rock.

      if (_playerIsInitialized) {
        // we've been here already; player is initialized, just return true to play
        return true;
      } else if (!_playerIsInitialized) {
        _playerIsInitialized = true;

        //This waits for all the prelim checks to be done then gets to the next part
        if (await shows.localAudioFileCheck(filename)) {
          //source is local
          print('File is downloaded');
          _loadLocalAudio(filename);
          return true;
        } else {
          //file is not downloaded; source is remote:
          //check if connected:
          if (await shows.connectivityCheck) {
            //if so, load the file:
            _loadRemoteAudio('$urlBase/$urlSnip/$filename');
            return true;
          } else {
            //Do this if file is not downloaded but we're not connected
            //The player is not initialized because there's nothing to play;
            //if you get here there's no local file and no internet connection.
            _playerIsInitialized = false;
            shows.snackbarMessageNoInternet(context);
            return false;
          }
        }
      }
    }

    return Column(
      children: [
        //SeekBar
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
        //This row is the control buttons. Some of the original code's controls (from just_audio plugin example) this app does not use so have just commented out rather than deleting.
        Row(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            !kIsWeb
                ? Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: DownloadButton(widget.show),
                  )
                : SizedBox(width: 40, height: 10),
            //Previous button
            IconButton(
                icon: Icon(Icons.skip_previous),
                onPressed: () {
                  widget.jumpPrevNext('back');
                }),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        _initializePlayer(urlBase, widget.show.urlSnip,
                                widget.show.filename)
                            .then((shouldPlay) {
                          if (shouldPlay) {
                            _player.play();
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
            IconButton(
                icon: Icon(Icons.skip_next),
                onPressed: () {
                  widget.jumpPrevNext('next');
                }),
            StreamBuilder<double>(
              stream: _player.speedStream,
              builder: (context, snapshot) => GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("${snapshot.data?.toStringAsFixed(1)}x",
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2
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
              ),
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
  final ValueChanged<Duration> onChanged;
  final ValueChanged<Duration> onChangeEnd;

  SeekBar({
    @required this.duration,
    @required this.position,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double _dragValue;

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
              widget.onChanged(Duration(milliseconds: value.round()));
            }
          },
          onChangeEnd: (value) {
            if (widget.onChangeEnd != null) {
              widget.onChangeEnd(Duration(milliseconds: value.round()));
            }
            _dragValue = null;
          },
        ),
        Positioned(
          right: 16.0,
          bottom: 0.0,
          child: Text(
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
  BuildContext context,
  String title,
  int divisions,
  double min,
  double max,
  String valueSuffix = '',
  Stream<double> stream,
  ValueChanged<double> onChanged,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
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
                min: min,
                max: max,
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
