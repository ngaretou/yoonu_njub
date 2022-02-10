import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

bool initialvalue = false;

class PlayerManager with ChangeNotifier {
  AudioPlayer player = AudioPlayer();
  ConcatenatingAudioSource playlist = ConcatenatingAudioSource(children: []);

  Future<void> initializeSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());

    // Listen to errors during playback.
    // player.playbackEventStream.listen((event) {
    //   // print(event);
    // }, onError: (Object e, StackTrace stackTrace) {
    //   print('A stream error occurred: $e');
    // });
  }

  String _showToPlay = "";

  String get showToPlay {
    return _showToPlay;
  }

  set showToPlay(String value) {
    this._showToPlay = value;
    notifyListeners();
  }

  //Manage the player
  // Future<void> gracefulStop() async {
  //   // Gradually turn down volume
  //   for (var i = 10; i >= 0; i--) {
  //     player.setVolume(i / 10);
  //     await Future.delayed(Duration(milliseconds: 10));
  //   }

  //   player.stop();
  // }

  Future<void> changePlaylist({AudioSource? source}) async {
    await player.stop();

    //If we got here by initializing the play button
    if (source != null) {
      playlist = ConcatenatingAudioSource(children: [source]);

      await player.setAudioSource(playlist, preload: true);

      //If we got here by page turn; no arguments (source == null)
    } else if (source == null) {
      if (!kIsWeb) {
        /*This bit of code loads an empty playlist, which dismisses the playback notification widget
        Not important for Android but crucial for iOS,
        otherwise you have a non-functional playback widget hanging around that does confusing things.
        This does mess up on the web version, so only do this if we're not on web*/
        playlist = ConcatenatingAudioSource(children: []); //working
        //This works to dismiss the notification widget with clear and then preload: true
        await player.setAudioSource(playlist, preload: true); //working
        player.stop();
      }
    }

    return;
  }
}
