import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

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

//-----Colors of Theme
List<Color> themeColors;
getThemeColors(ThemeData themeData) {
  themeColors = [];
  themeColors.add(themeData.accentColor);
  themeColors.add(themeData.backgroundColor);
  themeColors.add(themeData.canvasColor);
  themeColors.add(themeData.cardColor);
  //themeColors.add(themeData.cursorColor);
  themeColors.add(themeData.bottomAppBarColor);
  themeColors.add(themeData.buttonColor);
  themeColors.add(themeData.dialogBackgroundColor);
  themeColors.add(themeData.disabledColor);
  themeColors.add(themeData.dividerColor);
  themeColors.add(themeData.errorColor);
  themeColors.add(themeData.focusColor);
  themeColors.add(themeData.highlightColor);
  themeColors.add(themeData.hintColor);
  themeColors.add(themeData.hoverColor);
  themeColors.add(themeData.indicatorColor);
  themeColors.add(themeData.primaryColor);
  themeColors.add(themeData.primaryColorDark);
  themeColors.add(themeData.primaryColorLight);
  themeColors.add(themeData.scaffoldBackgroundColor);
  themeColors.add(themeData.secondaryHeaderColor);
  themeColors.add(themeData.selectedRowColor);
  themeColors.add(themeData.splashColor);
  //themeColors.add(themeData.textSelectionColor);
  //themeColors.add(themeData.textSelectionHandleColor);
  themeColors.add(themeData.toggleableActiveColor);
  themeColors.add(themeData.unselectedWidgetColor);
}
