import 'package:flutter2_contact_picker/contact_picker/searchContact/searches.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/helper.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'searchBody.dart';

//TODO: when tapping a suggestion -> scroll to top of list after build completes

//No Recent Searches -> IF no results & no recents
//results -> Name match is default -> X Matching Phone Number(s) -> Y Matching Email(s)
class SearchContactPage extends StatefulWidget {
  //use the passed contacts list, if its passed
  SearchContactPage({
    this.allContacts,
    this.contactIDToColor,
  });

  final ValueNotifier<Map<String, Contact>> allContacts;
  final ValueNotifier<Map<String, Color>> contactIDToColor;

  @override
  _SearchContactPageState createState() => _SearchContactPageState();
}

class _SearchContactPageState extends State<SearchContactPage> {
  //might be reusable from the page that called this, but might not be
  ValueNotifier<Map<String, Contact>> allContactsLocal = ValueNotifier({});
  ValueNotifier<Map<String, Color>> contactIDToColorLocal = ValueNotifier({});

  //specific to this page
  TextEditingController textEditingController = new TextEditingController();
  ValueNotifier<String> refinedSearchString = ValueNotifier("");
  ValueNotifier<List<String>> queryResults = new ValueNotifier([]);
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
    if (query == "" || query.length == 0) {
      queryResults.value = [];
    } else {
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
      queryResults.value = (contactIDsWithMatchingFirstNames +
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

  refineSearchString() {
    if (textEditingController.text == "" ||
        textEditingController.text.length == 0) {
      refinedSearchString.value = "";
    } else {
      refinedSearchString.value = cleanUp(textEditingController.text);
    }
  }

  asyncInit() async {
    if (widget.allContacts != null && widget.contactIDToColor != null) {
      //reuse the passed contact list
      allContactsLocal.value = widget.allContacts.value;

      //reuse the passed contact ID to Color List
      contactIDToColorLocal.value = widget.contactIDToColor.value;
    } else {
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
      contactIDToColorLocal.value = contactIDToColorMap;

      //now that we have BOTH color and contact data, trigger a reload
      allContactsLocal.value = allContactsMap;

      //get all the recent searches here (now that we have the essential contact info)
      await SearchesData.initSearches();

      //grab a little more than the basic info (thumbnails)
      allContactsLocal.value = contactListToMap(
        await ContactsService.getContacts(
          withThumbnails: true, //only thumbnails are required
          photoHighResolution: false,
        ),
      );
    }
  }

  updateLocalAllContacts() {
    allContactsLocal.value = widget.allContacts.value;
  }

  updateLocalContactIDToColor() {
    contactIDToColorLocal.value = widget.contactIDToColor.value;
  }

  @override
  void initState() {
    //super init
    super.initState();

    //try to reuse data when possible
    if (widget.allContacts != null) {
      widget.allContacts.addListener(updateLocalAllContacts);
    }
    if (widget.contactIDToColor != null) {
      widget.contactIDToColor.addListener(updateLocalContactIDToColor);
    }

    //when the local lists change, trigger a reload
    allContactsLocal.addListener(updateState);
    contactIDToColorLocal.addListener(updateState);

    //when the text changes, cascade changes as required
    textEditingController.addListener(refineSearchString);
    refinedSearchString.addListener(newQuery);
    queryResults.addListener(updateState);

    //track when a recent search is added or removed
    SearchesData.searches.addListener(updateState);

    //grab the data if it wasn't grabbed before
    asyncInit();
  }

  @override
  void dispose() {
    if (widget.allContacts != null) {
      widget.allContacts.removeListener(updateLocalAllContacts);
    }
    if (widget.contactIDToColor != null) {
      widget.contactIDToColor.removeListener(updateLocalContactIDToColor);
    }
    allContactsLocal.removeListener(updateState);
    contactIDToColorLocal.removeListener(updateState);
    textEditingController.removeListener(refineSearchString);
    refinedSearchString.removeListener(newQuery);
    queryResults.removeListener(updateState);
    SearchesData.searches.removeListener(updateState);

    //super dipose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
      Widget body;
      if (orientation == Orientation.portrait) {
        print(".\nportrait\n.");
        body = ResultsBodyPortraitMode(
          textEditingController: textEditingController,
          allContacts: allContactsLocal.value,
          contactIDToColor: contactIDToColorLocal.value,
          //first > first names,
          //then > any name with a space in front of it
          //then > any match regardless of spaces
          matchingNameContactIDs: contactIDsWithMatchingFirstNames +
              contactIDsWithMatchingOtherNames +
              contactIDsWithMatchingNames,
          matchingNumberContactIDs: contactIDsWithMatchingNumber,
          matchingEmailContactIDs: contactIDsWithMatchingEmail,
        );
      } else {
        print(".\nlandscape\n.");
        body = ResultsBodyLandscapeMode(
          textEditingController: textEditingController,
          allContacts: allContactsLocal.value,
          contactIDToColor: contactIDToColorLocal.value,
          //first > first names,
          //then > any name with a space in front of it
          //then > any match regardless of spaces
          matchingNameContactIDs: contactIDsWithMatchingFirstNames +
              contactIDsWithMatchingOtherNames +
              contactIDsWithMatchingNames,
          matchingNumberContactIDs: contactIDsWithMatchingNumber,
          matchingEmailContactIDs: contactIDsWithMatchingEmail,
        );
      }

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
                    textEditingController: textEditingController,
                  ),
                  Expanded(
                    child: body,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class SearchBox extends StatelessWidget {
  const SearchBox({
    Key key,
    this.textEditingController,
    this.onTap,
  }) : super(key: key);

  final TextEditingController textEditingController;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'search box',
      child: SizedBox(
        height: 56,
        child: Material(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
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
                child: Stack(
                  children: [
                    TextField(
                      scrollPadding: EdgeInsets.all(0),
                      textInputAction: TextInputAction.search,
                      controller: textEditingController,
                      autofocus: textEditingController != null ? true : false,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(0),
                        border: InputBorder.none,
                        hintText: "Search",
                      ),
                      onEditingComplete: () {
                        if (textEditingController.text != "") {
                          SearchesData.addSearches(textEditingController.text);
                        }
                        FocusScope.of(context).unfocus();
                      },
                    ),
                    textEditingController != null && onTap == null
                        ? SizedBox.shrink()
                        : Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: onTap,
                              child: SizedBox.expand(
                                child: Container(),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              textEditingController != null
                  ? AnimatedBuilder(
                      animation: textEditingController,
                      builder: (context, snapshot) {
                        if (textEditingController.text.length == 0) {
                          return Container();
                        } else {
                          return IconButton(
                            onPressed: () {
                              if (textEditingController.text != "") {
                                textEditingController.text = "";
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
                          );
                        }
                      },
                    )
                  : Padding(
                      padding: EdgeInsets.only(
                        right: 16,
                      ),
                      child: Icon(Icons.search),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultsHeader extends StatelessWidget {
  const ResultsHeader({
    Key key,
    this.resultCount,
    @required this.resultDescription,
  }) : super(key: key);

  final int resultCount;
  final String resultDescription;

  @override
  Widget build(BuildContext context) {
    String title = resultDescription;
    if (resultCount != null) {
      title = resultCount.toString() +
          " " +
          resultDescription +
          (resultCount == 1 ? "" : "s");
    }

    return Container(
      height: 48,
      width: MediaQuery.of(context).size.width,
      color: Colors.black,
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 8,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Text(title),
        ),
      ),
    );
  }
}

class RecentSearch extends StatelessWidget {
  const RecentSearch({
    @required this.recentSearch,
    @required this.textEditingController,
    @required this.isFirstIndex,
    @required this.isLastIndex,
    Key key,
  }) : super(key: key);

  final String recentSearch;
  final TextEditingController textEditingController;
  final bool isFirstIndex;
  final bool isLastIndex;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: Container(color: ThemeData.dark().primaryColor),
              ),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(isFirstIndex ? 16 : 0),
            bottom: Radius.circular(isLastIndex ? 16 : 0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: Colors.grey[300],
                ),
              ),
            ),
            child: ListTile(
              visualDensity: VisualDensity.compact,
              onTap: () {
                //change the text
                textEditingController.text = recentSearch;

                //adjust the selection
                //since setting the value of the text editing controller didn't work
                //and setting the text and then the selection is not good
                //I just wait and then do exactly that to skip whatever makes it not good practice
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  textEditingController.selection = TextSelection.fromPosition(
                    TextPosition(
                      offset: textEditingController.text.length,
                    ),
                  );
                });

                //add to recents
                SearchesData.addSearches(
                  recentSearch,
                );
              },
              title: Text(recentSearch),
              contentPadding: EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
              trailing: IconButton(
                onPressed: () {
                  SearchesData.removeSearch(recentSearch);
                },
                icon: Icon(
                  Icons.close,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
