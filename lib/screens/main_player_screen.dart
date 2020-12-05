import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../locale/app_localization.dart';

import '../widgets/drawer.dart';
import '../widgets/show_display.dart';
import '../widgets/contact_options.dart';

class MainPlayer extends StatelessWidget {
  static const routeName = 'main-player-screen';

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
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              //open the contact us possibilities
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: Text(
                      AppLocalization.of(context).settingsContactUs,
                    ),
                    // content:
                    //     Text(AppLocalization.of(context).settingsContactUs),
                    children: [ContactOptions()],
                  );
                },
              );
            },
          ),
        ],
      ),
      drawer: MainDrawer(),
      body: ShowDisplay(),
    );
  }
}
