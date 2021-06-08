import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/newContact/newContactButton.dart';
import 'package:flutter2_contact_picker/contact_picker/searchContact/searchContact.dart';
import 'package:flutter2_contact_picker/contact_picker/searchContact/searches.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/goldenRatio.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/helper.dart';
import 'package:page_transition/page_transition.dart';

class SelectContactPage extends StatefulWidget {
  const SelectContactPage({
    @required this.prompt,
    Key key,
  }) : super(key: key);

  final Widget prompt;

  @override
  _SelectContactPageState createState() => _SelectContactPageState();
}

class _SelectContactPageState extends State<SelectContactPage> {
  //false to true => MIGHT be => loading to no contacts available (must trigger reload)
  ValueNotifier<bool> contactsRead = ValueNotifier(false);
  //if this changes there is a new contact list (must trigger reload)
  //! Since this map is created directly from a list of contacts, the keys are always order
  ValueNotifier<Map<String, Contact>> allContacts = ValueNotifier({});
  //this only changes if allContacts Changes first (DOES NOT trigger reload)
  ValueNotifier<Map<String, Color>> contactIDToColor = ValueNotifier({});

  readInContacts() async {
    //grab the basic info first
    Map<String, Contact> allContactsMap = contactListToMap(
      await ContactsService.getContacts(
        withThumbnails: false,
        photoHighResolution: false,
      ),
    );

    //generate the colors
    Map<String, Color> contactIDToColorMap = {};
    for (String contactID in allContactsMap.keys) {
      contactIDToColorMap[contactID] = getRandomDarkBlueOrGreyColor();
    }
    contactIDToColor.value = contactIDToColorMap;

    //now that we have BOTH color and contact data, trigger a reload
    allContacts.value = allContactsMap;

    //mark the contacts as read,
    //so that we can distinguish when there are no contacts
    //VS when we just haven't read them yet
    contactsRead.value = true;

    //get all the recent searches here (now that we have the essential contact info)
    await SearchesData.initSearches();

    //grab a little more than the basic info (thumbnails)
    allContacts.value = contactListToMap(
      await ContactsService.getContacts(
        withThumbnails: true, //only thumbnails are required
        photoHighResolution: false,
      ),
    );
  }

  updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    readInContacts();
    contactsRead.addListener(updateState);
    allContacts.addListener(updateState);
    super.initState();
  }

  @override
  void dispose() {
    contactsRead.removeListener(updateState);
    allContacts.removeListener(updateState);
    super.dispose();
  }

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
            prompt: widget.prompt,
            allContacts: allContacts,
            contactIDToColor: contactIDToColor,
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
    @required this.allContacts,
    @required this.contactIDToColor,
  }) : super(key: key);

  final ValueNotifier<Map<String, Contact>> allContacts;
  final ValueNotifier<Map<String, Color>> contactIDToColor;
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
                  Center(
                    child: CollapsedNewContactButton(),
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
