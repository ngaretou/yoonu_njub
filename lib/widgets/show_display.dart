import 'dart:async';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../main.dart';

import '../providers/shows.dart';
import '../providers/player_manager.dart';

import 'download_button.dart';
import 'player_controls.dart';
import 'animated_equalizer.dart';

class ShowDisplay extends StatefulWidget {
  const ShowDisplay({super.key});

  @override
  ShowDisplayState createState() => ShowDisplayState();
}

class ShowDisplayState extends State<ShowDisplay> {
  final ItemScrollController itemScrollController = ItemScrollController();
  AssetImage backgroundImage = AssetImage('assets/images/1.jpg');
  ValueNotifier<double> rewValueNotifier = ValueNotifier(0);
  ValueNotifier<double> ffValueNotifier = ValueNotifier(0);
  late PlayerManager playerManager;
  late AudioPlayer player;
  late PageController _pageController;
  bool isUserSwipe = false;
  bool initialLoad = true;
  double statusBarHeight = 20;

  Future<void> analyzeTopOfImage(AssetImage provider) async {
    final completer = Completer<ImageInfo>();
    provider.resolve(ImageConfiguration()).addListener(
          ImageStreamListener((info, _) => completer.complete(info)),
        );
    final imageInfo = await completer.future;
    final width = imageInfo.image.width;
    final height = imageInfo.image.height;

    final palette = await PaletteGenerator.fromImageProvider(
      provider,
      size: Size(width.toDouble(), height.toDouble()),
      region: Rect.fromLTWH(0, 0, width.toDouble(), 50),
    );

    final color = palette.dominantColor?.color ?? Colors.black;
    prefsBox.put('chrome', color.computeLuminance());
  }

  @override
  void initState() {
    if (kDebugMode) debugPrint('show display init');
    super.initState();
    playerManager = Provider.of<PlayerManager>(context, listen: false);
    player = playerManager.player;
    int initialPage = prefsBox.get('lastShowViewed') ?? 0;
    _pageController = PageController(initialPage: initialPage);
    statusBarHeight = prefsBox.get('statusBarHeight');
    player.currentIndexStream.listen((currentIndex) {
      int index = currentIndex ?? 0;
      prefsBox.put('lastShowViewed', index);

      // this controls the page controller
      if (_pageController.hasClients &&
          _pageController.page?.round() != index &&
          !isUserSwipe) {
        _pageController
            .animateToPage(
              index,
              duration: const Duration(milliseconds: 400),
              curve: Curves.linear,
            )
            .then((_) => isUserSwipe = false);
      }
    });
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
    if (kDebugMode) debugPrint('show display build');

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

    if (initialLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        analyzeTopOfImage(backgroundImage);
      });
      initialLoad = false;
    }

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
    // TextStyle showNumberStyle = TextStyle(
    //     color: Theme.of(context).textTheme.titleSmall?.color,
    //     fontFamily: "Lato",
    //     fontSize: 16);

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
      return webScrollable(
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: ScrollablePositionedList.builder(
              itemScrollController: itemScrollController,
              initialScrollIndex: showsProvider.lastShowViewed,
              physics: ClampingScrollPhysics(),
              itemCount: showsProvider.shows.length,
              itemBuilder: (ctx, i) {
                return ListTile(
                  leading: StreamBuilder(
                      stream: player.currentIndexStream,
                      builder: (context, snapshot) {
                        int currentIndex = snapshot.data ?? 0;
                        if (currentIndex == i) {
                          return StreamBuilder<bool>(
                              stream: player.playingStream,
                              builder: (context, snapshot) {
                                bool isPlaying = snapshot.data ?? false;
                                return AnimatedEqualizer(
                                    isAnimating: isPlaying);
                              });
                        } else {
                          return Icon(Icons.play_arrow);
                        }
                      }),
                  title: Text(
                      '${showsProvider.shows[i].id}. ${showsProvider.shows[i].showNameRS}',
                      style: showListStyle),
                  trailing:
                      !kIsWeb ? DownloadButton(showsProvider.shows[i]) : null,
                  onTap: () async {
                    //If not on the web version, pop the modal bottom sheet - if web, no need
                    if (isPhone || mediaQuery.width < wideVersionBreakPoint) {
                      Navigator.pop(context);
                    }
                    await player.seek(Duration.zero, index: i);
                  },
                );
              }),
        ),
      );
    }

    // Widget for the transparent panel left and right that ff and rew 10 seconds
    // this is a bit complicated but it's this way so that we can reuse the widget!
    Widget animatedSeekPanel(String direction) {
      late ValueNotifier<double> valueNotifier;
      late IconData directionIcon;
      late MouseCursor cursor;

      seekForward() async {
        final duration = player.duration ?? Duration.zero;

        if ((duration - player.position) > Duration(seconds: 11)) {
          await player.seek(player.position + Duration(seconds: 10));
        }
      }

      seekBackward() async {
        if (player.position > Duration(seconds: 11)) {
          await player.seek(player.position - Duration(seconds: 10));
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
      if (kDebugMode) debugPrint('showing playlist');
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
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
      if (kDebugMode) debugPrint('building the player stack');

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
                onPageChanged: (index) async {
                  analyzeTopOfImage(backgroundImage);
                  if (isUserSwipe) {
                    if (player.currentIndex != index) {
                      await player.seek(Duration.zero, index: index);
                      isUserSwipe = false;
                    }
                  }
                },
                itemBuilder: (context, index) {
                  final show = showsProvider.shows[index];
                  backgroundImage = AssetImage(
                    "assets/images/${show.image}.jpg",
                  );

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
                                  image: backgroundImage,
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
      // const double verticalDividerWidth = 3;
      const double minPlaylistWidth = 350;

      return Row(
        children: [
          SizedBox(
              width:
                  // mediaQuery.width - (verticalDividerWidth + minPlaylistWidth),
                  mediaQuery.width - (minPlaylistWidth),
              child: playerStack()),
          // Container(
          //     width: verticalDividerWidth,
          //     color: Theme.of(context).colorScheme.surfaceContainerLow),
          SizedBox(
              width: minPlaylistWidth,
              child: Stack(children: [
                playList(),
                if (!kIsWeb || !isPhone)
                  Positioned(
                      child: ValueListenableBuilder<Box>(
                          valueListenable:
                              prefsBox.listenable(keys: ['chrome']),
                          builder: (context, val, _) {
                            Color color = Colors.white;

                            bool lightTheme =
                                Theme.brightnessOf(context) == Brightness.light;

                            final luminescence = prefsBox.get('chrome') ?? 0;
                            final lightOverlay = luminescence < .08;

                            if (lightTheme && lightOverlay) {
                              color = Colors.black54;
                            } else if (!lightTheme && !lightOverlay) {
                              // dark on dark
                              color = Colors.white54;
                            } else {
                              color = Colors.transparent;
                            }
                            // if (lightTheme) {
                            //   color = Colors.black54;
                            // } else if (!lightTheme) {
                            //   // dark on dark
                            //   color = Colors.white54;
                            // }

                            return Container(
                                width: double.infinity,
                                height: statusBarHeight * 1.5,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [color, Colors.transparent],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: [.0, .8]),
                                ));
                          })),
              ])),
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

//To adapt to new Flutter 2.8 behavior that does not allow mice to drag - which is our desired behavior here
class MyCustomScrollBehavior extends ScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
