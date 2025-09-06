import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'download_button.dart';
import 'player_controls.dart';
import '../providers/shows.dart';
import '../providers/player_manager.dart';

//For calling the child method from the parent - follow the childController text through this and player_controls.dart
// class ChildController {
//   void Function(String) childMethod = (String input) {};
// }

//To adapt to new Flutter 2.8 behavior that does not allow mice to drag - which is our desired behavior here
class MyCustomScrollBehavior extends ScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class ShowDisplay extends StatefulWidget {
  @override
  ShowDisplayState createState() => ShowDisplayState();
}

class ShowDisplayState extends State<ShowDisplay> {
  final ItemScrollController itemScrollController = ItemScrollController();

  ValueNotifier<double> rewValueNotifier = ValueNotifier(0);
  ValueNotifier<double> ffValueNotifier = ValueNotifier(0);
  late PlayerManager playerManager;
  late AudioPlayer player;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    rewValueNotifier.dispose();
    ffValueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('show display build');
    playerManager = Provider.of<PlayerManager>(context, listen: true);
    player = playerManager.player;
    //https://github.com/gskinner/flutter_animate#testing-animations
    Animate.restartOnHotReload = true;

    //Data and preliminaries
    final showsProvider = Provider.of<Shows>(context, listen: false);

    final mediaQuery = MediaQuery.of(context).size;
    //Smallest iPhone is UIKit 320 x 480 = 800.
    //Biggest (12 pro max) is 428 x 926 = 1354.
    //Android biggest phone I can find is is 480 x 853 = 1333
    //For tablets the smallest I can find is 768 x 1024
    final bool _isPhone = (mediaQuery.width + mediaQuery.height) <= 1400;
    final int wideVersionBreakPoint = 700;
    //Text Styles
    ui.TextDirection _rtlText = ui.TextDirection.rtl;
    ui.TextDirection _ltrText = ui.TextDirection.ltr;

    TextStyle _asStyle = TextStyle(
        color: Theme.of(context).textTheme.titleLarge!.color,
        fontFamily: "Harmattan",
        fontSize: 32);

    TextStyle _rsStyle = TextStyle(
        color: Theme.of(context).textTheme.titleLarge!.color,
        fontFamily: "Lato",
        fontSize: 22);

    TextStyle showListStyle = TextStyle(
        color: Theme.of(context).textTheme.titleLarge!.color,
        fontFamily: "Lato",
        fontSize: 20);

    //This page is split up into components that can be recombined based on the platform.

    // For web, a widget to facilitate dragging
    Widget webScrollable(Widget childWidget) {
      return MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: ScrollConfiguration(
              //The 2.8 Flutter behavior is to not have mice grabbing and dragging - but we do want this in the web version of the app, so the custom scroll behavior here
              //Turn off scrollbar here so as to be able to control it more below with Scrollbar widget
              behavior: MyCustomScrollBehavior()
                  .copyWith(scrollbars: kIsWeb ? true : false),
              child: childWidget));
    }

    //This is the playList widget. For web, it will go side by side; for app, it will go as a drawer.
    Widget playList() {
      Widget playListInterior() {
        return ScrollablePositionedList.builder(
            itemScrollController: itemScrollController,
            initialScrollIndex: showsProvider.lastShowViewed,
            physics: ClampingScrollPhysics(),
            itemCount: showsProvider.shows.length,
            itemBuilder: (ctx, i) {
              return Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      //If not on the web version, pop the modal bottom sheet - if web, no need
                      if (_isPhone || mediaQuery.width < wideVersionBreakPoint)
                        Navigator.pop(context);
                      player.seek(Duration.zero, index: i);
                    },
                    child: Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 0,
                                child: Text(showsProvider.shows[i].id + ".  ",
                                    style: showListStyle)),
                            Expanded(
                              flex: 3,
                              child: Text(showsProvider.shows[i].showNameRS,
                                  style: showListStyle),
                            ),
                            if (!kIsWeb)
                              Container(
                                  width: 40,
                                  height: 40,
                                  child:
                                      DownloadButton(showsProvider.shows[i])),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            });
      }

      return webScrollable(playListInterior());
    }

    //Widget for the transparent panel left and right that ff and rew 10 seconds
    Widget animatedSeekPanel(String direction) {
      late ValueNotifier<double> valueNotifier;
      late IconData directionIcon;
      late MouseCursor cursor;

      if (direction == 'ff') {
        valueNotifier = ffValueNotifier;
        directionIcon = Icons.fast_forward;
        cursor = SystemMouseCursors.resizeRight;
      } else if (direction == 'rew') {
        valueNotifier = rewValueNotifier;
        directionIcon = Icons.fast_rewind;
        cursor = SystemMouseCursors.resizeLeft;
      }

      void triggerSeek() {
        if (valueNotifier.value == 1) {
          valueNotifier.value = 0;
        } else {
          valueNotifier.value = 1;
        }
      }

      return Expanded(
        child: MouseRegion(
          cursor: cursor,
          child: GestureDetector(
            //Makes more sense for web to ff on single click
            onTap: kIsWeb ? triggerSeek : () {},
            //But for mobile to dbl click
            onDoubleTap: !kIsWeb ? triggerSeek : () {},
            child: RepaintBoundary(
              child: Container(
                child: Icon(
                  directionIcon,
                  size: 75,
                ),
                // width: mediaQuery.width / 2,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const ui.Color.fromARGB(76, 255, 255, 255),
                      Colors.transparent,
                    ],
                    center: Alignment.center,
                    radius: 2,
                  ),
                ),
              )
                  .animate(
                    adapter:
                        ValueNotifierAdapter(valueNotifier, animated: true),
                  )
                  .fadeIn()
                  .then()
                  .fadeOut(),
            ),
          ),
        ),
      );
    }

    // The function that shows the bottom playlist drawer, playList()
    void popUpShowList() {
      debugPrint('showing playlist');
      showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
        ),
        builder: (context) {
          return ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Container(
                padding: EdgeInsets.only(top: 8),
                height: mediaQuery.height * .8,
                //Here is the real content, the playList widget
                child: playList(),
              ));
        },
      );
    }

    //End of the playlist section

    //This is the main player component - the picture, show name, player controls
    Widget playerStack() {
      return webScrollable(Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: StreamBuilder(
                stream: player.sequenceStateStream,
                builder: (context, snapshot) {
                  print('sequencestatestream');
                  final state = snapshot.data;
                  if (state?.sequence.isEmpty ?? true) {
                    // return const SizedBox();
                    return const SizedBox();
                  }
                  final metadata = state!.currentSource!.tag as MediaItem;

                  int id = int.parse(metadata.id);

                  //Show image
                  return Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Stack(
                          children: [
                            Container(
                              // width: mediaQuery.width,
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage(
                                    "assets/images/${showsProvider.shows[id].image}.jpg",
                                  ),
                                ),
                              ),
                            ),

                            //the left and right sides of the invisible double tap ff and rewind areas

                            Material(
                              type: MaterialType.transparency,
                              child: Row(
                                children: [
                                  animatedSeekPanel('rew'),
                                  animatedSeekPanel('ff'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(showsProvider.shows[id].id,
                          style: _rsStyle.copyWith(fontSize: 18)),
                      Text(showsProvider.shows[id].showNameAS,
                          textAlign: TextAlign.center,
                          style: _asStyle,
                          textDirection: _rtlText),
                      Text(showsProvider.shows[id].showNameRS,
                          textAlign: TextAlign.center,
                          style: _rsStyle,
                          textDirection: _ltrText),
                    ],
                  );
                }),
          ),
          ControlButtons(
            showPlayList: popUpShowList,
            wideVersionBreakPoint: wideVersionBreakPoint,
          )
        ],
      ));
    }
    //End of main player component

    //Putting it all together. First set up the widget combinations
    Widget phoneVersion() {
      return Center(
        child: Container(
          child: playerStack(),
        ),
      );
    }

    Widget wideVersion() {
      return Row(
        children: [
          Container(width: mediaQuery.width * .7, child: playerStack()),
          Container(width: mediaQuery.width * .3, child: playList()),
        ],
      );
    }

    //Now figure out which version to use and build it

    if (_isPhone || mediaQuery.width <= wideVersionBreakPoint) {
      return phoneVersion();
    } else {
      return wideVersion();
    }
  }
}
