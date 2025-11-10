import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:yoonu_njub/main.dart';
import '../widgets/drawer.dart';
import '../widgets/show_display.dart';

class MainPlayer extends StatefulWidget {
  static const routeName = 'main-player-screen';

  const MainPlayer({super.key});

  @override
  State<MainPlayer> createState() => _MainPlayerState();
}

class _MainPlayerState extends State<MainPlayer> {
  ValueNotifier<SystemUiOverlayStyle> chrome =
      ValueNotifier(SystemUiOverlayStyle.light);
  ValueListenable<Box<dynamic>> box = prefsBox.listenable(keys: ['chrome']);

  @override
  void initState() {
    // if the box changes, this runs - otherwise no change, and we keep the context brightness.
    box.addListener(() {
      final luminescence = prefsBox.get('chrome');

      chrome.value = luminescence < .08
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark;
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // initial value - this will get changed if kIsWeb || isPhone in show_display.dart
    chrome.value = Theme.brightnessOf(context) == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) debugPrint('MainPlayerScreen');
    //Smallest iPhone is UIKit 320 x 480 = 800.
    //Biggest (12 pro max) is 428 x 926 = 1354.
    //Android biggest phone I can find is is 480 x 853 = 1333
    //For tablets the smallest I can find is 768 x 1024
    final mediaQuery = MediaQuery.of(context).size;
    final bool isPhone = (mediaQuery.width + mediaQuery.height) <= 1400;
    if (isPhone) {
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

    prefsBox.put('statusBarHeight', MediaQuery.of(context).padding.top);

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
            preferredSize:
                const Size.fromHeight(kToolbarHeight), // Standard AppBar height
            child: ValueListenableBuilder<SystemUiOverlayStyle>(
                valueListenable: chrome,
                builder: (context, _, __) {
                  final color = chrome.value == SystemUiOverlayStyle.light
                      ? Colors.white
                      : Colors.black;
                  return AppBar(
                    iconTheme: IconThemeData(color: color),
                    systemOverlayStyle: chrome.value,
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                  );
                })),
        drawer: MainDrawer(),
        body: ShowDisplay()
        // body: ShowDisplaySimple()
        );
  }
}
