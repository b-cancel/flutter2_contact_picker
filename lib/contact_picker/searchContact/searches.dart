import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/read_write/list.dart';

class SearchesData {
  static String searchesID = "searches";
  static ValueNotifier<List<String>> searches = ValueNotifier([]);

  //won't allow double initializations
  static initSearches() async {
    if (searches.value.length == 0) {
      //grab everything that is stored
      searches.value = await loadSearches();
      //listen to changes and automatically update things
      searches.addListener(saveSearches);
    }
  }

  static containsSearch(String search) {
    return searches.value.contains(search);
  }

  //true if something new was added
  static addSearches(String newSearch) {
    //make sure this search isn't already in the list
    bool searchRemoved = removeSearch(newSearch);
    //add it back to the top
    List newList = List<String>.from(searches.value);
    newList.add(newSearch); //actual addition
    searches.value = newList;
    //nothing was removed, so this is a new search
    return searchRemoved == false;
  }

  //true if something was removed
  static bool removeSearch(String search) {
    List newList = List<String>.from(searches.value);
    bool searchRemoved = newList.remove(search);
    if (searchRemoved) {
      searches.value = newList;
    }
    return searchRemoved;
  }

  static Future saveSearches() async {
    return saveList(searchesID, searches.value);
  }

  static Future<List<String>> loadSearches() async {
    return await loadList(searchesID);
  }
}
