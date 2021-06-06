import 'dart:ui';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class SearchContactPage extends StatefulWidget {
  @override
  _SearchContactPageState createState() => _SearchContactPageState();
}

class _SearchContactPageState extends State<SearchContactPage> {
  TextEditingController search = new TextEditingController();
  ValueNotifier<List<Contact>> results = new ValueNotifier([]);

  query(String searchString) async {
    if (searchString == "") {
      results.value = [];
    } else {
      Iterable<Contact> allContacts = await ContactsService.getContacts(
        withThumbnails: false,
        photoHighResolution: false,
        query: searchString,
      );
      results.value = allContacts.toList();
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

  @override
  void initState() {
    search.addListener(newSearch);
    results.addListener(updateState);
    super.initState();
  }

  @override
  void dispose() {
    search.removeListener(newSearch);
    results.removeListener(updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                            return ContactTile(
                              contact: results.value[index],
                              isFirst: index == 0,
                              isLast: index == (results.value.length - 1),
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

  final ValueNotifier<Iterable<Contact>> results;

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

class ContactTile extends StatelessWidget {
  const ContactTile({
    this.contact,
    this.isFirst: false,
    this.isLast: false,
    Key key,
  }) : super(key: key);

  final Contact contact;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    //handle numbers
    int numbers = contact.phones?.length ?? 0;

    //handle emails
    int emails = contact.emails?.length ?? 0;

    //build
    return Material(
      color: isLast ? ThemeData.dark().primaryColor : Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(isFirst ? 16 : 0),
                bottom: Radius.circular(isLast ? 16 : 0),
              ),
            ),
            child: ListTile(
              title: Padding(
                padding: EdgeInsets.only(
                  top: 4,
                  bottom: 4,
                ),
                child: Text(
                  contact.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(
                  bottom: 4,
                ),
                child: Row(
                  children: [
                    ContactChip(
                      iconData: Icons.phone,
                      dataCount: numbers,
                      errorLabel: "No Phone Numbers",
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 8.0,
                      ),
                      child: ContactChip(
                        iconData: Icons.email,
                        dataCount: emails,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
              ),
            ),
          ),
          Container(
            color: Colors.grey,
            height: isLast == false ? .5 : 0,
          ),
        ],
      ),
    );
  }
}

class ContactChip extends StatelessWidget {
  const ContactChip({
    Key key,
    @required this.iconData,
    @required this.dataCount,
    this.errorLabel,
  }) : super(key: key);

  final IconData iconData;
  final int dataCount;
  final String errorLabel;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: dataCount > 0 || (dataCount == 0 && errorLabel != null),
      child: Chip(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor:
            (dataCount == 0 && errorLabel != null) ? Colors.red : null,
        padding: EdgeInsets.all(0),
        label: dataCount == 0
            ? Text(
                errorLabel ?? "",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Row(
                children: [
                  (dataCount == 1)
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.only(
                            right: 4,
                          ),
                          child: Text(
                            dataCount.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  Icon(
                    iconData,
                    size: 16,
                  ),
                ],
              ),
      ),
    );
  }
}
