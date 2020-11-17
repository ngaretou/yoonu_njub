import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'download_button.dart';

import '../providers/shows.dart';
import '../widgets/player_controls.dart';

class ShowDisplay extends StatefulWidget {
  @override
  _ShowDisplayState createState() => _ShowDisplayState();
}

class _ShowDisplayState extends State<ShowDisplay> {
  PageController _pageController;

  // @override
  // void initState() {
  //   _pageController = PageController(
  //     initialPage: Provider.of<Shows>(context, listen: false).lastShowViewed,
  //     viewportFraction: 1,
  //     keepPage: true,
  //   );
  //   super.initState();
  // }

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
  Widget build(BuildContext context) {
    //Data and preliminaries
    final shows = Provider.of<Shows>(context, listen: false);
    int currentPageId;
    final mediaQuery = MediaQuery.of(context).size;
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

    print('shows.lastShowViewed');
    print(shows.lastShowViewed);

    final ItemScrollController itemScrollController = ItemScrollController();

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
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Container(
                  padding: EdgeInsets.only(top: 8),
                  height: mediaQuery.height * .8,
                  child: ScrollablePositionedList.builder(
                      itemScrollController: itemScrollController,
                      initialScrollIndex: initialScrollIndex,
                      physics: ClampingScrollPhysics(),
                      itemCount: shows.shows.length,
                      itemBuilder: (ctx, i) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              _pageController.jumpToPage(i);
                            },
                            child: Card(
                              elevation: 5,
                              color: Theme.of(context).cardColor,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 16.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: Text(shows.shows[i].id + ".  ",
                                            style: showListStyle)),
                                    Expanded(
                                      flex: 3,
                                      child: Text(shows.shows[i].showNameRS,
                                          style: showListStyle),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: DownloadButton(shows.shows[i]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      })),
            ),
          );
        },
      );
    }

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
                AspectRatio(
                  aspectRatio: mediaQuery.height > 800 ? 8 / 7 : 16 / 9,
                  child: Image.asset(
                    'assets/images/${show.image}.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Text(shows.shows[i].id + ': ' + shows.shows[i].showNameAS,
                          textAlign: TextAlign.center,
                          style: _asStyle,
                          textDirection: _rtlText),
                      Text(shows.shows[i].id + ': ' + shows.shows[i].showNameRS,
                          textAlign: TextAlign.center,
                          style: _rsStyle,
                          textDirection: _ltrText),
                    ],
                  ),
                ),

                ControlButtons(show),
                SizedBox(
                  height: 50,
                )
              ],
            );
          }),

      //ModalBottomSheet version here, other option is below DraggableScrollableSheet
      Positioned(
        bottom: 0,
        child: GestureDetector(
          onTap: () {
            print(currentPageId);
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

      //DraggableScrollableSheet version here:
      // DraggableScrollableSheet(
      //     initialChildSize: .08,
      //     minChildSize: .08,
      //     maxChildSize: .9,
      //     builder: (BuildContext context, ScrollController scrollController) {
      //       return Container(
      //         padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      //         decoration: BoxDecoration(
      //           borderRadius: BorderRadius.circular(10.0),
      //           color: Colors.grey,
      //           // gradient: LinearGradient(
      //           //   begin: Alignment.bottomRight,
      //           //   colors: [
      //           //     Colors.black87,
      //           //     Colors.black12,
      //           //   ],
      //           // ),
      //         ),
      //         child: ClipRRect(
      //           borderRadius: BorderRadius.circular(15.0),
      //           child: CustomScrollView(
      //             controller: scrollController,
      //             slivers: [
      //               SliverToBoxAdapter(
      //                 child: Padding(
      //                     padding: const EdgeInsets.only(bottom: 8.0),
      //                     child: GestureDetector(
      //                       onTap: () {
      //                         // setState(() {
      //
      //                         //   _drawerOpen = !_drawerOpen;
      //                         // });
      //                       },
      //                       child: _drawerOpen
      //                           ? Icon(
      //                               Icons.arrow_drop_down,
      //                               size: 40,
      //                             )
      //                           : Icon(
      //                               Icons.arrow_drop_up,
      //                               size: 40,
      //                             ),
      //                     )),
      //               ),
      //               SliverList(
      //                 delegate: SliverChildListDelegate(
      //                   [
      //                     ListView.builder(
      //                       shrinkWrap: true,
      //                       physics: NeverScrollableScrollPhysics(),
      //                       itemCount: shows.shows.length,
      //                       itemBuilder: (ctx, i) {
      //                         return Card(
      //                           elevation: 5,
      //                           color: Theme.of(context).cardColor,
      //                           child: Padding(
      //                             padding: const EdgeInsets.symmetric(
      //                                 horizontal: 8.0, vertical: 16.0),
      //                             child: Row(
      //                               children: [
      //                                 Text(
      //                                     shows.shows[i].id +
      //                                         ".  " +
      //                                         shows.shows[i].showNameRS,
      //                                     style: TextStyle(
      //                                         fontFamily: "Lato",
      //                                         fontSize: 20)),
      //                                 Expanded(
      //                                   child: Align(
      //                                       alignment: Alignment.centerRight,
      //                                       child:
      //                                           DownloadButton(shows.shows[i])),
      //                                 ),
      //                               ],
      //                             ),
      //                           ),
      //                         );
      //                       },
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       );
      //     })
    ]);
  }
}
