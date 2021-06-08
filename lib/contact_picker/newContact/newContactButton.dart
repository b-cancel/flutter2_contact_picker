import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'newContactPage.dart';

class FullWidthNewContactButton extends StatelessWidget {
  const FullWidthNewContactButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'new contact',
      child: NewContactButton(),
    );
  }
}

class CollapsedNewContactButton extends StatelessWidget {
  const CollapsedNewContactButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'new contact',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NewContactButton(),
        ],
      ),
    );
  }
}

class NewContactButton extends StatelessWidget {
  const NewContactButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: Colors.blue,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
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
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Text(
                "Create New Contact",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
