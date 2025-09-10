import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';

class PlayerManager with ChangeNotifier {
  AudioPlayer player = AudioPlayer();

  Stream<(bool, ProcessingState, int)> get playerStateStream =>
      Rx.combineLatest2(
          player.playerEventStream,
          player.sequenceStream,
          (event, sequence) => (
                event.playing,
                event.playbackEvent.processingState,
                sequence.length,
              ));

  Future<void> initializeSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());

    // Listen to errors during playback.
    // player.errorStream.listen((event) {
    //   if (kDebugMode) debugPrint('A stream error occurred: ${event.toString}');
    // });

    if (kDebugMode) debugPrint('initializeSession complete');
  }

  Future<void> loadPlaylist(
      List<AudioSource> playlist, int initialIndex) async {
    if (kDebugMode) debugPrint('loadPlaylist');
    try {
      await player.setAudioSources(playlist,
          initialIndex: initialIndex, preload: true);
      await player.seek(Duration.zero, index: initialIndex);
    } on PlayerException catch (e) {
      if (kDebugMode) debugPrint("Error loading audio source: $e");
    }
  }
}
