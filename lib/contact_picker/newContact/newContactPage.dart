import 'package:flutter/material.dart';
import 'categorySelect.dart';
import 'nameHandler.dart';
import 'newContactUX.dart';
import 'outer_shell/avatarAndSave.dart';

/*
 Contact({
    //names
    this.displayName,
    this.givenName,
    this.middleName,
    this.prefix,
    this.suffix,
    this.familyName,
    //other 
    this.company,
    this.jobTitle,
    this.emails,
    this.phones,
    this.postalAddresses,
    this.avatar,
    this.birthday,
    this.androidAccountType,
    this.androidAccountTypeRaw,
    this.androidAccountName,
  })
*/

class FieldData {
  TextEditingController controller;
  FocusNode focusNode;
  Function nextFunction;

  FieldData() {
    controller = new TextEditingController();
    focusNode = new FocusNode();
    nextFunction = () {
      print("next field");
    };
  }
}

//this page does not care for access
//it simply MIGHT return a contact it the form that it COULD be saved by the contact service
class NewContactPage extends StatefulWidget {
  NewContactPage();

  @override
  _NewContactPageState createState() => _NewContactPageState();
}

class _NewContactPageState extends State<NewContactPage> {
  //-------------------------Logic Code-------------------------
  ValueNotifier<bool> namesSpread = new ValueNotifier<bool>(false);
  ValueNotifier<String> imageLocation = new ValueNotifier<String>("");

  //-------------------------Fields Options-------------------------

  //NOTE: these are designed to be set ONCE and DONE
  //NOTE: we NEED a name so it autofocuses and therefore auto opens

  //-------------------------Fields Code-------------------------

  //-------------------------Name (put together)
  FieldData nameField = FieldData();

  //-------------------------Names (split up)
  //prefix, first, middle, last, suffix
  List<FieldData> nameFields = [];
  List<String> nameLabels = [];

  //-------------------------Phones
  bool autoAddFirstPhone = true;
  List<FieldData> phoneValueFields = [];
  List<ValueNotifier<String>> phoneLabelStrings = [];

  //-------------------------Emails
  bool autoAddFirstEmail = true;
  List<FieldData> emailValueFields = [];
  List<ValueNotifier<String>> emailLabelStrings = [];

  //-------------------------Work
  bool autoOpenWork = true;
  FieldData jobTitleField = FieldData(); //jobTitle
  FieldData companyField = FieldData(); //company
  ValueNotifier<bool> workOpen = new ValueNotifier<bool>(false);

  //-------------------------Addresses
  bool autoAddFirstAddress = false;
  List<FieldData> addressStreetFields = [];
  List<FieldData> addressCityFields = [];
  List<FieldData> addressPostcodeFields = [];
  List<FieldData> addressRegionFields = [];
  List<FieldData> addressCountryFields = [];
  List<ValueNotifier<String>> addressLabelStrings = [];

  //-------------------------Note
  bool autoOpenNote = true;
  FieldData noteField = FieldData(); //note
  ValueNotifier<bool> noteOpen = new ValueNotifier<bool>(false);

  //-------------------------Next Function Helpers-------------------------
  //NOTE: these WILL only be called IF indeed things are empty

  //start with value
  addFirstPhone() {
    if (phoneValueFields.isEmpty) {
      addPhone(); //sets state AND focuses on field
    }
  }

  //start with value
  addFirstEmail() {
    if (emailValueFields.isEmpty) {
      addEmail(); //sets state AND focuses on field
    }
  }

  //starting with job title
  openWork() {
    if (workOpen.value == false) {
      //open the work section
      workOpen.value = true;
      //the value changing to true will trigger a listener
      //that will set state and focus on the right field
    }
  }

  //starting with street
  addFirstPostalAddress() {
    if (addressStreetFields.isEmpty) {
      addPostalAddress(); //sets state AND focuses on field
    }
  }

  //start with note (only way to start :p)
  openNote() {
    if (noteOpen.value == false) {
      //open the note section
      noteOpen.value = true;
      //the value changing to true will trigger a listener
      //that will set state and focus on the right field
    }
  }

  //-------------------------Next Function Helper's Helpers-------------------------

  toFirstItem(
    List<FieldData> fields,
    bool autoAddFirstField,
    Function addFirst,
    Function alternative,
  ) {
    bool fieldsPresent = (fields.length > 0);
    bool canAddFirstField = fieldsPresent == false && autoAddFirstField;
    if (fieldsPresent || canAddFirstField) {
      if (canAddFirstField) {
        addFirst(); //will focus after build
      } else {
        FocusScope.of(context).requestFocus(fields[0].focusNode);
      }
    } else {
      alternative();
    }
  }

  //-------------------------Next Function Helpers-------------------------

  toFirstPhone() {
    //TODO... shift addPhone to addFirstPhone
    toFirstItem(phoneValueFields, autoAddFirstPhone, addPhone, toFirstEmail);
  }

  toFirstEmail() {
    //TODO... shift addEmail to addFirstEmail
    toFirstItem(emailValueFields, autoAddFirstEmail, addEmail, toWork);
  }

  toWork() {
    if (workOpen.value)
      FocusScope.of(context).requestFocus(jobTitleField.focusNode);
    else {
      if (autoOpenWork)
        openWork();
      else
        toFirstAddress();
    }
  }

  toFirstAddress() {
    //TODO... shift addPostalAddress to addFirstPostalAddress
    toFirstItem(
        addressStreetFields, autoAddFirstAddress, addPostalAddress, toNote);
  }

  toNote() {
    if (noteOpen.value)
      FocusScope.of(context).requestFocus(noteField.focusNode);
    else {
      if (autoOpenNote) openNote();
      //ELSE... there is nothing else to do
    }
  }

  //-------------------------Add To List Helper-------------------------

  addItem(List<List<FieldData>> allFields) {
    int newIndex = allFields[0].length;

    //init all fields for the new item
    for (int i = 0; i < allFields.length; i++) {
      allFields[i].add(FieldData()); //add both values
    }

    //set the state so the UI rebuilds with the new number
    setState(() {});

    //focus on the first field AFTER build completes (above)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(allFields[0][newIndex].focusNode);
    });
  }

  //-------------------------Add To Lists-------------------------
  //NOTES:
  //1. we always add at the end of the list
  //2. we must set state afterwards
  //3. whenever we add, we also have to focus on what we add

  addPhone() {
    //add field
    addItem([
      phoneValueFields,
    ]);

    //add default string
    phoneLabelStrings.add(
      ValueNotifier<String>(CategoryData.phoneLabels[0]),
    );
  }

  addEmail() {
    //add field
    addItem([
      emailValueFields,
    ]);

    //add default string
    emailLabelStrings.add(
      ValueNotifier<String>(CategoryData.emailLabels[0]),
    );
  }

  addPostalAddress() {
    //add field
    addItem([
      addressStreetFields,
      addressCityFields,
      addressPostcodeFields,
      addressRegionFields,
      addressCountryFields,
    ]);

    //add default string
    addressLabelStrings.add(
      ValueNotifier<String>(CategoryData.addressLabels[0]),
    );
  }

  //-------------------------Remove From Lists Helper-------------------------

  //NOTE: edge case where you delete the last item is handled
  //NOTE: if you are focused on some other item while deleting this one, your focus will not shift
  //NOTE: if you delete the last item in a list focus will be taken and keyboard closed
  removeItem(int index, List<List<FieldData>> allFields) {
    if (0 <= index && index < allFields[0].length) {
      //determine if we are currently focusing on any fields that will be deleted
      bool deleteFocusedField = false;
      for (int i = 0; i < allFields.length; i++) {
        if (allFields[i][index].focusNode.hasFocus) {
          deleteFocusedField = true;
          break;
        }
      }

      //remove the all fields of the item
      for (int i = 0; i < allFields.length; i++) {
        allFields[i].removeAt(index);
      }

      //set the state so the UI rebuilds with the new number
      setState(() {});

      //focus on the NEXT field AFTER build completes (above)
      if (deleteFocusedField) {
        print("length: " + allFields.length.toString());
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(new FocusNode());
          //NOTE: we could focus on the "nextFunction" of the deleted item
          //but it seems more standard to simply close up the keybaord
        });
      }
      //ELSE... stay focused on whatever other field you were before deleting this one
    }
    //ELSE... we can't remove what doesn't exist
  }

  //-------------------------Remove From Lists-------------------------
  //NOTE:
  //1. we can remove from any location in the list
  //2. we must set state afterwards
  //3. whenever we remove we also focus on whatever was going to be next
  //  on the thing we removed

  removePhone(int index) {
    //remove field
    removeItem(index, [
      phoneValueFields,
    ]);

    //remove string
    phoneLabelStrings.removeAt(
      index,
    );
  }

  removeEmail(int index) {
    //remove field
    removeItem(index, [
      emailValueFields,
    ]);

    //remove string
    emailLabelStrings.removeAt(
      index,
    );
  }

  removalPostalAddress(int index) {
    //remove field
    removeItem(index, [
      addressStreetFields,
      addressCityFields,
      addressPostcodeFields,
      addressRegionFields,
      addressCountryFields,
    ]);

    //remove string
    addressLabelStrings.removeAt(
      index,
    );
  }

  //-------------------------Init-------------------------
  @override
  void initState() {
    workOpen.addListener(() {
      //set state to reflect that change
      setState(() {});

      //focus on the section AFTER build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(jobTitleField.focusNode);
      });
    });

    noteOpen.addListener(() {
      //set state to reflect that change
      setState(() {});

      //focus on the section AFTER build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(noteField.focusNode);
      });
    });

    //-------------------------Variable Prep-------------------------

    //prefix, first, middle, last, suffix
    int fieldCount = 0; //0,1,2,3,4
    while (fieldCount < 5) {
      nameFields.add(FieldData());
      fieldCount++;
    }
    nameLabels.add("Name prefix");
    nameLabels.add("First name");
    nameLabels.add("Middle name");
    nameLabels.add("Last name");
    nameLabels.add("Name suffix");

    //-------------------------Other-------------------------

    //NOTE: we could keep everything in its position
    //IF after all the names are merged the merge name isn't updated
    //But that's too much work

    //if we spread or unspread the name
    namesSpread.addListener(() {
      //modify text editing controller value
      if (namesSpread.value) {
        //if all the names have been spread
        //split things up
        List<String> theNames = nameToNames(nameField.controller.text);

        //apply this our fields
        for (int i = 0; i < nameFields.length; i++) {
          nameFields[i].controller.text = theNames[i];
        }
      } else {
        //If all the names have been closed
        //put things together
        String name = namesToName(nameFields);

        //set the combine name into our field
        nameField.controller.text = name;
      }

      //actually open the names
      setState(() {});

      //focus on the proper name
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (namesSpread.value) {
          //if all the names have been spread
          FocusScope.of(context).requestFocus(nameFields[1].focusNode);
        } else {
          //If all the names have been closed
          FocusScope.of(context).requestFocus(nameField.focusNode);
        }
      });
    });

    //super init
    super.initState();
  }

  //-------------------------build-------------------------
  @override
  Widget build(BuildContext context) {
    //TODO... I should be able to shift everything below to init
    //from our name field we move onto the first phone
    //or whatever else we can
    nameField.nextFunction = toFirstPhone;

    //only if we are in our last name do we move onto our first phone
    //or whatever else we can
    for (int i = 0; i < nameFields.length; i++) {
      FieldData thisField = nameFields[i];
      if (i != (nameFields.length - 1)) {
        //not last index
        thisField.nextFunction = () {
          FocusScope.of(context).requestFocus(nameFields[i + 1].focusNode);
        };
      } else
        thisField.nextFunction = toFirstPhone;
    }

    //phones section
    for (int i = 0; i < phoneValueFields.length; i++) {
      FieldData thisField = phoneValueFields[i];
      if (i != (phoneValueFields.length - 1)) {
        //not last index
        thisField.nextFunction = () {
          FocusScope.of(context)
              .requestFocus(phoneValueFields[i + 1].focusNode);
        };
      } else
        thisField.nextFunction = toFirstEmail;
    }

    //emails section
    for (int i = 0; i < emailValueFields.length; i++) {
      FieldData thisField = emailValueFields[i];
      if (i != (emailValueFields.length - 1)) {
        //not last index
        thisField.nextFunction = () {
          FocusScope.of(context)
              .requestFocus(emailValueFields[i + 1].focusNode);
        };
      } else
        thisField.nextFunction = toWork;
    }

    //handle work section
    jobTitleField.nextFunction = () {
      FocusScope.of(context).requestFocus(companyField.focusNode);
    };
    companyField.nextFunction = toFirstAddress;

    //address section
    int addressCount = addressStreetFields.length;
    for (int i = 0; i < addressCount; i++) {
      //street, city, postcode, region, country
      addressStreetFields[i].nextFunction = () {
        FocusScope.of(context).requestFocus(addressCityFields[i].focusNode);
      };
      addressCityFields[i].nextFunction = () {
        FocusScope.of(context).requestFocus(addressPostcodeFields[i].focusNode);
      };
      addressPostcodeFields[i].nextFunction = () {
        FocusScope.of(context).requestFocus(addressRegionFields[i].focusNode);
      };
      addressRegionFields[i].nextFunction = () {
        FocusScope.of(context).requestFocus(addressCountryFields[i].focusNode);
      };
      addressCountryFields[i].nextFunction = () {
        if (i == (addressCount - 1)) {
          //last address
          toNote();
        } else {
          FocusScope.of(context)
              .requestFocus(addressStreetFields[i + 1].focusNode);
        }
      };
    }

    //handle note section
    noteField.nextFunction = null;

    return OrientationBuilder(builder: (context, orientation) {
      bool isPortrait = (orientation == Orientation.portrait);

      //calc bottom bar height
      double bottomBarHeight = 32;
      if (isPortrait == false) bottomBarHeight = 0;

      return NewContactAvatarAndSave(
        returnContact: () {
          print("this used to be create contant");
        },
        imageLocation: imageLocation,
        isPortrait: isPortrait,
        fields: NewContactEditFields(
          //names stuff
          bottomBarHeight: bottomBarHeight,
          namesSpread: namesSpread,
          nameField: nameField,
          nameFields: nameFields,
          nameLabels: nameLabels,

          //phones
          addPhone: addPhone,
          removePhone: removePhone,
          phoneFields: phoneValueFields,
          phoneLabels: phoneLabelStrings,

          //emails
          addEmail: addEmail,
          removeEmail: removeEmail,
          emailFields: emailValueFields,
          emailLabels: emailLabelStrings,

          //work stuff
          jobTitleField: jobTitleField,
          companyField: companyField,
          workOpen: workOpen,

          //address
          addAddress: addPostalAddress,
          removeAddress: removalPostalAddress,
          addressStreetFields: addressStreetFields,
          addressCityFields: addressCityFields,
          addressPostcodeFields: addressPostcodeFields,
          addressRegionFields: addressRegionFields,
          addressCountryFields: addressCountryFields,
          addressLabels: addressLabelStrings,

          //note stuff
          noteField: noteField,
          noteOpen: noteOpen,
        ),
      );
    });
  }
}
