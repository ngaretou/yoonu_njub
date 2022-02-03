import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
// import 'package:just_audio_background/just_audio_background.dart';

bool initialvalue = false;

class PlayerManager with ChangeNotifier {
  AudioPlayer player = AudioPlayer();
  ConcatenatingAudioSource playlist = ConcatenatingAudioSource(children: []);

  Future<void> initializeSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    // player.setAudioSource(playlist);

    // Listen to errors during playback.
    player.playbackEventStream.listen((event) {
      print('Current Index ${event.currentIndex}');
    }, onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
  }

  String _showToPlay = "";

  String get showToPlay {
    return _showToPlay;
  }

  set showToPlay(String value) {
    this._showToPlay = value;
    print('set showToPlay $value');
    notifyListeners();
  }

  //Manage the player
  //load the audio
  //play
  //pause
  //stop
  //gracefulStop
  Future<void> gracefulStop() async {
    // Gradually turn down volume
    for (var i = 10; i >= 0; i--) {
      player.setVolume(i / 10);
      await Future.delayed(Duration(milliseconds: 10));
    }
    // player.pause().then((_) => player.stop());
    player.stop();

    print('paused');
  }
  //dismissNotification
  //This bit of code loads an empty playlist, which dismisses the playback notification widget
  //Not important for Android but crucial for iOS, otherwise you have a non-functional playback widget hanging around that does confusing things.
// playlist.clear
  //changePlaylist

  Future<void> changePlaylist({AudioSource? source}) async {
    // if (player.playerState.playing) {
    //   await gracefulStop();
    //   // player.pause().then((_) => player.stop());

    // }
    player.stop();
    //If we got here by initializing the play button
    if (source != null) {
      print('set playlist');
      // await playlist.clear();
      playlist = ConcatenatingAudioSource(children: [source]);
      print('in between clear and add source');
      // await playlist.add(source);
      await player.setAudioSource(playlist, preload: true);
      //If we got here by page turn; no arguments (source == null)
    } else if (source == null) {
      print('clear playlist');
      // await playlist.clear();
      playlist = ConcatenatingAudioSource(children: []);
      //This works to dismiss the notification widget with clear and then preload: true
      //whole problem now is playing does not stop somehow
      await player.setAudioSource(playlist, preload: true);
      // player.stop();
    }
    // player.seek(Duration(minutes: 0));
    return;
  }
}
