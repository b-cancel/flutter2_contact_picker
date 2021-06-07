//dart
import 'dart:convert';
import 'dart:io';

//internal
import 'helper.dart';

//returns Map since all of our files will be json
Future<Map> fileToMap(String fileName, {bool createIfNeeded: true}) async {
  File fileReference = await nameToFileReference(fileName);
  if (await fileReference.exists() == false) {
    if (createIfNeeded) {
      await fileReference.create(); //create the file
    }
    return Map(); //return an emtpy map
  } else {
    String fileString = await fileReference.readAsString();

    //if there is something in the file, maybe its a map
    if (fileString.length > 0) {
      try {
        //attempt to decode json
        return jsonDecode(fileString);
      } catch (e) {
        //whatever was in there wasn't json
        return Map();
      }
    } else {
      //file was empty
      return Map();
    }
  }
}
