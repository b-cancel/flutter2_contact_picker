import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/newContact/newContactButton.dart';
import 'package:flutter2_contact_picker/contact_picker/searchContact/searchContact.dart';
import 'package:page_transition/page_transition.dart';

class SliverPromptSearchHeader extends StatelessWidget {
  const SliverPromptSearchHeader({
    Key key,
    @required this.allContacts,
    @required this.contactIDToColor,
    @required this.expandedBannerHeight,
    @required this.bottomAppBarHeight,
    @required this.toolbarHeight,
    @required this.prompt,
  }) : super(key: key);

  final ValueNotifier<Map<String, Contact>> allContacts;
  final ValueNotifier<Map<String, Color>> contactIDToColor;
  final double expandedBannerHeight;
  final double bottomAppBarHeight;
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
      leading: null,
      title: null,
      actions: null,
      primary: true,
      //only show shadow if content below
      forceElevated: false,
      //snapping is annoying and disorienting
      //but the opposite is ugly
      snap: false,
      pinned: true, //so the [bottom] parameter allways shows
      //might make it open in annoying times (so we turn it off)
      floating: false,
      //most of the screen
      expandedHeight: expandedBannerHeight,
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
            //+8 is a little extra for when things are tighter
            padding: EdgeInsets.only(
              //from the tool bar
              top: toolbarHeight + 8.0,
              //from the bottom bar
              bottom: bottomAppBarHeight + 8.0,
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: prompt,
                    ),
                    Center(
                      child: CollapsedNewContactButton(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size(
          MediaQuery.of(context).size.width,
          0,
        ),
        child: Container(
          height: bottomAppBarHeight,
          color: Colors.black,
          child: Theme(
            data: ThemeData.light(),
            child: SearchBox(
              onTap: () async {
                //creat the new contact
                var newContact = await Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.bottomToTop,
                    child: Theme(
                      data: ThemeData.dark(),
                      child: SearchContactPage(
                        allContacts: allContacts,
                        contactIDToColor: contactIDToColor,
                      ),
                    ),
                  ),
                );

                //if the new contact is indeed created
                //save it
                if (newContact != null) {
                  Navigator.of(context).pop(newContact);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
