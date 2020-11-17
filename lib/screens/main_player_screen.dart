import 'package:flutter/material.dart';

import '../widgets/drawer.dart';
import '../widgets/show_display.dart';

class MainPlayer extends StatelessWidget {
  static const routeName = 'main-player-screen';

  @override
  Widget build(BuildContext context) {
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
