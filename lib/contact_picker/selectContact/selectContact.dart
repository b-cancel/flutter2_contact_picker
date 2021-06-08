import 'package:contacts_service/contacts_service.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/searchContact/searchContact.dart';
import 'package:flutter2_contact_picker/contact_picker/searchContact/searches.dart';
import 'package:flutter2_contact_picker/contact_picker/selectContact/recents.dart';
import 'package:flutter2_contact_picker/contact_picker/selectContact/scrollToTop.dart';
import 'package:flutter2_contact_picker/contact_picker/tile/tile.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/goldenRatio.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/helper.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import 'header.dart';
import 'scrollBar/scrollBar.dart';

class SelectContactPage extends StatefulWidget {
  const SelectContactPage({
    @required this.verticalPrompt,
    @required this.horizontalPrompt,
    Key key,
  }) : super(key: key);

  final Widget verticalPrompt;
  final Widget horizontalPrompt;

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

  //since this also includes recents, whenever this changes we should also reload
  ValueNotifier<Map<String, List<String>>> keyToContactIDs = ValueNotifier({});

  ScrollController scrollController = ScrollController();

  generateSections() async {
    //grab the recents from the file
    await RecentsData.initRecents();

    //assemble everything in one hit before moving forward
    Map<String, List<String>> keyToContactIDsLocal = {};

    //create a reference to recents
    List<String> recentContactIDs = RecentsData.recents.value;
    if (recentContactIDs.length > 0) {
      keyToContactIDsLocal["*"] = recentContactIDs;
    }

    //go through all of our contacts and sort accordingly
    for (String contactID in allContacts.value.keys) {
      Contact thisContact = allContacts.value[contactID];
      String firstLetter = removeDiacritics(
        thisContact.displayName.toUpperCase()[0],
      );
      int firstLetterAsciiCode = firstLetter.codeUnitAt(0);
      String contactIDKey;
      if (65 <= firstLetterAsciiCode && firstLetterAsciiCode <= 90) {
        //add to normal letter section
        contactIDKey = firstLetter;
      } else {
        //add to special section
        contactIDKey = "#";
      }

      //add this contact ID to it's expected section
      if (keyToContactIDsLocal.containsKey(contactIDKey) == false) {
        keyToContactIDsLocal[contactIDKey] = [];
      }
      keyToContactIDsLocal[contactIDKey].add(contactID);
    }

    //make sure all the #, are at the very end
    if (keyToContactIDsLocal.containsKey("#")) {
      List<String> specialContactIDs = keyToContactIDsLocal["#"];
      keyToContactIDsLocal.remove("#");
      keyToContactIDsLocal["#"] = specialContactIDs;
    }

    //update things globally to trigger a reload
    keyToContactIDs.value = keyToContactIDsLocal;
  }

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

    await generateSections();

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
    keyToContactIDs.addListener(updateState);
    super.initState();
  }

  @override
  void dispose() {
    contactsRead.removeListener(updateState);
    allContacts.removeListener(updateState);
    keyToContactIDs.removeListener(updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double toolbarHeight = MediaQuery.of(context).padding.top;
    List<double> heightsBS = measurementToGoldenRatioBS(
      MediaQuery.of(context).size.height,
    );
    double expandedBannerHeight = heightsBS[1] + toolbarHeight;
    double bottomAppBarHeight = 56;

    //actually build
    return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
      double scrollToTopButtonPadding = 8;

      //add first sliver
      List<Widget> slivers = [];
      slivers.add(
        SliverPromptSearchHeader(
          expandedBannerHeight: expandedBannerHeight,
          bottomAppBarHeight: bottomAppBarHeight,
          toolbarHeight: toolbarHeight,
          prompt: orientation == Orientation.portrait
              ? widget.verticalPrompt
              : widget.horizontalPrompt,
          allContacts: allContacts,
          contactIDToColor: contactIDToColor,
        ),
      );

      //compile all the slivers based on our section information
      for (String sectionKey in keyToContactIDs.value.keys) {
        //create the section
        Widget section = createSectionForKey(sectionKey);

        //add the section
        slivers.add(
          section,
        );
      }

      //add last sliver
      slivers.add(
        SliverFillRemaining(
          child: Container(
            color: ThemeData.dark().primaryColor,
            //48 for mini FAB
            height: 48 + (scrollToTopButtonPadding * 2),
          ),
        ),
      );

      //build everything
      return Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              controller: scrollController,
              physics: BouncingScrollPhysics(),
              slivers: slivers,
            ),
            ScrollBar(
              scrollController: scrollController,
              expandedBannerHeight: expandedBannerHeight,
              //56 REGARDLESS OF SIZE OF ACTUAL BOTTOM APP BAR
              bottomAppBarHeight: 56,
              toolbarHeight: toolbarHeight,
            ),
            ScrollToTopButton(
              scrollController: scrollController,
              padding: scrollToTopButtonPadding,
            ),
          ],
        ),
      );
    });
  }

  Widget createSectionForKey(String sectionKey) {
    //! We know this list isn't empty
    List<String> contactIDsInSection = keyToContactIDs.value[sectionKey];

    //process key
    String sectionTitle = sectionKey;
    if (sectionKey == "*" || sectionKey == "#") {
      if (sectionKey == "*") {
        sectionTitle = "Recents";
      } else {
        sectionTitle = "Other";
      }
    }

    //return section
    return SliverStickyHeader(
      header: ResultsHeader(
        resultDescription: sectionTitle,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            String contactID = contactIDsInSection[index];
            return ContactTile(
              onTap: () {
                //save as a successfull search term
                RecentsData.addRecent(
                  contactID,
                );

                //return contact ID
                Navigator.of(context).pop(contactID);
              },
              iconColor: contactIDToColor.value[contactID],
              contact: allContacts.value[contactID],
              isFirst: index == 0,
              isLast: index == (contactIDsInSection.length - 1),
              bottomBlack: sectionExistsUnderThisSection(
                  sectionKey), //TODO: eventually edit this
              //TODO: add on remove call back
            );
          },
          childCount: contactIDsInSection.length,
        ),
      ),
    );
  }

  sectionExistsUnderThisSection(String sectionKey) {
    if (sectionKey == "#") {
      return false;
    } else {
      if (sectionKey == "*") {
        if (keyToContactIDs.value.length > 1) {
          //atleast 2 sections exist, one of which is us
          return true;
        } else {
          return false;
        }
      } else {
        if (sectionKey == "Z") {
          if (sectionKey == "#") {
            //an other section exists
            return true;
          } else {
            //we are the last section since no other section exist
            return false;
          }
        } else {
          //Letters A -> Y... keep checking for if the next letter exist...
          //if still can't even find Z... check for #
          //TODO: combine with code above
          return true; //TODO: good enough for now
        }
      }
    }
  }
}
