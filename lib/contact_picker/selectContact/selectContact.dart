import 'package:flutter/material.dart';

class SelectContactPage extends StatelessWidget {
  const SelectContactPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            //color
            //brightness: Brightness.dark,
            backgroundColor: Colors.black,
            //default color of things within app bar
            foregroundColor: Colors.white,
            //everything else
            automaticallyImplyLeading: false,
            excludeHeaderSemantics: false,
            //collapsedHeight: kToolbarHeight, //<- smallest possible value
            //titleSpacing: 0,
            //NOTE: leading to left of title
            //NOTE: title in middle
            //NOTE: action to right of title
            //show extra top padding
            primary: true,
            //only show shadow if content below
            forceElevated: false,
            //snapping is annoying and disorienting
            //but the opposite is ugly
            snap: false,
            pinned: true, //so the [bottom] parameter allways shows
            //might make it open in annoying times (so we turn it off)
            floating: true,
            //most of the screen
            expandedHeight: 250,
            //better illustrates the overscroll
            stretch: true,
            //the map
            flexibleSpace: FlexibleSpaceBar(
              //parallax keeps the background centered within flexible space
              //pin will essentially make it another sticky header
              //but to give the top app bar a back ground all the time I need none
              collapseMode: CollapseMode.none,
              //this does work
              stretchModes: [
                //this plays well enough and gets the point accross
                StretchMode.blurBackground,

                //we don't have one
                StretchMode.fadeTitle,

                //zooming doesn't play well the map
                StretchMode.zoomBackground,
              ],
              background: Center(
                child: Text(
                  "Prompt",
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size(
                MediaQuery.of(context).size.width,
                48,
              ),
              child: Container(
                color: Colors.white,
                height: 48,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
          SliverFillRemaining(
            child: Container(
              color: Colors.red,
              child: Center(
                child: Text("help me"),
              ),
            ),
          ),
          /*
          SliverToBoxAdapter(
            child: Theme(
              data: ThemeData.light(),
              child: CategorySelectionPageBody(
                labelType: labelType,
                labelString: labelString,
              ),
            ),
          ),
          */
        ],
      ),
    );
  }
}