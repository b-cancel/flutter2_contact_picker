import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/newContact/newContactButton.dart';
import 'package:flutter2_contact_picker/contact_picker/searchContact/searches.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import 'searchComponents.dart';

//same exact thing as below, but
//1. with sticky headers and
//2. with the sticky button at the bottom
class ResultsBodyPortraitMode extends StatelessWidget {
  const ResultsBodyPortraitMode({
    Key key,
    @required this.textEditingController,
    @required this.allContacts,
    @required this.contactIDToColor,
    @required this.matchingNameContactIDs,
    @required this.matchingNumberContactIDs,
    @required this.matchingEmailContactIDs,
  }) : super(key: key);

  final TextEditingController textEditingController;
  final Map<String, Contact> allContacts;
  final Map<String, Color> contactIDToColor;
  final List<String> matchingNameContactIDs;
  final List<String> matchingNumberContactIDs;
  final List<String> matchingEmailContactIDs;

  @override
  Widget build(BuildContext context) {
    List<String> allMatches = matchingNameContactIDs +
        matchingNumberContactIDs +
        matchingEmailContactIDs;

    Widget results;

    if (textEditingController.text.length == 0) {
      if (SearchesData.searches.value.length == 0) {
        //show that a recent searches functionality exists
        results = NoRecentSearches();
      } else {
        //show recents searches
        results = CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverStickyHeader(
              header: RecentSearchesHeader(),
              sliver: RecentSearchesSliver(
                textEditingController: textEditingController,
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: true,
              child: Container(
                color: ThemeData.dark().primaryColor,
              ),
            ),
          ],
        );
      }
    } else {
      if (allMatches.length == 0) {
        results = NoResultsFound();
      } else {
        //names (bottom grey IF phones OR emails exists)
        //phones (bottom grey IF email exists)
        //emails (bottom allways grey)
        bool nameMatchesExist = matchingNameContactIDs.length > 0;
        bool phoneMatchesExist = matchingNumberContactIDs.length > 0;
        bool emailMatchesExist = matchingEmailContactIDs.length > 0;

        bool namesBottomBlack = phoneMatchesExist || emailMatchesExist;
        bool phonesBottomBlack = emailMatchesExist;

        //show the results of the search
        results = CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverStickyHeader(
              header: nameMatchesExist == false
                  ? Container()
                  : MatchingNamesHeader(
                      matchingNameContactIDs: matchingNameContactIDs,
                    ),
              sliver: nameMatchesExist == false
                  ? SliverToBoxAdapter(
                      child: Container(),
                    )
                  : MatchingNamesSliver(
                      matchingNameContactIDs: matchingNameContactIDs,
                      textEditingController: textEditingController,
                      contactIDToColor: contactIDToColor,
                      allContacts: allContacts,
                      namesBottomBlack: namesBottomBlack,
                    ),
            ),
            SliverStickyHeader(
              header: phoneMatchesExist == false
                  ? Container()
                  : MatchingPhonesHeader(
                      matchingNumberContactIDs: matchingNumberContactIDs,
                    ),
              sliver: phoneMatchesExist == false
                  ? SliverToBoxAdapter(
                      child: Container(),
                    )
                  : MatchingPhonesSliver(
                      matchingNumberContactIDs: matchingNumberContactIDs,
                      textEditingController: textEditingController,
                      contactIDToColor: contactIDToColor,
                      allContacts: allContacts,
                      phonesBottomBlack: phonesBottomBlack,
                    ),
            ),
            SliverStickyHeader(
              header: emailMatchesExist == false
                  ? Container()
                  : MatchingEmailsHeader(
                      matchingEmailContactIDs: matchingEmailContactIDs,
                    ),
              sliver: emailMatchesExist == false
                  ? SliverToBoxAdapter(
                      child: Container(),
                    )
                  : MatchingEmailsSliver(
                      matchingEmailContactIDs: matchingEmailContactIDs,
                      textEditingController: textEditingController,
                      contactIDToColor: contactIDToColor,
                      allContacts: allContacts,
                    ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: true,
              child: Container(
                color: ThemeData.dark().primaryColor,
              ),
            ),
          ],
        );
      }
    }

    return Column(
      children: [
        Expanded(
          child: results,
        ),
        Container(
          color: ThemeData.dark().primaryColor,
          padding: EdgeInsets.symmetric(
            vertical: 8,
          ),
          child: FullWidthNewContactButton(),
        ),
      ],
    );
  }
}

//same exact thing as above, but
//1. without sticky headers and
//2. without the sticky button at the bottom
class ResultsBodyLandscapeMode extends StatelessWidget {
  const ResultsBodyLandscapeMode({
    Key key,
    @required this.textEditingController,
    @required this.allContacts,
    @required this.contactIDToColor,
    @required this.matchingNameContactIDs,
    @required this.matchingNumberContactIDs,
    @required this.matchingEmailContactIDs,
  }) : super(key: key);

  final TextEditingController textEditingController;
  final Map<String, Contact> allContacts;
  final Map<String, Color> contactIDToColor;
  final List<String> matchingNameContactIDs;
  final List<String> matchingNumberContactIDs;
  final List<String> matchingEmailContactIDs;

  @override
  Widget build(BuildContext context) {
    List<String> allMatches = matchingNameContactIDs +
        matchingNumberContactIDs +
        matchingEmailContactIDs;

    if (textEditingController.text.length == 0) {
      if (SearchesData.searches.value.length == 0) {
        //show that a recent searches functionality exists
        return MessageToAddContact(
          message: NoRecentSearches(),
        );
      } else {
        //show recents searches
        return CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: RecentSearchesHeader(),
            ),
            RecentSearchesSliver(
              textEditingController: textEditingController,
            ),
            SliverToBoxAdapter(
              child: AddContactOnListBottom(),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: true,
              child: Container(
                color: ThemeData.dark().primaryColor,
              ),
            ),
          ],
        );
      }
    } else {
      if (allMatches.length == 0) {
        return MessageToAddContact(
          message: NoResultsFound(),
        );
      } else {
        //names (bottom grey IF phones OR emails exists)
        //phones (bottom grey IF email exists)
        //emails (bottom allways grey)
        bool nameMatchesExist = matchingNameContactIDs.length > 0;
        bool phoneMatchesExist = matchingNumberContactIDs.length > 0;
        bool emailMatchesExist = matchingEmailContactIDs.length > 0;

        bool namesBottomBlack = phoneMatchesExist || emailMatchesExist;
        bool phonesBottomBlack = emailMatchesExist;

        //show the results of the search
        return CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: nameMatchesExist == false
                  ? Container()
                  : MatchingNamesHeader(
                      matchingNameContactIDs: matchingNameContactIDs,
                    ),
            ),
            nameMatchesExist == false
                ? SliverToBoxAdapter(
                    child: Container(),
                  )
                : MatchingNamesSliver(
                    matchingNameContactIDs: matchingNameContactIDs,
                    textEditingController: textEditingController,
                    contactIDToColor: contactIDToColor,
                    allContacts: allContacts,
                    namesBottomBlack: namesBottomBlack,
                  ),
            SliverToBoxAdapter(
              child: phoneMatchesExist == false
                  ? Container()
                  : MatchingPhonesHeader(
                      matchingNumberContactIDs: matchingNumberContactIDs,
                    ),
            ),
            phoneMatchesExist == false
                ? SliverToBoxAdapter(
                    child: Container(),
                  )
                : MatchingPhonesSliver(
                    matchingNumberContactIDs: matchingNumberContactIDs,
                    textEditingController: textEditingController,
                    contactIDToColor: contactIDToColor,
                    allContacts: allContacts,
                    phonesBottomBlack: phonesBottomBlack,
                  ),
            SliverToBoxAdapter(
              child: emailMatchesExist == false
                  ? Container()
                  : MatchingEmailsHeader(
                      matchingEmailContactIDs: matchingEmailContactIDs,
                    ),
            ),
            emailMatchesExist == false
                ? SliverToBoxAdapter(
                    child: Container(),
                  )
                : MatchingEmailsSliver(
                    matchingEmailContactIDs: matchingEmailContactIDs,
                    textEditingController: textEditingController,
                    contactIDToColor: contactIDToColor,
                    allContacts: allContacts,
                  ),
            SliverToBoxAdapter(
              child: AddContactOnListBottom(),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: true,
              child: Container(
                color: ThemeData.dark().primaryColor,
              ),
            ),
          ],
        );
      }
    }
  }
}

class AddContactOnListBottom extends StatelessWidget {
  const AddContactOnListBottom({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeData.dark().primaryColor,
      padding: EdgeInsets.symmetric(
        vertical: 16,
      ),
      child: FullWidthNewContactButton(),
    );
  }
}

class MessageToAddContact extends StatelessWidget {
  const MessageToAddContact({
    Key key,
    @required this.message,
  }) : super(key: key);

  final Widget message;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          fillOverscroll: true,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 8,
                    ),
                    child: message,
                  ),
                  CollapsedNewContactButton(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
