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
import 'package:flutter2_contact_picker/contact_picker/utils/permissions/ask.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:permission_handler/permission_handler.dart';

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
    //double check before using the service
    if (await doubleCheckPermission(
          context,
          permission: Permission.contacts,
          permissionName: 'contacts',
        ) ==
        false) {
      Navigator.of(context).pop();
    }

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

    //double check before using the service
    if (await doubleCheckPermission(
          context,
          permission: Permission.contacts,
          permissionName: 'contacts',
        ) ==
        false) {
      Navigator.of(context).pop();
    }

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
    RecentsData.recents.addListener(updateState);
    super.initState();
  }

  @override
  void dispose() {
    contactsRead.removeListener(updateState);
    allContacts.removeListener(updateState);
    keyToContactIDs.removeListener(updateState);
    RecentsData.recents.removeListener(updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    generateSections();

    double toolbarHeight = MediaQuery.of(context).padding.top;
    List<double> heightsBS = measurementToGoldenRatioBS(
      MediaQuery.of(context).size.height,
    );
    double expandedBannerHeight = heightsBS[1] + toolbarHeight;
    double bottomAppBarHeight = 56;

    //actually build
    return OrientationBuilder(builder: (
      BuildContext context,
      Orientation orientation,
    ) {
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

      bool sectionsExist = keyToContactIDs.value.length > 0;
      if (sectionsExist) {
        //compile all the slivers based on our section information
        for (String sectionKey in keyToContactIDs.value.keys) {
          slivers.add(
            KeySection(
              sectionKey: sectionKey,
              allContacts: allContacts,
              contactIDToColor: contactIDToColor,
              keyToContactIDs: keyToContactIDs,
            ),
          );
        }

        //add last sliver
        slivers.add(
          SliverFillRemaining(
            hasScrollBody: false,
            fillOverscroll: true,
            child: Container(
              //48 for mini FAB
              //atleast this size
              height: 48 + (scrollToTopButtonPadding * 2),
            ),
          ),
        );
      } else {
        //show different empty states
        Widget explainWhyEmpty =
            contactsRead.value ? Text("No Contacts Found") : Text("Loading...");

        //nothing else to show, fill remaining
        slivers.add(
          SliverFillRemaining(
            hasScrollBody: false,
            fillOverscroll: true,
            child: Center(
              child: explainWhyEmpty,
            ),
          ),
        );
      }

      //build everything
      return Scaffold(
        backgroundColor: ThemeData.dark().primaryColor,
        body: Stack(
          children: [
            CustomScrollView(
              controller: scrollController,
              physics: BouncingScrollPhysics(),
              slivers: slivers,
            ),
            Visibility(
              visible: sectionsExist,
              child: ScrollBar(
                scrollController: scrollController,
                expandedBannerHeight: expandedBannerHeight,
                //56 REGARDLESS OF SIZE OF ACTUAL BOTTOM APP BAR
                bottomAppBarHeight: 56,
                toolbarHeight: toolbarHeight,
              ),
            ),
            Visibility(
              visible: sectionsExist,
              child: ScrollToTopButton(
                scrollController: scrollController,
                padding: scrollToTopButtonPadding,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class KeySection extends StatelessWidget {
  const KeySection({
    Key key,
    @required this.sectionKey,
    @required this.allContacts,
    @required this.contactIDToColor,
    @required this.keyToContactIDs,
  }) : super(key: key);

  final String sectionKey;
  final ValueNotifier<Map<String, Contact>> allContacts;
  final ValueNotifier<Map<String, Color>> contactIDToColor;
  final ValueNotifier<Map<String, List<String>>> keyToContactIDs;

  @override
  Widget build(BuildContext context) {
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
          (BuildContext context, int rawIndex) {
            int index = rawIndex;

            //invert the indices for the recents section
            //most recently added stuff on top
            if (sectionKey == "*") {
              index = (contactIDsInSection.length - 1) - rawIndex;
            }

            //gather the information
            String contactID = contactIDsInSection[index];
            Contact thisContact = allContacts.value[contactID];
            bool sectionBottomIsBlack = sectionExistsUnderThisSection(
              sectionKey,
            );

            //build
            return ContactTile(
              onTap: () {
                //save as a successfull search term
                RecentsData.addRecent(
                  contactID,
                );

                //return contact ID
                Navigator.of(context).pop(thisContact);
              },
              iconColor: contactIDToColor.value[contactID],
              contact: thisContact,
              isFirst: rawIndex == 0,
              isLast: rawIndex == (contactIDsInSection.length - 1),
              bottomBlack: sectionBottomIsBlack,
              //extra spacing on icons given scroll bar
              inContactSelector: true,
              onRemove: sectionKey != "*"
                  ? null
                  : () {
                      //remove the recent
                      RecentsData.removeRecent(
                        contactID,
                      );

                      //this will trigger a reload
                      //and remove it visually
                    },
            );
          },
          childCount: contactIDsInSection.length,
        ),
      ),
    );
  }

  bool sectionExistsUnderThisLetterSection(String letterSectionKey) {
    if (letterSectionKey == "Z") {
      if (keyToContactIDs.value.containsKey("#")) {
        return true;
      } else {
        return false;
      }
    } else {
      //we are any letter A through Y

      //EX: we are section a... looking for the next section
      //section b doesn't exist... so move onto the next letter
      int nextSectionKeyCode = letterSectionKey.codeUnitAt(0);
      String nextSectionKey = String.fromCharCode(nextSectionKeyCode + 1);

      //if our next section exist horray... else recurse
      if (keyToContactIDs.value.containsKey(nextSectionKey)) {
        return true;
      } else {
        return sectionExistsUnderThisLetterSection(nextSectionKey);
      }
    }
  }

  bool sectionExistsUnderThisSection(String sectionKey) {
    //nothing is under this section
    if (sectionKey == "#") {
      return false;
    } else {
      //its very likely things are under this section
      if (sectionKey == "*") {
        //only 2 sections have to exist...
        //the * section... and another other section
        if (keyToContactIDs.value.length > 1) {
          return true;
        } else {
          return false;
        }
      } else {
        //we are starting for a letter,
        //check if the next letter section exists
        //or keep moving to the next letter
        return sectionExistsUnderThisLetterSection(sectionKey);
      }
    }
  }
}
