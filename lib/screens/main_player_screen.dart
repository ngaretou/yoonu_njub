// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/drawer.dart';
import '../widgets/show_display.dart';
import '../widgets/contact_options.dart';

class MainPlayer extends StatefulWidget {
  static const routeName = 'main-player-screen';

  @override
  _MainPlayerState createState() => _MainPlayerState();
}

class _MainPlayerState extends State<MainPlayer> {
  bool _showPlaylist;
  @override
  void initState() {
    _showPlaylist = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Smallest iPhone is UIKit 320 x 480 = 800.
    //Biggest (12 pro max) is 428 x 926 = 1354.
    //Android biggest phone I can find is is 480 x 853 = 1333
    //For tablets the smallest I can find is 768 x 1024
    final mediaQuery = MediaQuery.of(context).size;
    final bool _isPhone = (mediaQuery.width + mediaQuery.height) <= 1400;
    if (_isPhone) {
      //only allow portrait mode, not landscape
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight
      ]);
    }

    print('_MainPlayerState build');

    return Scaffold(
      appBar: AppBar(
        title: Text("Yoonu Njub"),
        actions: [
          if (_isPhone || mediaQuery.width < 600)
            IconButton(
                icon: Icon(Icons.playlist_play),
                onPressed: () async {
                  //when triggered rebuild the page so the popup is shown

                  setState(() {
                    _showPlaylist = true;
                  });
                  //then switch back to false wihtout setState for the next time.
                  //The future is necessary because otherwise flutter is *too* fast - if you don't wait it
                  //switches before it can build and you don't get the popup!
                  await new Future.delayed(const Duration(seconds: 5))
                      .then((value) => _showPlaylist = false);
                }),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              //open the contact us possibilities
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: Text(
                      AppLocalizations.of(context).settingsContactUs,
                    ),
                    // content:
                    //     Text(AppLocalizations.of(context).settingsContactUs),
                    children: [ContactOptions()],
                  );
                },
              );
            },
          ),
        ],
      ),
      drawer: MainDrawer(),
      body: ShowDisplay(_showPlaylist),
    );
  }
}
