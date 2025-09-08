import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:just_audio/just_audio.dart';

import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'download_button.dart';
import 'player_controls.dart';
import '../providers/shows.dart';
import '../providers/player_manager.dart';

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
  const ShowDisplay({super.key});

  @override
  ShowDisplayState createState() => ShowDisplayState();
}

class ShowDisplayState extends State<ShowDisplay> {
  final ItemScrollController itemScrollController = ItemScrollController();

  ValueNotifier<double> rewValueNotifier = ValueNotifier(0);
  ValueNotifier<double> ffValueNotifier = ValueNotifier(0);
  late PlayerManager playerManager;
  late AudioPlayer player;
  late PageController _pageController;
  bool isUserSwipe = true;

  @override
  void initState() {
    super.initState();
    playerManager = Provider.of<PlayerManager>(context, listen: false);
    player = playerManager.player;
    final showsProvider = Provider.of<Shows>(context, listen: false);
    player.currentIndex;
    player.currentIndexStream.listen((index) {
      isUserSwipe = false;
      if (index != null &&
          _pageController.hasClients &&
          _pageController.page?.round() != index) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn,
        );
      }
    });
    _pageController = PageController(initialPage: showsProvider.lastShowViewed);
  }

  @override
  void dispose() {
    rewValueNotifier.dispose();
    ffValueNotifier.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('show display build');
    //https://github.com/gskinner/flutter_animate#testing-animations
    Animate.restartOnHotReload = true;

    //Data and preliminaries
    final showsProvider = Provider.of<Shows>(context, listen: false);

    final mediaQuery = MediaQuery.of(context).size;
    //Smallest iPhone is UIKit 320 x 480 = 800.
    //Biggest (12 pro max) is 428 x 926 = 1354.
    //Android biggest phone I can find is is 480 x 853 = 1333
    //For tablets the smallest I can find is 768 x 1024
    final bool isPhone = (mediaQuery.width + mediaQuery.height) <= 1400;
    final int wideVersionBreakPoint = 700;
    //Text Styles
    ui.TextDirection rtlText = ui.TextDirection.rtl;
    ui.TextDirection ltrText = ui.TextDirection.ltr;

    TextStyle asStyle = TextStyle(
        color: Theme.of(context).textTheme.titleLarge?.color,
        fontFamily: "Harmattan",
        fontSize: 32);

    TextStyle rsStyle = TextStyle(
        color: Theme.of(context).textTheme.titleLarge?.color,
        fontFamily: "Lato",
        fontSize: 22);

    TextStyle showListStyle = TextStyle(
        color: Theme.of(context).textTheme.titleLarge?.color,
        fontFamily: "Lato",
        fontSize: 18);
    TextStyle showNumberStyle = TextStyle(
        color: Theme.of(context).textTheme.titleSmall?.color,
        fontFamily: "Lato",
        fontSize: 16);

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
        print('building scrollable positionedlist of playlist');
        return ScrollablePositionedList.builder(
            itemScrollController: itemScrollController,
            initialScrollIndex: showsProvider.lastShowViewed,
            physics: ClampingScrollPhysics(),
            itemCount: showsProvider.shows.length,
            itemBuilder: (ctx, i) {
              return ListTile(
                leading:
                    Text(showsProvider.shows[i].id, style: showNumberStyle),
                title: Text(showsProvider.shows[i].showNameRS,
                    style: showListStyle),
                trailing:
                    !kIsWeb ? DownloadButton(showsProvider.shows[i]) : null,
                onTap: () {
                  //If not on the web version, pop the modal bottom sheet - if web, no need
                  if (isPhone || mediaQuery.width < wideVersionBreakPoint) {
                    Navigator.pop(context);
                  }
                  player.seek(Duration.zero, index: i);
                },
              );
            });
      }

      return webScrollable(playListInterior());
    }

    // Widget for the transparent panel left and right that ff and rew 10 seconds
    // this is a bit complicated but it's this way so that we can reuse the widget!
    Widget animatedSeekPanel(String direction) {
      late ValueNotifier<double> valueNotifier;
      late IconData directionIcon;
      late MouseCursor cursor;

      seekForward() {
        final duration = player.duration ?? Duration.zero;

        if ((duration - player.position) > Duration(seconds: 11)) {
          player.seek(player.position + Duration(seconds: 10));
        }
      }

      seekBackward() {
        if (player.position > Duration(seconds: 11)) {
          player.seek(player.position - Duration(seconds: 10));
        }
      }

      if (direction == 'ff') {
        valueNotifier = ffValueNotifier;
        directionIcon = Icons.fast_forward;
        cursor = SystemMouseCursors.resizeRight;
      } else if (direction == 'rew') {
        valueNotifier = rewValueNotifier;
        directionIcon = Icons.fast_rewind;
        cursor = SystemMouseCursors.resizeLeft;
        seekBackward();
      }

      void triggerSeek() {
        if (valueNotifier.value == 1) {
          valueNotifier.value = 0;
        } else {
          valueNotifier.value = 1;
        }
        if (direction == 'ff') {
          seekForward();
        } else if (direction == 'rew') {
          seekBackward();
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
                child: Icon(
                  directionIcon,
                  size: 75,
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
      print('building teh player stack');

      return webScrollable(Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification &&
                    notification.dragDetails != null) {
                  isUserSwipe = true;
                }
                return false;
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: showsProvider.shows.length,
                onPageChanged: (index) {
                  if (isUserSwipe) {
                    if (player.currentIndex != index) {
                      player.seek(Duration.zero, index: index);
                    }
                  }
                },
                itemBuilder: (context, index) {
                  final show = showsProvider.shows[index];
                  return Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              // width: mediaQuery.width,
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage(
                                    "assets/images/${show.image}.jpg",
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
                      Text(show.id, style: rsStyle.copyWith(fontSize: 18)),
                      Text(show.showNameAS,
                          textAlign: TextAlign.center,
                          style: asStyle,
                          textDirection: rtlText),
                      Text(show.showNameRS,
                          textAlign: TextAlign.center,
                          style: rsStyle,
                          textDirection: ltrText),
                    ],
                  );
                },
              ),
            ),
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
          SizedBox(width: mediaQuery.width * .7, child: playerStack()),
          SizedBox(width: mediaQuery.width * .3, child: playList()),
        ],
      );
    }

    //Now figure out which version to use and build it

    if (isPhone || mediaQuery.width <= wideVersionBreakPoint) {
      return phoneVersion();
    } else {
      return wideVersion();
    }
  }
}
