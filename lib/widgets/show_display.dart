import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'download_button.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../providers/shows.dart';
import '../widgets/player_controls.dart';

class ShowDisplay extends StatefulWidget {
  @override
  _ShowDisplayState createState() => _ShowDisplayState();
}

class _ShowDisplayState extends State<ShowDisplay> {
  PageController _pageController;
  ScrollController _scrollController = ScrollController();
  ScrollController _pageScrollController = ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();

  @override
  void didChangeDependencies() {
    _pageController = PageController(
      initialPage: Provider.of<Shows>(context, listen: false).lastShowViewed,
      viewportFraction: 1,
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
    final shows = Provider.of<Shows>(context, listen: false);
    int currentPageId;
    final mediaQuery = MediaQuery.of(context).size;
    //Smallest iPhone is UIKit 320 x 480 = 800.
    //Biggest (12 pro max) is 428 x 926 = 1354.
    //Android biggest phone I can find is is 480 x 853 = 1333
    //For tablets the smallest I can find is 768 x 1024
    final bool _isPhone = (mediaQuery.width + mediaQuery.height) <= 1400;

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

    void jumpPrevNext(String direction) {
      direction == 'next'
          ? _pageController.nextPage(
              duration: Duration(milliseconds: 500), curve: Curves.ease)
          : _pageController.previousPage(
              duration: Duration(milliseconds: 500), curve: Curves.ease);
    }

//This page is split up into components that can be recombined based on the platform.
//This is the playList widget. For web, it will go side by side; for app, it will go as a drawer.
    Widget playList(int initialScrollIndex) {
      Widget mainList() {
        return ScrollablePositionedList.builder(
            itemScrollController: itemScrollController,
            initialScrollIndex: initialScrollIndex,
            physics: ClampingScrollPhysics(),
            itemCount: shows.shows.length,
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
                      _pageController.animateToPage(i,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeIn);
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
                                child: Text(shows.shows[i].id + ".  ",
                                    style: showListStyle)),
                            Expanded(
                              flex: 3,
                              child: Text(shows.shows[i].showNameRS,
                                  style: showListStyle),
                            ),
                            if (!kIsWeb)
                              // Expanded(
                              //   flex: 1,
                              //   child:
                              DownloadButton(shows.shows[i]),
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
    void _popUpShowList(BuildContext context, int initialScrollIndex) {
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
                child: playList(initialScrollIndex),
              ));
        },
      );
    }

    //This is the main player component
    Widget playerStack() {
      Widget mainStack() {
        return Stack(children: [
          PageView.builder(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              controller: _pageController,
              onPageChanged: (index) {
                //Here we want the user to be able to come back to the name they were on when they
                //return to the app, so save lastpage viewed on each page swipe.

                shows.saveLastShowViewed(index + 1);
              },
              itemCount: shows.shows.length,
              itemBuilder: (context, i) {
                Show show = shows.shows[i];
                currentPageId = int.parse(show.id) - 1;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Show image
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: mediaQuery.width,
                        child: Image.asset(
                          'assets/images/${show.image}.jpg',
                          fit: BoxFit.cover,
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
                          Text(shows.shows[i].id,
                              style: _rsStyle.copyWith(fontSize: 18)),
                          Text(shows.shows[i].showNameAS,
                              textAlign: TextAlign.center,
                              style: _asStyle,
                              textDirection: _rtlText),
                          Text(shows.shows[i].showNameRS,
                              textAlign: TextAlign.center,
                              style: _rsStyle,
                              textDirection: _ltrText),
                        ],
                      ),
                    ),

                    ControlButtons(show, jumpPrevNext),
                    SizedBox(
                      height: 50,
                    )
                  ],
                );
              }),

          //ModalBottomSheet version here, other option is below DraggableScrollableSheet
          if (_isPhone || mediaQuery.width < 600)
            Positioned(
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  _popUpShowList(context, currentPageId);
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
          Container(width: mediaQuery.width * .4, child: playList(0)),
        ],
      );
    }

    print(mediaQuery.width);
    if (_isPhone || mediaQuery.width < 600) {
      return phoneVersion();
    } else {
      return webVersion();
    }
  }
}
