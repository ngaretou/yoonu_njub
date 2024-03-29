import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'download_button.dart';
import 'player_controls.dart';
import '../providers/shows.dart';
import '../providers/player_manager.dart';

//For calling the child method from the parent - follow the childController text through this and player_controls.dart
class ChildController {
  void Function(String) childMethod = (String input) {};
}

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
  final bool showPlaylist;
  ShowDisplay(this.showPlaylist);
  @override
  ShowDisplayState createState() => ShowDisplayState();
}

class ShowDisplayState extends State<ShowDisplay> {
  PreloadPageController _pageController = PreloadPageController();
  final ScrollController _pageScrollController = ScrollController();

  final ScrollController _scrollController = ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ChildController childController = ChildController();
  bool isInitialized = false;
  ValueNotifier<double> rewValueNotifier = ValueNotifier(0);
  ValueNotifier<double> ffValueNotifier = ValueNotifier(0);

  @override
  void didChangeDependencies() {
    print('show display didChangeDependencies');
    _pageController = PreloadPageController(
      initialPage: Provider.of<Shows>(context, listen: false).lastShowViewed,
      viewportFraction: 1.0,
      keepPage: true,
    );

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _pageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //https://github.com/gskinner/flutter_animate#testing-animations
    Animate.restartOnHotReload = true;

    //Data and preliminaries
    final showsProvider = Provider.of<Shows>(context, listen: false);
    final playerManager = Provider.of<PlayerManager>(context, listen: false);
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

    //code for prev/next buttons - this makes clicking the button equivalent to scrolling

    void jumpPrevNext(String direction) {
      //This gets fed into the player_controls widget
      direction == 'next'
          ? _pageController.nextPage(
              duration: Duration(milliseconds: 500), curve: Curves.ease)
          : _pageController.previousPage(
              duration: Duration(milliseconds: 500), curve: Curves.ease);
    }

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
                      _pageController.jumpToPage(
                        i,
                      );
                    },
                    child: Card(
                      elevation: 5,
                      color: Theme.of(context).cardColor,
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
        childController.childMethod(direction);
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
    void _popUpShowList() {
      print('showing playlist');
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

    //this shows when you reload it from the AppBar button
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showPlaylist == true) {
        _popUpShowList();
      }
    });
    //End of the playlist section

    //This is the main player component - the picture, show name, player controls
    Widget playerStack() {
      Widget mainStack() {
        return Stack(children: [
          PreloadPageView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              controller: _pageController,
              preloadPagesCount: 1,
              itemCount: showsProvider.shows.length,
              onPageChanged: (int index) {
                print(index);
                //Here we want the user to be able to come back to the name they were on when they
                //return to the app, so save lastpage viewed on each page swipe.
                showsProvider.saveLastShowViewed(index);

                //This tells the player manager which show to stop.
                playerManager.showToPlay =
                    (int.parse(showsProvider.shows[index].id)).toString();
                playerManager.changePlaylist();
              },
              itemBuilder: (context, i) {
                Show show = showsProvider.shows[i];

                return Column(
                  key: UniqueKey(),
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Show image
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
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(showsProvider.shows[i].id,
                              style: _rsStyle.copyWith(fontSize: 18)),
                          Text(showsProvider.shows[i].showNameAS,
                              textAlign: TextAlign.center,
                              style: _asStyle,
                              textDirection: _rtlText),
                          Text(showsProvider.shows[i].showNameRS,
                              textAlign: TextAlign.center,
                              style: _rsStyle,
                              textDirection: _ltrText),
                        ],
                      ),
                    ),

                    ControlButtons(
                      key: ValueKey(show.filename),
                      show: show,
                      jumpPrevNext: jumpPrevNext,
                      showPlayList: _popUpShowList,
                      childController: childController,
                      wideVersionBreakPoint: wideVersionBreakPoint,
                    ),
                  ],
                );
              }),
        ]);
      }

      //playerStack return:
      // return _isPhone ? mainStack() : webScrollable(mainStack());
      return webScrollable(mainStack());
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
