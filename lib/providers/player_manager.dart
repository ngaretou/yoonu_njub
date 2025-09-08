import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../main.dart';

class PlayerManager with ChangeNotifier {
  AudioPlayer player = AudioPlayer();

  saveLastShowViewed(int lastShowViewed) {
    prefsBox.put('lastShowViewed', lastShowViewed.toString());
  }

  Future<void> initializeSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());

    // Listen to errors during playback.
    // player.errorStream.listen((event) {
    //   debugPrint('A stream error occurred: ${event.toString}');
    // });
    debugPrint('initializeSession complete');
  }

  Future<void> loadPlaylist(
      List<AudioSource> playlist, int initialIndex) async {
    debugPrint('loadPlaylist');
    try {
      await player.setAudioSources(playlist,
          initialIndex: initialIndex, preload: true);
    } on PlayerException catch (e) {
      debugPrint("Error loading audio source: $e");
    }
    player.sequenceStateStream.listen((event) {
      if (player.sequenceState.currentSource != null) {
        var tag = player.sequenceState.currentSource!.tag as MediaItem;
        var id = tag.id;
        saveLastShowViewed(int.parse(id) -
            1); // to get the index - the id is the human readable show number here
      }
    });
  }

  // Future<void> play() async {
  //   await player.play();
  // }

  // Future<void> pause() async {
  //   await player.pause();
  // }

  // Future<void> stop() async {
  //   await player.stop();
  // }

  //Manage the player
  // Future<void> gracefulStop() async {
  //   // Gradually turn down volume
  //   for (var i = 10; i >= 0; i--) {
  //     player.setVolume(i / 10);
  //     await Future.delayed(Duration(milliseconds: 10));
  //   }

  //   player.stop();
  // }

  // Future<void> changePlaylist({AudioSource? source}) async {
  //   await player.stop();

  //   //If we got here by initializing the play button
  //   if (source != null) {
  //     await player.setAudioSources([source], preload: true);

  //     //If we got here by page turn; no arguments (source == null)
  //   } else if (source == null) {
  //     if (!kIsWeb) {
  //       /*This bit of code loads an empty playlist, which dismisses the playback notification widget
  //       Not important for Android but crucial for iOS,
  //       otherwise you have a non-functional playback widget hanging around that does confusing things.
  //       This does mess up on the web version, so only do this if we're not on web*/

  //       //This works to dismiss the notification widget with clear and then preload: true
  //       await player.setAudioSources([], preload: true); //working
  //       player.stop();
  //     }
  //   }

  //   return;
  // }
}
