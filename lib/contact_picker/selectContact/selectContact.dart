import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/newContact/newContactPage.dart';
import 'package:flutter2_contact_picker/contact_picker/searchContact/searchContact.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/goldenRatio.dart';
import 'package:page_transition/page_transition.dart';

class SelectContactPage extends StatelessWidget {
  const SelectContactPage({
    @required this.prompt,
    Key key,
  }) : super(key: key);

  final Widget prompt;

  @override
  Widget build(BuildContext context) {
    double toolbarHeight = MediaQuery.of(context).padding.top;
    List<double> heightsBS = measurementToGoldenRatioBS(
      MediaQuery.of(context).size.height,
    );

    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverPromptSearchHeader(
            heightsBS: heightsBS,
            toolbarHeight: toolbarHeight,
            prompt: prompt,
          ),
          SliverToBoxAdapter(
            child: Text(
              "fsfsdf\n\n\nn\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nsdfdsf",
            ),
          ),
          SliverFillRemaining(
            child: Container(
              color: Colors.red,
              child: Center(
                child: Text("hi"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SliverPromptSearchHeader extends StatelessWidget {
  const SliverPromptSearchHeader({
    Key key,
    @required this.heightsBS,
    @required this.toolbarHeight,
    @required this.prompt,
  }) : super(key: key);

  final List<double> heightsBS;
  final double toolbarHeight;
  final Widget prompt;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
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
      expandedHeight: heightsBS[1] + toolbarHeight,
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
          //StretchMode.blurBackground,

          //we don't have one
          //StretchMode.fadeTitle,

          //zooming doesn't play well the map
          StretchMode.zoomBackground,
        ],
        background: Center(
          child: Padding(
            padding: EdgeInsets.only(
              //from the tool bar
              top: toolbarHeight,
              //from the bottom bar
              bottom: 48,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: prompt,
                  ),
                  FloatingActionButton.extended(
                    heroTag: 'new contact',
                    backgroundColor: Colors.blue,
                    onPressed: () async {
                      //creat the new contact
                      var newContact = await Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.bottomToTop,
                          child: Theme(
                            data: ThemeData.dark(),
                            child: NewContactPage(),
                          ),
                        ),
                      );

                      //if the new contact is indeed created
                      //save it
                      if (newContact != null) {
                        Navigator.of(context).pop(newContact);
                      }
                    },
                    label: Text(
                      "New Contact",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size(
          MediaQuery.of(context).size.width,
          48,
        ),
        child: Container(
          height: 48,
          color: Colors.black,
          child: Theme(
            data: ThemeData.light(),
            child: SearchBox(),
          ),
        ),
      ),
    );
  }
}
