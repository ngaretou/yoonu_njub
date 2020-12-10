import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:preload_page_view/preload_page_view.dart';

import 'download_button.dart';
import '../widgets/player_controls.dart';
import '../providers/shows.dart';
import '../providers/player_manager.dart';

class ShowDisplay extends StatefulWidget {
  final bool showPlaylist;
  ShowDisplay(this.showPlaylist);
  @override
  ShowDisplayState createState() => ShowDisplayState();
}

class ShowDisplayState extends State<ShowDisplay> {
  PreloadPageController _pageController;
  ScrollController _scrollController = ScrollController();
  ScrollController _pageScrollController = ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();

  @override
  void didChangeDependencies() {
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
    //Data and preliminaries
    final showsProvider = Provider.of<Shows>(context, listen: false);
    final playerManager = Provider.of<PlayerManager>(context, listen: false);
    final mediaQuery = MediaQuery.of(context).size;
    //Smallest iPhone is UIKit 320 x 480 = 800.
    //Biggest (12 pro max) is 428 x 926 = 1354.
    //Android biggest phone I can find is is 480 x 853 = 1333
    //For tablets the smallest I can find is 768 x 1024
    final bool _isPhone = (mediaQuery.width + mediaQuery.height) <= 1400;

    void jumpPrevNext(String direction) {
      direction == 'next'
          ? _pageController.nextPage(
              duration: Duration(milliseconds: 500), curve: Curves.ease)
          : _pageController.previousPage(
              duration: Duration(milliseconds: 500), curve: Curves.ease);
    }

    //Text Styles
    ui.TextDirection _rtlText = ui.TextDirection.rtl;
    ui.TextDirection _ltrText = ui.TextDirection.ltr;

    TextStyle _asStyle = TextStyle(
        // height: 1.3,
        color: Theme.of(context).textTheme.headline6.color,
        fontFamily: "Harmattan",
        fontSize: 32);

    TextStyle _rsStyle = TextStyle(
        // height: 1.3,
        color: Theme.of(context).textTheme.headline6.color,
        fontFamily: "Lato",
        fontSize: 22);

    TextStyle showListStyle = TextStyle(
        // height: 1.3,
        color: Theme.of(context).textTheme.headline6.color,
        fontFamily: "Lato",
        fontSize: 20);

// //This page is split up into components that can be recombined based on the platform.
// //This is the playList widget. For web, it will go side by side; for app, it will go as a drawer.
    Widget playList() {
      Widget mainList() {
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
                      if (_isPhone || mediaQuery.width < 600)
                        Navigator.pop(context);
                      // _pageController.jumpToPage(i);
                      // _pageController.animateToPage(i,
                      //     duration: Duration(milliseconds: 500),
                      //     curve: Curves.easeIn);
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
                              // Expanded(
                              //   flex: 1,
                              //   child:
                              DownloadButton(showsProvider.shows[i]),
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

      return Scrollbar(
        child: mainList(),
        controller: _scrollController,
        // isAlwaysShown: alwaysShowScrollbars,
      );
    }

// Bottom playlist drawer
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showPlaylist == true) {
        _popUpShowList();
      }
    });

    //This is the main player component
    Widget playerStack() {
      Widget mainStack() {
        return Stack(children: [
          PreloadPageView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              controller: _pageController,
              preloadPagesCount: 3,
              itemCount: showsProvider.shows.length,
              onPageChanged: (index) {
                //Here we want the user to be able to come back to the name they were on when they
                //return to the app, so save lastpage viewed on each page swipe.

                showsProvider.saveLastShowViewed(index);

                //This tells the player manager which show to stop.
                playerManager.showToPlay =
                    (int.parse(showsProvider.shows[index].id)).toString();
              },
              itemBuilder: (context, i) {
                Show show = showsProvider.shows[i];

                print('assets/images/${show.image}.jpg');
                return Column(
                  key: UniqueKey(),
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Show image
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: mediaQuery.width,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage(
                              "assets/images/${show.image}.jpg",
                              // bundle: DefaultAssetBundle.of(context)),
                              // bundle: rootBundle
                            ),
                          ),
                        ),
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
                        jumpPrevNext: jumpPrevNext),
                    SizedBox(
                      height: 50,
                    )
                  ],
                );
              }),
          if (_isPhone || mediaQuery.width < 600)
            Positioned(
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  _popUpShowList();
                },
                child: Container(
                  width: mediaQuery.width,
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 1),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          topLeft: Radius.circular(15)),
                      color: Theme.of(context).cardColor),
                  child: Center(
                    child: Icon(
                      Icons.arrow_drop_up,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
        ]);
      }

      return _isPhone
          ? mainStack()
          : Scrollbar(
              // isAlwaysShown: true,
              controller: _pageScrollController,
              child: mainStack());
    }

    Widget phoneVersion() {
      return Center(
        child: Container(
          child: playerStack(),
        ),
      );
    }

    Widget webVersion() {
      return Row(
        children: [
          Container(width: mediaQuery.width * .6, child: playerStack()),
          //playList takes an initialPage, which here is 0, the first one
          Container(width: mediaQuery.width * .4, child: playList()),
        ],
      );
    }

    // print(mediaQuery.width);
    if (_isPhone || mediaQuery.width < 600) {
      print('returning phoneVersion');
      return phoneVersion();
    } else {
      return webVersion();
    }
  }
}
