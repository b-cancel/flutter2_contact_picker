import 'dart:math';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/helper.dart';

//these tiles are a height of 56
class ContactTile extends StatelessWidget {
  const ContactTile({
    @required this.contact,
    @required this.onTap,
    @required this.isFirst,
    @required this.isLast,
    this.highlightPhone: false,
    this.highlightEmail: false,
    this.iconColor,
    this.bottomBlack: false,
    Key key,
  }) : super(key: key);

  final Contact contact;
  final Function onTap;
  final bool isFirst;
  final bool isLast;
  final bool highlightPhone;
  final bool highlightEmail;
  final Color iconColor;
  final bool bottomBlack;

  @override
  Widget build(BuildContext context) {
    //handle numbers
    int numbers = contact.phones?.length ?? 0;

    //handle emails
    int emails = contact.emails?.length ?? 0;

    //build
    return Material(
      color: isLast && bottomBlack == false
          ? ThemeData.dark().primaryColor
          : Colors.transparent,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(isFirst ? 16 : 0),
              bottom: Radius.circular(isLast ? 16 : 0),
            ),
            child: SizedBox(
              height: 56,
              child: Material(
                color: Colors.white,
                child: ListTile(
                  visualDensity: VisualDensity.compact,
                  onTap: onTap,
                  leading: Transform.translate(
                    offset: Offset(0, -4),
                    child: TileImage(
                      contact: contact,
                      color: iconColor,
                    ),
                  ),
                  title: Transform.translate(
                    offset: Offset(0, -8),
                    child: Text(
                      contact.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  subtitle: Transform.translate(
                    offset: Offset(0, -8),
                    child: Row(
                      children: [
                        ContactChip(
                          iconData: Icons.phone,
                          dataCount: numbers,
                          errorLabel: "No Phone Numbers",
                          highlight: highlightPhone,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 8.0,
                          ),
                          child: ContactChip(
                            iconData: Icons.email,
                            dataCount: emails,
                            highlight: highlightEmail,
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
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.grey,
              height: isLast == false ? 1 : 0,
              width: MediaQuery.of(context).size.width,
            ),
          ),
        ],
      ),
    );
  }
}

class TileImage extends StatelessWidget {
  TileImage({
    @required this.contact,
    this.color,
  });

  final Contact contact;
  final Color color;

  Widget build(BuildContext context) {
    Widget child;
    if (contact.avatar.length <= 0) {
      String letters = contact.givenName;
      Widget center;

      //if possible have a letter
      if (letters.length == 0) {
        center = Icon(
          Icons.person,
          color: Colors.black,
        );
      } else {
        center = Text(
          letters[0].toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        );
      }

      child = Center(
        child: center,
      );
    } else {
      child = ClipOval(
        child: FittedBox(
          fit: BoxFit.cover,
          child: Image.memory(
            contact.avatar,
          ),
        ),
      );
    }

    return Container(
      //56 is max size for this kind of thing
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: color ?? getRandomDarkBlueOrGreyColor(),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}

class ContactChip extends StatelessWidget {
  const ContactChip({
    Key key,
    @required this.iconData,
    @required this.dataCount,
    this.errorLabel,
    this.highlight: false,
  }) : super(key: key);

  final IconData iconData;
  final int dataCount;
  final String errorLabel;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: dataCount > 0 || (dataCount == 0 && errorLabel != null),
      child: Container(
        margin: EdgeInsets.all(0),
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: (dataCount == 0 && errorLabel != null)
              ? Colors.red
              : (highlight ? Colors.blue : Colors.black),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 8,
        ),
        child: dataCount == 0
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
                              color: Colors.white,
                            ),
                          ),
                        ),
                  Icon(
                    iconData,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    );
  }
}

//randomizer for below
Random random = new Random();

//NOTE: we never scramble the first letter
String scrambler(String original, double scrambleFactor,
    {bool onlyNumbers: false}) {
  //otherwise substring stuff will break things
  if (original.length > 2) {
    //setup
    int len = original.length;
    int valuesToScramble = (len * scrambleFactor).toInt();

    //scramble
    while (valuesToScramble > 0) {
      //never scramble the first value (For section purposes)
      int indexToReplace =
          random.nextInt(len - 2) + 1; //TODO... check 1->(len-1)

      //scramble that index
      int replacementLetter;
      if (onlyNumbers) {
        //only replace lower case letters
        if (isNumeric(original[indexToReplace])) {
          //TODO... check 48->57
          replacementLetter = random.nextInt(9) + 48;
        } else {
          //we can't it isnt a number
          replacementLetter = -1;
        }
      } else {
        //only replace lower case letters
        if (isLowerCase(original[indexToReplace])) {
          //TODO... check 97->122
          replacementLetter = random.nextInt(25) + 97;
        } //we can't it isn't lower case
        else
          replacementLetter = -1;
      }

      //update string IF possible
      if (replacementLetter != -1) {
        String newChar = String.fromCharCode(replacementLetter);
        String left = original.substring(0, indexToReplace);
        String right = original.substring(indexToReplace + 1, len);
        original = left + newChar + right;
      }

      //keep scrambling maybe
      //if we dont have this here
      //then if the string doesn't have what we are looking for
      //the function has the chance of never finishing
      valuesToScramble--;
    }

    //return
    return original;
  } else
    return original;
}

bool isNumeric(String s) {
  if (s == null || s.length == 0)
    return false;
  else {
    int code = s.codeUnitAt(0);
    if (48 <= code && code <= 57)
      return true;
    else
      return false;
  }
}

bool isLowerCase(String str) {
  return str == str.toLowerCase() && str != str.toUpperCase();
}
