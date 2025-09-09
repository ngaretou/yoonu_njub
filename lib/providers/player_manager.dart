import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class PlayerManager with ChangeNotifier {
  AudioPlayer player = AudioPlayer();

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
      await player.seek(Duration.zero, index: initialIndex);
    } on PlayerException catch (e) {
      debugPrint("Error loading audio source: $e");
    }
  }
}
