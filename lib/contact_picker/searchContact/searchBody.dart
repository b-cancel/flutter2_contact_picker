import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import '../../contact_picker/newContact/newContactButton.dart';
import '../../contact_picker/searchContact/searches.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import 'searchComponents.dart';

class ResultsBody extends StatelessWidget {
  const ResultsBody({
    Key key,
    @required this.textEditingController,
    @required this.allContacts,
    @required this.contactIDToColor,
    @required this.matchingNameContactIDs,
    @required this.matchingNumberContactIDs,
    @required this.matchingEmailContactIDs,
    //other
    @required this.portraitMode,
    @required this.scrollController,
  }) : super(key: key);

  final TextEditingController textEditingController;
  final Map<String, Contact> allContacts;
  final Map<String, Color> contactIDToColor;
  final List<String> matchingNameContactIDs;
  final List<String> matchingNumberContactIDs;
  final List<String> matchingEmailContactIDs;
  //other
  final bool portraitMode;
  final ScrollController scrollController;

  List<Widget> getOrientationSlivers(
    Widget header,
    Widget sliverBody,
  ) {
    List<Widget> slivers = [];
    if (portraitMode) {
      slivers.add(
        SliverStickyHeader(
          header: header,
          sliver: sliverBody,
        ),
      );
    } else {
      slivers.add(
        SliverToBoxAdapter(
          child: header,
        ),
      );

      slivers.add(
        sliverBody,
      );
    }
    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    //compile all the matches
    List<String> allMatches = matchingNameContactIDs +
        matchingNumberContactIDs +
        matchingEmailContactIDs;

    //compile all the slivers
    List<Widget> slivers = [];

    //scroll to the top of this NEW list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(0);
    });

    //handle all the special list related stuff
    if (textEditingController.text.length == 0) {
      if (SearchesData.searches.value.length == 0) {
        //show that a recent searches functionality exists
        slivers.add(
          MessageToAddContact(
            message: NoRecentSearches(),
          ),
        );
      } else {
        //show recents searches
        slivers.addAll(
          getOrientationSlivers(
            RecentSearchesHeader(),
            RecentSearchesSliver(
              textEditingController: textEditingController,
            ),
          ),
        );
      }
    } else {
      if (allMatches.length == 0) {
        slivers.add(
          MessageToAddContact(
            message: NoResultsFound(),
          ),
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

        //handle name matches
        if (nameMatchesExist) {
          slivers.addAll(
            getOrientationSlivers(
              MatchingNamesHeader(
                matchingNameContactIDs: matchingNameContactIDs,
              ),
              MatchingNamesSliver(
                matchingNameContactIDs: matchingNameContactIDs,
                textEditingController: textEditingController,
                contactIDToColor: contactIDToColor,
                allContacts: allContacts,
                namesBottomBlack: namesBottomBlack,
              ),
            ),
          );
        }

        //handle number matches
        if (phoneMatchesExist) {
          slivers.addAll(
            getOrientationSlivers(
              MatchingPhonesHeader(
                matchingNumberContactIDs: matchingNumberContactIDs,
              ),
              MatchingPhonesSliver(
                matchingNumberContactIDs: matchingNumberContactIDs,
                textEditingController: textEditingController,
                contactIDToColor: contactIDToColor,
                allContacts: allContacts,
                phonesBottomBlack: phonesBottomBlack,
              ),
            ),
          );
        }

        //handle email matches
        if (emailMatchesExist) {
          slivers.addAll(
            getOrientationSlivers(
              MatchingEmailsHeader(
                matchingEmailContactIDs: matchingEmailContactIDs,
              ),
              MatchingEmailsSliver(
                matchingEmailContactIDs: matchingEmailContactIDs,
                textEditingController: textEditingController,
                contactIDToColor: contactIDToColor,
                allContacts: allContacts,
              ),
            ),
          );
        }
      }
    }

    //add the full width button where it makes sense
    bool hasRecents = textEditingController.text.length == 0 &&
        SearchesData.searches.value.length > 0;
    bool hasResults =
        textEditingController.text.length > 0 && allMatches.length > 0;
    if (hasRecents || hasResults) {
      slivers.add(
        SliverToBoxAdapter(
          child: AddContactOnListBottom(),
        ),
      );

      slivers.add(
        SliverFillRemaining(
          hasScrollBody: false,
          fillOverscroll: true,
          child: Container(
            color: ThemeData.dark().primaryColor,
          ),
        ),
      );
    }

    //return the list with whatever new slivers it has now
    return CustomScrollView(
      controller: scrollController,
      physics: BouncingScrollPhysics(),
      slivers: slivers,
    );
  }
}

class AddContactOnListBottom extends StatelessWidget {
  const AddContactOnListBottom({
    Key key,
  }) : super(key: key);

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
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 16,
          ),
          child: FullWidthNewContactButton(),
        ),
      ],
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
    return SliverFillRemaining(
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
    );
  }
}
