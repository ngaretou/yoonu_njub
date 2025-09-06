import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/drawer.dart';
import '../widgets/show_display.dart';

class MainPlayer extends StatefulWidget {
  static const routeName = 'main-player-screen';

  @override
  _MainPlayerState createState() => _MainPlayerState();
}

class _MainPlayerState extends State<MainPlayer> {
  @override
  Widget build(BuildContext context) {
    debugPrint('MainPlayerScreen');
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

    return Scaffold(
        extendBodyBehindAppBar: true,
        // floatingActionButton: FloatingActionButton(
        //   child: Icon(Icons.menu),
        //   onPressed: () => Scaffold.of(context).openDrawer(),
        //   mini: true,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.all(
        //       Radius.circular(10),
        //     ),
        //   ),
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        // ),
        appBar: AppBar(
          systemOverlayStyle: Theme.of(context).brightness == Brightness.light
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        drawer: MainDrawer(),
        body: ShowDisplay()
        // body: ShowDisplaySimple()
        );
  }
}
