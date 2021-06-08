import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/searchContact/searches.dart';
import 'package:flutter2_contact_picker/contact_picker/tile/tile.dart';

import 'searchContact.dart';

class MatchingEmailsSliver extends StatelessWidget {
  const MatchingEmailsSliver({
    Key key,
    @required this.matchingEmailContactIDs,
    @required this.textEditingController,
    @required this.contactIDToColor,
    @required this.allContacts,
  }) : super(key: key);

  final List<String> matchingEmailContactIDs;
  final TextEditingController textEditingController;
  final Map<String, Color> contactIDToColor;
  final Map<String, Contact> allContacts;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          String contactID = matchingEmailContactIDs[index];
          return ContactTile(
            onTap: () {
              //save as a successfull search term
              SearchesData.addSearches(textEditingController.text);

              //return contact ID
              Navigator.of(context).pop(contactID);
            },
            iconColor: contactIDToColor[contactID],
            contact: allContacts[contactID],
            isFirst: index == 0,
            isLast: index == (matchingEmailContactIDs.length - 1),
            highlightPhone: false,
            highlightEmail: true,
          );
        },
        childCount: matchingEmailContactIDs.length,
      ),
    );
  }
}

class MatchingEmailsHeader extends StatelessWidget {
  const MatchingEmailsHeader({
    Key key,
    @required this.matchingEmailContactIDs,
  }) : super(key: key);

  final List<String> matchingEmailContactIDs;

  @override
  Widget build(BuildContext context) {
    return ResultsHeader(
      resultCount: matchingEmailContactIDs.length,
      resultDescription: "Matching Email",
    );
  }
}

class MatchingPhonesSliver extends StatelessWidget {
  const MatchingPhonesSliver({
    Key key,
    @required this.matchingNumberContactIDs,
    @required this.textEditingController,
    @required this.contactIDToColor,
    @required this.allContacts,
    @required this.phonesBottomBlack,
  }) : super(key: key);

  final List<String> matchingNumberContactIDs;
  final TextEditingController textEditingController;
  final Map<String, Color> contactIDToColor;
  final Map<String, Contact> allContacts;
  final bool phonesBottomBlack;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          String contactID = matchingNumberContactIDs[index];
          return ContactTile(
            onTap: () {
              //save as a successfull search term
              SearchesData.addSearches(textEditingController.text);

              //return contact ID
              Navigator.of(context).pop(contactID);
            },
            iconColor: contactIDToColor[contactID],
            contact: allContacts[contactID],
            isFirst: index == 0,
            isLast: index == (matchingNumberContactIDs.length - 1),
            highlightPhone: true,
            highlightEmail: false,
            bottomBlack: phonesBottomBlack,
          );
        },
        childCount: matchingNumberContactIDs.length,
      ),
    );
  }
}

class MatchingPhonesHeader extends StatelessWidget {
  const MatchingPhonesHeader({
    Key key,
    @required this.matchingNumberContactIDs,
  }) : super(key: key);

  final List<String> matchingNumberContactIDs;

  @override
  Widget build(BuildContext context) {
    return ResultsHeader(
      resultCount: matchingNumberContactIDs.length,
      resultDescription: "Matching Phone Number",
    );
  }
}

class MatchingNamesSliver extends StatelessWidget {
  const MatchingNamesSliver({
    Key key,
    @required this.matchingNameContactIDs,
    @required this.textEditingController,
    @required this.contactIDToColor,
    @required this.allContacts,
    @required this.namesBottomBlack,
  }) : super(key: key);

  final List<String> matchingNameContactIDs;
  final TextEditingController textEditingController;
  final Map<String, Color> contactIDToColor;
  final Map<String, Contact> allContacts;
  final bool namesBottomBlack;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          String contactID = matchingNameContactIDs[index];
          return ContactTile(
            onTap: () {
              //save as a successfull search term
              SearchesData.addSearches(
                textEditingController.text,
              );

              //return contact ID
              Navigator.of(context).pop(contactID);
            },
            iconColor: contactIDToColor[contactID],
            contact: allContacts[contactID],
            isFirst: index == 0,
            isLast: index == (matchingNameContactIDs.length - 1),
            highlightPhone: false,
            highlightEmail: false,
            bottomBlack: namesBottomBlack,
          );
        },
        childCount: matchingNameContactIDs.length,
      ),
    );
  }
}

class MatchingNamesHeader extends StatelessWidget {
  const MatchingNamesHeader({
    Key key,
    @required this.matchingNameContactIDs,
  }) : super(key: key);

  final List<String> matchingNameContactIDs;

  @override
  Widget build(BuildContext context) {
    return ResultsHeader(
      resultCount: matchingNameContactIDs.length,
      resultDescription: "Matching Name",
    );
  }
}

class NoResultsFound extends StatelessWidget {
  const NoResultsFound({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Text("No Results Found"),
      ),
    );
  }
}

class RecentSearchesSliver extends StatelessWidget {
  const RecentSearchesSliver({
    Key key,
    @required this.textEditingController,
  }) : super(key: key);

  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int invertedIndex) {
          int lastIndex = (SearchesData.searches.value.length - 1);
          int index = lastIndex - invertedIndex;
          String searchTerm = SearchesData.searches.value[index];
          return RecentSearch(
            recentSearch: searchTerm,
            textEditingController: textEditingController,
            isFirstIndex: invertedIndex == 0,
            isLastIndex: invertedIndex == lastIndex,
          );
        },
        childCount: SearchesData.searches.value.length,
      ),
    );
  }
}

class RecentSearchesHeader extends StatelessWidget {
  const RecentSearchesHeader({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResultsHeader(
      resultDescription: "Recent Searches",
    );
  }
}

class NoRecentSearches extends StatelessWidget {
  const NoRecentSearches({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Text("No Recent Searches"),
      ),
    );
  }
}
