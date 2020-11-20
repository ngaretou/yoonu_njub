import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/drawer.dart';
import '../widgets/show_display.dart';

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
        // actions: [
        // IconButton(
        //   icon: Icon(Icons.calendar_today),
        //   onPressed: () {
        //     Navigator.of(context).pushNamed(DateScreen.routeName,
        //         arguments: DateScreenArgs(
        //             year: currentYear,
        //             month: currentMonth,
        //             date: currentDate));
        //   },
        // ),
        // ],
      ),
      drawer: MainDrawer(),
      body: ShowDisplay(),
    );
  }
}
