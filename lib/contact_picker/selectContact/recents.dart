import 'package:flutter/material.dart';
import '../../contact_picker/utils/read_write/list.dart';

//literally a clone of searches with swapped names
class RecentsData {
  static String recentsID = "recents";
  static bool _initComplete = false;
  static ValueNotifier<List<String>> recents = ValueNotifier([]);

  //won't allow double initializations
  static Future initRecents() async {
    if (_initComplete == false) {
      _initComplete = true;
      //grab everything that is stored
      recents.value = await loadRecents();
      //listen to changes and automatically update things
      recents.addListener(saveRecents);
    }
  }

  static containsRecent(String recent) {
    return recents.value.contains(recent);
  }

  //true if something new was added
  static addRecent(String newRecent) {
    //make sure this recent isn't already in the list
    bool recentRemoved = removeRecent(newRecent);
    //add it back to the top
    List newList = List<String>.from(recents.value);
    newList.add(newRecent); //actual addition
    recents.value = newList;
    //nothing was removed, so this is a new recent
    return recentRemoved == false;
  }

  //true if something was removed
  static bool removeRecent(String recent) {
    List newList = List<String>.from(recents.value);
    bool recentRemoved = newList.remove(recent);
    if (recentRemoved) {
      recents.value = newList;
    }
    return recentRemoved;
  }

  static Future saveRecents() async {
    return saveList(recentsID, recents.value);
  }

  static Future<List<String>> loadRecents() async {
    return await loadList(recentsID);
  }
}
