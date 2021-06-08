import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/searchContact/searchContact.dart';
import 'package:flutter2_contact_picker/contact_picker/selectContact/selectContact.dart';
import 'package:page_transition/page_transition.dart';

import 'newContact/newContactPage.dart';

///poping this route is what returns, it may return null
///whenever we are accessing contact we make sure we have access to them first
///if we don't we simply pop this route
///SO this should never be the only thing on the navigation stack
///but we COULD simluate that it is, by forcing the user to select a contact
///by setting allowPop to false
class ContactPicker extends StatelessWidget {
  const ContactPicker({
    this.allowPop: true,
    key,
  }) : super(key: key);

  final bool allowPop;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //how we pop if we click the back button
      onWillPop: () async {
        return allowPop;
      },
      child: Scaffold(
        body: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop("ac unit");
                },
                icon: Icon(Icons.ac_unit),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop("alarm");
                },
                icon: Icon(Icons.alarm),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop("book");
                },
                icon: Icon(Icons.book),
              ),
              IconButton(
                onPressed: () async {
                  //creat the new contact
                  var newContact = await Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.bottomToTop,
                      child: Theme(
                        data: ThemeData.dark(),
                        child: NewContactPage(),
                      ),
                    ),
                  );

                  //if the new contact is indeed created
                  //save it
                  if (newContact != null) {
                    Navigator.of(context).pop(newContact);
                  }
                },
                icon: Icon(
                  Icons.add,
                  color: Colors.blue,
                ),
              ),
              IconButton(
                onPressed: () async {
                  //creat the new contact
                  var newContact = await Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.topToBottom,
                      child: Theme(
                        data: ThemeData.dark(),
                        child: SearchContactPage(),
                      ),
                    ),
                  );

                  //if the new contact is indeed created
                  //save it
                  if (newContact != null) {
                    Navigator.of(context).pop(newContact);
                  }
                },
                icon: Icon(
                  Icons.search,
                  color: Colors.blue,
                ),
              ),
              IconButton(
                onPressed: () async {
                  //creat the new contact
                  var newContact = await Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.topToBottom,
                      child: Theme(
                        data: ThemeData.dark(),
                        child: SelectContactPage(
                          verticalPrompt: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 56,
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 16,
                                bottom: 12,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Who's In Charge",
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "of the territory?",
                                    style: TextStyle(
                                      fontSize: 48,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          horizontalPrompt: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: 4,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Who's In Charge",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    " of the territory?",
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                icon: Icon(
                  Icons.select_all,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
