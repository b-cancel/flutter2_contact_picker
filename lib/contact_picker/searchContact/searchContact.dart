import 'package:contacts_service/contacts_service.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter2_contact_picker/contact_picker/tile/tile.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/helper.dart';

class SearchContactPage extends StatefulWidget {
  //use the passed contacts list, if its passed
  SearchContactPage({
    this.allContacts,
  });

  final ValueNotifier<List<Contact>> allContacts;

  @override
  _SearchContactPageState createState() => _SearchContactPageState();
}

class _SearchContactPageState extends State<SearchContactPage> {
  ValueNotifier<Map<String, Contact>> allContactsLocal = new ValueNotifier({});
  TextEditingController search = new TextEditingController();
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

  query(String rawSearchString) async {
    if (rawSearchString == "") {
      results.value = [];
    } else {
      //optimize the search string
      String searchString = cleanUp(rawSearchString);

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

        if (cleanDisplayName.contains(searchString)) {
          int indexOfMatch = cleanDisplayName.indexOf(searchString);
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
            if (cleanNumber.contains(searchString)) {
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
              if (cleanEmail.contains(searchString)) {
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
  }

  updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  newSearch() {
    query(search.text);
  }

  asyncInit() async {
    //grab the basic info first
    allContactsLocal.value = contactListToMap(
      await ContactsService.getContacts(
        withThumbnails: false,
        photoHighResolution: false,
      ),
    );

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
    search.addListener(newSearch);
    //when the results change, set state
    results.addListener(updateState);
  }

  @override
  void dispose() {
    if (widget.allContacts != null) {
      widget.allContacts.removeListener(updateLocal);
    }
    allContactsLocal.removeListener(updateState);
    search.removeListener(newSearch);
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
                Padding(
                  padding: EdgeInsets.only(
                    top: 8.0,
                  ),
                  child: SearchBox(
                    search: search,
                  ),
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
                            child: Text(results.value.length == 0
                                ? "Type To Search Your Contacts"
                                : ""),
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
                  hintText: "Search",
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
