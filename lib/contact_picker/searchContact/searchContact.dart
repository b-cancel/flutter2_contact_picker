import 'package:contacts_service/contacts_service.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter2_contact_picker/contact_picker/tile/tile.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/helper.dart';

//No Recent Searches -> IF no results & no recents
//results -> Name match is default -> X Matching Phone Number(s) -> Y Matching Email(s)
class SearchContactPage extends StatefulWidget {
  //use the passed contacts list, if its passed
  SearchContactPage({
    this.allContacts,
    this.contactIDToColor,
  });

  final ValueNotifier<List<Contact>> allContacts;
  final Map<String, Color> contactIDToColor;

  @override
  _SearchContactPageState createState() => _SearchContactPageState();
}

class _SearchContactPageState extends State<SearchContactPage> {
  ValueNotifier<Map<String, Contact>> allContactsLocal = new ValueNotifier({});
  Map<String, Color> contactIDToColorLocal = {};
  TextEditingController searchString = new TextEditingController();
  ValueNotifier<String> refinedSearchString = ValueNotifier("");
  ValueNotifier<List<String>> results = new ValueNotifier([]);
  List<String> contactIDsWithMatchingFirstNames = [];
  List<String> contactIDsWithMatchingOtherNames = [];
  List<String> contactIDsWithMatchingNames = [];
  List<String> contactIDsWithMatchingNumber = [];
  List<String> contactIDsWithMatchingEmail = [];

  cleanUp(String dirty) {
    //to lower
    String clean = dirty.toLowerCase();
    //remove diacritics
    clean = removeDiacritics(clean);
    //remove white space
    clean = clean.split(RegExp('\\s')).join('');
    //remove special characters (for phone number searching)
    clean = clean.split(RegExp('\\(')).join('');
    clean = clean.split(RegExp('\\)')).join('');
    clean = clean.split(RegExp('\\-')).join('');
    //return
    return clean;
  }

  newQuery() async {
    String query = refinedSearchString.value;

    //we try and find exact matches for all of these
    //a single contact ID should only be in one of the 2 lists
    contactIDsWithMatchingFirstNames = [];
    contactIDsWithMatchingOtherNames = [];
    contactIDsWithMatchingNames = [];
    contactIDsWithMatchingNumber = [];
    contactIDsWithMatchingEmail = [];

    //loop through all the contacts and query
    for (String contactID in allContactsLocal.value.keys) {
      Contact thisContact = allContactsLocal.value[contactID];
      String cleanDisplayName = cleanUp(thisContact.displayName);

      if (cleanDisplayName.contains(query)) {
        int indexOfMatch = cleanDisplayName.indexOf(query);
        if (indexOfMatch == 0) {
          contactIDsWithMatchingFirstNames.add(contactID);
        } else if ((cleanDisplayName[indexOfMatch - 1]).trim().length == 0) {
          contactIDsWithMatchingOtherNames.add(contactID);
        } else {
          contactIDsWithMatchingNames.add(contactID);
        }
      } else {
        //if the search query looks like ANY of the numbers this particular contact has
        List<Item> numbers = thisContact.phones.toList();
        bool addToNumbers = false;
        for (Item number in numbers) {
          String cleanNumber = cleanUp(number.value);
          if (cleanNumber.contains(query)) {
            addToNumbers = true;
            break;
          }
        }

        //we found a matching number
        if (addToNumbers) {
          contactIDsWithMatchingNumber.add(contactID);
        } else {
          //if the search query looks like ANY of the emails this particular contact has
          List<Item> emails = thisContact.emails.toList();
          bool addToEmails = false;
          for (Item email in emails) {
            String cleanEmail = cleanUp(email.value);
            if (cleanEmail.contains(query)) {
              addToEmails = true;
              break;
            }
          }

          if (addToEmails) {
            contactIDsWithMatchingEmail.add(contactID);
          }
        }
      }
    }

    //compile all the results
    results.value = (contactIDsWithMatchingFirstNames +
        contactIDsWithMatchingOtherNames +
        contactIDsWithMatchingNames +
        contactIDsWithMatchingNumber +
        contactIDsWithMatchingEmail);
  }

  updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  newRawSearchString() {
    if (searchString.text == "") {
      refinedSearchString.value = "";
    } else {
      refinedSearchString.value = cleanUp(searchString.text);
    }
  }

  asyncInit() async {
    //grab the basic info first
    allContactsLocal.value = contactListToMap(
      await ContactsService.getContacts(
        withThumbnails: false,
        photoHighResolution: false,
      ),
    );

    //generate the colors
    for (String contactID in allContactsLocal.value.keys) {
      contactIDToColorLocal[contactID] = getRandomDarkBlueOrGreyColor();
    }

    //grab a little more than the basic info (thumbnails)
    allContactsLocal.value = contactListToMap(
      await ContactsService.getContacts(
        withThumbnails: true,
        photoHighResolution: false,
      ),
    );
  }

  updateLocal() {
    allContactsLocal.value = contactListToMap(
      widget.allContacts.value,
    );
  }

  @override
  void initState() {
    //super init
    super.initState();

    //grab the data if it wasn't grabbed before
    if (widget.allContacts != null) {
      updateLocal();
      contactIDToColorLocal = widget.contactIDToColor;
    } else {
      asyncInit();
    }

    //listen to contact list changes if they occur
    if (widget.allContacts != null) {
      widget.allContacts.addListener(updateLocal);
    }
    //if our local contact list changes, update state
    allContactsLocal.addListener(updateState);
    //when the search query run, compile a new set of results
    searchString.addListener(newRawSearchString);
    refinedSearchString.addListener(newQuery);
    //when the results change, set state
    results.addListener(updateState);
  }

  @override
  void dispose() {
    if (widget.allContacts != null) {
      widget.allContacts.removeListener(updateLocal);
    }
    allContactsLocal.removeListener(updateState);
    searchString.removeListener(newRawSearchString);
    refinedSearchString.removeListener(newQuery);
    results.removeListener(updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //name matching is obvious, no need to highlight it
    //but phone and email, not so much

    //all the different
    Set matchingNumberContactIDs = contactIDsWithMatchingNumber.toSet();
    Set matchingEmailContactIDs = contactIDsWithMatchingEmail.toSet();

    //build
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Theme(
          data: ThemeData.light(),
          child: Container(
            color: Colors.black,
            child: Column(
              children: <Widget>[
                SearchBox(
                  search: searchString,
                ),
                ResultsHeader(
                  results: results,
                ),
                Expanded(
                  child: CustomScrollView(
                    physics: BouncingScrollPhysics(),
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            String contactID = results.value[index];
                            return ContactTile(
                              iconColor: contactIDToColorLocal[contactID],
                              contact: allContactsLocal.value[contactID],
                              isFirst: index == 0,
                              isLast: index == (results.value.length - 1),
                              highlightPhone:
                                  matchingNumberContactIDs.contains(contactID),
                              highlightEmail:
                                  matchingEmailContactIDs.contains(contactID),
                            );
                          },
                          childCount: results.value.length,
                        ),
                      ),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        fillOverscroll: true,
                        child: Container(
                          color: (results.value.length == 0)
                              ? Colors.black
                              : ThemeData.dark().primaryColor,
                          child: Center(
                            child: Text(results.value.length == 0 ? "" : ""),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchBox extends StatelessWidget {
  const SearchBox({
    Key key,
    @required this.search,
  }) : super(key: key);

  final TextEditingController search;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: Colors.black,
              icon: Icon(
                Icons.keyboard_arrow_left,
              ),
            ),
            Flexible(
              child: TextField(
                scrollPadding: EdgeInsets.all(0),
                textInputAction: TextInputAction.search,
                controller: search,
                autofocus: true,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(0),
                  border: InputBorder.none,
                  hintText: "Type To Search",
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                if (search.text != "") {
                  search.text = "";
                } else {
                  Navigator.of(context).pop();
                }
              },
              icon: Transform.rotate(
                angle: -math.pi / 4,
                child: Icon(
                  Icons.add,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultsHeader extends StatelessWidget {
  const ResultsHeader({
    Key key,
    @required this.results,
  }) : super(key: key);

  final ValueNotifier<List<String>> results;

  @override
  Widget build(BuildContext context) {
    if (results.value.length == 0) {
      return Container();
    } else {
      return Container(
        height: 48,
        width: MediaQuery.of(context).size.width,
        color: Colors.black,
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: 8,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  "Contacts",
                ),
                AnimatedBuilder(
                  animation: results,
                  builder: (context, snapshot) {
                    return Text(
                      results.value.length.toString() + " Found",
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
