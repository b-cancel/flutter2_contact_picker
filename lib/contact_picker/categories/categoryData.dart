import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/read_write/list.dart';

enum LabelType { phone, email, address }

//TODO: eventually one could allow saving of custom labels

//default match those on an iPhone 12 on June 4th 2021
class CategoryData {
  static List<String> defaultPhoneLabels = [
    "mobile",
    "home",
    "work",
    "school",
    "iPhone",
    "Apple Watch",
    "main",
    "home fax",
    "work fax",
    "pager",
    "other",
  ];

  static List<String> defaultEmailLabels = [
    "home",
    "work",
    "school",
    "iCloud",
    "other",
  ];

  static List<String> defaultAddressLabels = [
    "home",
    "work",
    "school",
    "other",
  ];

  static Map<LabelType, List<String>> labelTypeToDefaultLabels = {
    LabelType.phone: defaultPhoneLabels,
    LabelType.email: defaultEmailLabels,
    LabelType.address: defaultAddressLabels,
  };

  static Map<LabelType, ValueNotifier<List<String>>>
      labelTypeToCustomLabelNotifiers = {
    LabelType.phone: customPhoneLabels,
    LabelType.email: customEmailLabels,
    LabelType.address: customAddressLabels,
  };

  static Map<LabelType, String> labelTypeToCategoryName = {
    LabelType.phone: "phone number",
    LabelType.email: "email address",
    LabelType.address: "address",
  };

  //--------------------------------------------------
  //--------------------------------------------------
  //Handle Async Custom Labels
  //--------------------------------------------------
  //--------------------------------------------------

  static ValueNotifier<List<String>> customPhoneLabels = ValueNotifier(
    [],
  );
  static ValueNotifier<List<String>> customEmailLabels = ValueNotifier(
    [],
  );
  static ValueNotifier<List<String>> customAddressLabels = ValueNotifier(
    [],
  );

  static initCustomLabels() async {
    //grab everything that is stored
    customPhoneLabels.value = await loadCustomLabels(
      LabelType.phone,
    );
    customEmailLabels.value = await loadCustomLabels(
      LabelType.email,
    );
    customAddressLabels.value = await loadCustomLabels(
      LabelType.address,
    );

    //listen to changes and automatically update things
    customPhoneLabels.addListener(() => saveCustomLabels(
          LabelType.phone,
        ));
    customEmailLabels.addListener(() => saveCustomLabels(
          LabelType.email,
        ));
    customAddressLabels.addListener(() => saveCustomLabels(
          LabelType.address,
        ));
  }

  static containsCustomLabel(LabelType labelType, String labelToFind) {
    return labelTypeToCustomLabelNotifiers[labelType]
        .value
        .contains(labelToFind);
  }

  static bool addToCustomLabels(LabelType labelType, String newLabel) {
    if (containsCustomLabel(labelType, newLabel) == false) {
      //add new list as value to trigger notifier
      List newList =
          List<String>.from(labelTypeToCustomLabelNotifiers[labelType].value);
      newList.add(newLabel); //actual addition
      labelTypeToCustomLabelNotifiers[labelType].value = newList;

      //successfull addition
      return true;
    } else {
      return false;
    }
  }

  static bool removeFromCustomLabels(LabelType labelType, String newLabel) {
    if (containsCustomLabel(labelType, newLabel) == true) {
      //add new list as value to trigger notifier
      List newList =
          List<String>.from(labelTypeToCustomLabelNotifiers[labelType].value);
      newList.remove(newLabel); //actual removal
      labelTypeToCustomLabelNotifiers[labelType].value = newList;

      //successfull removal
      return true;
    } else {
      return false;
    }
  }

  static Future saveCustomLabels(
    LabelType labelType,
  ) async {
    String identifier = labelType.toString();
    return saveList(
        identifier, labelTypeToCustomLabelNotifiers[labelType].value);
  }

  static Future<List<String>> loadCustomLabels(
    LabelType labelType,
  ) async {
    String identifier = labelType.toString();
    return await loadList(identifier);
  }
}
