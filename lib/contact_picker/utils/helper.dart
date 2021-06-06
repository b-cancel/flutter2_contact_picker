import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/tile/tile.dart';

Map<String, Contact> contactListToMap(Iterable<Contact> contactList) {
  return Map<String, Contact>.fromIterable(
    contactList,
    key: (contact) => contact.identifier,
    value: (contact) => contact,
  );
}

String contactToName(Contact c) {
  String prefix = c?.prefix ?? "";
  String first = c?.givenName ?? "";
  String middle = c?.middleName ?? "";
  String last = c?.familyName ?? "";
  String suffix = c?.suffix ?? "";

  List<String> names = [];

  if (prefix != "") names.add(prefix);
  if (first != "") names.add(first);
  if (middle != "") names.add(middle);
  if (last != "") names.add(last);
  if (suffix != "") names.add(suffix);

  String result = "";
  for (int i = 0; i < names.length; i++) {
    if (i != 0) result += " ";
    result += names[i];
  }

  return result;
}

String _onlyCharactersS2E(String string, int startInc, int endInc) {
  String output = "";
  for (int i = 0; i < string.length; i++) {
    int code = string[i].codeUnitAt(0);
    if (startInc <= code && code <= endInc) {
      output += string[i];
    }
  }
  return output;
}

String onlyNumbers(String string) {
  return _onlyCharactersS2E(string, 48, 57);
}

String onlyCharacters(String string) {
  return _onlyCharactersS2E(string, 97, 122);
}

getRandomDarkBlueOrGreyColor() {
  //shade of color (stay darker)
  //0,1,2,3,4 => 5,6,7,8,9
  int specificColor = random.nextInt(5) + 4;
  int colorInt = specificColor * 100;

  //range of color
  int vagueColor = random.nextInt(3);
  if (vagueColor == 0) {
    return Colors.grey[colorInt];
  } else if (vagueColor == 1) {
    return Colors.blueGrey[colorInt];
  } else {
    return Colors.blue[colorInt];
  }
}
