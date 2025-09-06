import 'package:flutter/material.dart';

import 'dart:async';
import 'package:provider/provider.dart';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import 'player_controls.dart';
import '../providers/player_manager.dart';

class ShowDisplaySimple extends StatefulWidget {
  const ShowDisplaySimple({super.key});

  @override
  State<ShowDisplaySimple> createState() => _ShowDisplaySimpleState();
}

class _ShowDisplaySimpleState extends State<ShowDisplaySimple> {
  late AudioPlayer _player;
  late PlayerManager playerManager;

  Future<void> init() async {
    // playerManager = Provider.of<PlayerManager>(context, listen: true);
    playerManager = PlayerManager();
    await playerManager.initializeSession();
    _player = playerManager.player;

    final _playlist = [
      AudioSource.uri(
        Uri.parse(
            "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3"),
        tag: MediaItem(
          id: "1",
          album: "Science Friday",
          title: "A Salute To Head-Scratching Science (30 seconds)",
          artUri: Uri.parse(
              "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
        ),
      ),
      AudioSource.uri(
        Uri.parse(
            "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3"),
        tag: MediaItem(
          id: "2",
          album: "Science Friday",
          title: "A Salute To Head-Scratching Science",
          artUri: Uri.parse(
              "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
        ),
      ),
      AudioSource.uri(
        Uri.parse(
            "https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3"),
        tag: MediaItem(
          id: '3',
          album: "Science Friday",
          title: "From Cat Rheology To Operatic Incompetence",
          artUri: Uri.parse(
              "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
        ),
      ),
    ];

    await playerManager.loadPlaylist(_playlist, 0);

    return;
  }

  // @override
  // void initState() {

  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    print('show display simple');
    return FutureBuilder(
        future: init(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<SequenceState?>(
            stream: _player.sequenceStateStream,
            builder: (context, snapshot) {
              final state = snapshot.data;
              if (state?.sequence.isEmpty ?? true) {
                return const Center(child: Text('show display simple'));
              }
              final metadata = state!.currentSource!.tag as MediaItem;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Image.network(metadata.artUri.toString()),
                      ),
                    ),
                  ),
                  Text(metadata.title,
                      style: Theme.of(context).textTheme.titleLarge),
                  Text(metadata.title),
                  ControlButtons(
                    showPlayList: () {},
                    wideVersionBreakPoint: 1400,
                  ),
                ],
              );
            },
          );
        });
  }
}
