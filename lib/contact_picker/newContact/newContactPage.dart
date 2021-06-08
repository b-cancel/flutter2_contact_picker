import 'dart:io';
import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/appBarButton.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/helper.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/permissions/ask.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/permissions/justifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../categories/categoryData.dart';
import 'inner_shell/nameHandler.dart';

import 'outer_shell/scrollableEditor.dart';

class FieldData {
  TextEditingController controller;
  FocusNode focusNode;
  Function nextFunction;

  FieldData() {
    controller = new TextEditingController();
    focusNode = new FocusNode();
  }
}

//this page does not care for access
//until you attempt to save the contact
//at which point it confirms that you have the access you need for everything you are doing
//if you grant access to everything required AND save
//then you are allowed return the Contact
class NewContactPage extends StatefulWidget {
  NewContactPage();

  @override
  _NewContactPageState createState() => _NewContactPageState();
}

class _NewContactPageState extends State<NewContactPage> {
  //-------------------------Logic Code-------------------------
  ValueNotifier<String> imageLocation = new ValueNotifier<String>("");
  ValueNotifier<bool> namesSpread = new ValueNotifier<bool>(false);

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
  bool autoAddFirstPhone = false;
  List<FieldData> phoneValueFields = [];
  List<ValueNotifier<String>> phoneLabelStrings = [];

  //-------------------------Emails
  bool autoAddFirstEmail = false;
  List<FieldData> emailValueFields = [];
  List<ValueNotifier<String>> emailLabelStrings = [];

  //-------------------------Work
  bool autoOpenWork = false;
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

  //--------------------------------------------------
  //--------------------------------------------------
  //-------------------------Next Function Helpers-------------------------
  //--------------------------------------------------
  //--------------------------------------------------

  //NOTE: these WILL only be called IF indeed things are empty

  //starting with job title
  //called from toWork
  openWork() {
    if (workOpen.value == false) {
      //open the work section
      workOpen.value = true;
      //the value changing to true will trigger a listener
      //that will set state and focus on the right field
    }
  }

  //--------------------------------------------------
  //--------------------------------------------------
  //-------------------------Next Function Helper's Helpers-------------------------
  //--------------------------------------------------
  //--------------------------------------------------

  //IF next on the last name field...
  //IF no phone number... create one IF it's allowed
  //ELSE focus on the first field IF it exists
  //OTHERWISE do the alternative
  toFirstItem(
    List<FieldData> fields,
    bool autoAddFirstField,
    Function addFirst, {
    Function alternative,
  }) {
    bool fieldsPresent = (fields.length > 0);
    bool addFirstField = fieldsPresent == false && autoAddFirstField;

    //add the first field if possible
    if (addFirstField) {
      addFirst(); //will focus after build
    } else if (fieldsPresent) {
      //if the fields already exist autofocus on the first
      FocusScope.of(context).requestFocus(fields[0].focusNode);
    } else {
      if (alternative != null) {
        alternative();
      }
    }
  }

  //--------------------------------------------------
  //--------------------------------------------------
  //-------------------------Next Function Helpers-------------------------
  //--------------------------------------------------
  //--------------------------------------------------

  toFirstPhone() {
    toFirstItem(
      phoneValueFields,
      autoAddFirstPhone,
      addPhone,
      alternative: toFirstEmail,
    );
  }

  toFirstEmail() {
    toFirstItem(
      emailValueFields,
      autoAddFirstEmail,
      addEmail,
      alternative: toWork,
    );
  }

  toWork() {
    if (workOpen.value) {
      FocusScope.of(context).requestFocus(jobTitleField.focusNode);
    } else {
      if (autoOpenWork) {
        openWork();
      } else {
        toFirstAddress();
      }
    }
  }

  toFirstAddress() {
    toFirstItem(
      addressStreetFields,
      autoAddFirstAddress,
      addPostalAddress,
    );
  }

  //--------------------------------------------------
  //--------------------------------------------------
  //-------------------------Add To List Helper-------------------------
  //--------------------------------------------------
  //--------------------------------------------------

  addItem(List<List<FieldData>> allFields) {
    int newIndex = allFields[0].length;

    //init all fields for the new item
    for (int i = 0; i < allFields.length; i++) {
      allFields[i].add(FieldData()); //add both values
    }

    //set the state so the UI rebuilds with the new number
    setState(() {});

    //focus on the first field AFTER build completes (above)
    Function autoFocusAfterBuild = () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(allFields[0][newIndex].focusNode);
      });
    };

    //for the first time around wait another frame before autofocusing
    if (newIndex == 0) {
      //waited 3 frames without consistent behavior, leaving it here and moving on
      autoFocusAfterBuild();
    } else {
      autoFocusAfterBuild();
    }
  }

  //--------------------------------------------------
  //--------------------------------------------------
  //-------------------------Add To Lists-------------------------
  //--------------------------------------------------
  //--------------------------------------------------

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
      ValueNotifier<String>(CategoryData.defaultPhoneLabels[0]),
    );
  }

  addEmail() {
    //add field
    addItem([
      emailValueFields,
    ]);

    //add default string
    emailLabelStrings.add(
      ValueNotifier<String>(CategoryData.defaultEmailLabels[0]),
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
      ValueNotifier<String>(CategoryData.defaultAddressLabels[0]),
    );
  }

  //--------------------------------------------------
  //--------------------------------------------------
  //-------------------------Remove From Lists Helper-------------------------
  //--------------------------------------------------
  //--------------------------------------------------

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

  //--------------------------------------------------
  //--------------------------------------------------
  //-------------------------Remove From Lists-------------------------
  //--------------------------------------------------
  //--------------------------------------------------

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

  //--------------------------------------------------
  //--------------------------------------------------
  //-------------------------A State Changed-------------------------
  //--------------------------------------------------
  //--------------------------------------------------

  workOpenChanged() {
    //set state to reflect that change
    setState(() {});

    //focus on the section AFTER build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(jobTitleField.focusNode);
    });
  }

  namesSpreadChanged() {
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
  }

  //--------------------------------------------------
  //--------------------------------------------------
  //-------------------------Init-------------------------
  //--------------------------------------------------
  //--------------------------------------------------

  @override
  void initState() {
    //for label swapping
    CategoryData.initCustomLabels();

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

    //open and closers
    namesSpread.addListener(namesSpreadChanged);
    workOpen.addListener(workOpenChanged);

    //super init
    super.initState();
  }

  //--------------------------------------------------
  //--------------------------------------------------
  //-------------------------Dispose-------------------------
  //--------------------------------------------------
  //--------------------------------------------------

  @override
  void dispose() {
    workOpen.removeListener(workOpenChanged);
    namesSpread.removeListener(namesSpreadChanged);
    super.dispose();
  }

  //--------------------------------------------------
  //--------------------------------------------------
  //-------------------------build-------------------------
  //--------------------------------------------------
  //--------------------------------------------------

  @override
  Widget build(BuildContext context) {
    //only if we are in our last name do we move onto our first phone
    //or whatever else we can
    for (int index = 0; index < nameFields.length; index++) {
      FieldData thisField = nameFields[index];
      if (index < (nameFields.length - 1)) {
        //not last index
        thisField.nextFunction = () {
          FocusScope.of(context).requestFocus(nameFields[index + 1].focusNode);
        };
      }
    }

    //phones section
    for (int index = 0; index < phoneValueFields.length; index++) {
      FieldData thisField = phoneValueFields[index];
      if (index < (phoneValueFields.length - 1)) {
        //not last index
        thisField.nextFunction = () {
          FocusScope.of(context)
              .requestFocus(phoneValueFields[index + 1].focusNode);
        };
      }
    }

    //emails section
    for (int index = 0; index < emailValueFields.length; index++) {
      FieldData thisField = emailValueFields[index];
      if (index < (emailValueFields.length - 1)) {
        //not last index
        thisField.nextFunction = () {
          FocusScope.of(context)
              .requestFocus(emailValueFields[index + 1].focusNode);
        };
      }
    }

    //handle work section
    jobTitleField.nextFunction = () {
      FocusScope.of(context).requestFocus(companyField.focusNode);
    };

    //address section
    int addressCount = addressStreetFields.length;
    for (int index = 0; index < addressCount; index++) {
      //street, city, postcode, region, country
      addressStreetFields[index].nextFunction = () {
        FocusScope.of(context).requestFocus(addressCityFields[index].focusNode);
      };
      addressCityFields[index].nextFunction = () {
        FocusScope.of(context)
            .requestFocus(addressRegionFields[index].focusNode);
      };
      addressRegionFields[index].nextFunction = () {
        FocusScope.of(context)
            .requestFocus(addressPostcodeFields[index].focusNode);
      };
      addressPostcodeFields[index].nextFunction = () {
        FocusScope.of(context)
            .requestFocus(addressCountryFields[index].focusNode);
      };
      if (index < (addressCount - 1)) {
        addressCountryFields[index].nextFunction = () {
          FocusScope.of(context)
              .requestFocus(addressStreetFields[index + 1].focusNode);
        };
      }
    }

    //build
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          AppBarButton(
            onTapPassContext: (context) {
              Navigator.of(context).pop();
            },
            centerTitle: false,
            toolTip: 'Cancel',
            noBackButton: true,
            title: Text(
              'Cancel',
              overflow: TextOverflow.visible,
            ),
            actions: <Widget>[
              Center(
                child: Hero(
                  tag: 'new contact',
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.blue,
                        ),
                      ),
                      onPressed: () => createContact(),
                      child: Text(
                        "Save & Select",
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Theme(
              data: ThemeData.light(),
              child: ScrollableEditor(
                //basics
                imageLocation: imageLocation,

                //names stuff
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  //--------------------------------------------------
  //--------------------------------------------------
  //-------------------------Creating The Contact To Be Returned-------------------------
  //--------------------------------------------------
  //--------------------------------------------------

  createContact() async {
    //make sure all the name fields are filled as expected
    if (namesSpread.value) {
      //merge the spread name -> name
      nameField.controller.text = namesToName(nameFields);
    } else {
      //split the name -> names
      List<String> names = nameToNames(nameField.controller.text);
      for (int i = 0; i < names.length; i++) {
        nameFields[i].controller.text = names[i];
      }
    }

    //gen bools
    bool hasFirstName = (nameFields[1].controller.text.length > 0);
    bool hasLastName = (nameFields[3].controller.text.length > 0);
    bool hasName = (hasFirstName || hasLastName);

    //we can create the contact ONLY IF we have a first name
    if (hasName == false) {
      //inform the user of why their command didn't go through
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text(
            "A Name Is Required",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );

      //act accordingly
      if (hasName == false) {
        //then focus on the name field
        FocusScope.of(context).requestFocus(
          (namesSpread.value) ? nameFields[1].focusNode : nameField.focusNode,
        );
      } else {
        addPhone();
      }
    } else {
      //we have what we need to make a contact
      if (await havePermissionToCreateContact()) {
        saveNewContactAndPop();
      }
    }
  }

  havePermissionToCreateContact() async {
    PermissionStatus status = await Permission.contacts.status;
    if (status.isGranted || status.isLimited) {
      return true;
    } else {
      return await requestPermission(
        context,
        requestedAutomatically: false,
        permission: Permission.contacts,
        permissionName: "contacts",
        permissionJustification: JustifyContactsPermissionToSaveContact(),
      );
    }
  }

  saveNewContactAndPop() async {
    //maybe get avatar
    Uint8List maybeAvatar = await getAvatar();

    //save the name(s)
    String maybeFirstName = nameFields[1].controller.text;
    String maybeLastName = nameFields[3].controller.text;

    //NOTE: these are showing up exactly as expected on android
    //create contact WITH name to avoid error
    Contact newContact = new Contact(
      //avatar
      avatar: maybeAvatar,
      //name
      prefix: nameFields[0].controller.text,
      givenName: (maybeFirstName == "") ? " " : maybeFirstName,
      middleName: nameFields[2].controller.text,
      familyName: (maybeLastName == "") ? " " : maybeLastName,
      suffix: nameFields[4].controller.text,
      //phones
      phones: itemFieldData2ItemList(
        phoneValueFields,
        phoneLabelStrings,
      ),
      //emails
      emails: itemFieldData2ItemList(
        emailValueFields,
        emailLabelStrings,
      ),
      //work
      jobTitle: jobTitleField.controller.text,
      company: companyField.controller.text,
      //addresses
      postalAddresses: fieldsToAddresses(),
    );

    //what contacts exist before saving
    Map<String, Contact> beforeAddMap = contactListToMap(
      await ContactsService.getContacts(
        withThumbnails: false,
        photoHighResolution: false,
      ),
    );

    //add the new contact (returns null... what a shame)
    await ContactsService.addContact(newContact);

    //what contacts exist after saving
    Iterable<Contact> afterAddList = await ContactsService.getContacts(
      withThumbnails: false,
      photoHighResolution: false,
    );

    //find the new contact
    String newContactIdentifier = "";
    for (Contact contact in afterAddList) {
      String thisID = contact.identifier;
      if (beforeAddMap.containsKey(thisID) == false) {
        newContactIdentifier = thisID;
        break;
      }
    }

    //pop and pass true (to indivate we made a new contact)
    Navigator.of(context).pop(newContactIdentifier);
  }

  Future<Uint8List> getAvatar() async {
    //save the image
    if (imageLocation.value != "") {
      List<int> dataList = await File(imageLocation.value).readAsBytes();
      Uint8List eightList = Uint8List.fromList(dataList);

      //TODO: check if we have to save images that we took from within the app
      //in order to be able to use them within a contact
      //the plugin below is the most highly rated for this action, if its deemed necesary
      //https://pub.dev/packages/image_gallery_saver

      //save in new contact
      return eightList;
    }

    return null;
  }

  List<Item> itemFieldData2ItemList(
      List<FieldData> values, List<ValueNotifier<String>> labels) {
    List<Item> itemList = [];
    for (int i = 0; i < values.length; i++) {
      itemList.add(Item(
        value: values[i].controller.text,
        label: labels[i].value,
      ));
    }
    return itemList;
  }

  List<PostalAddress> fieldsToAddresses() {
    List<PostalAddress> addresses = [];
    for (int i = 0; i < addressStreetFields.length; i++) {
      addresses.add(PostalAddress(
        street: addressStreetFields[i].controller.text,
        city: addressCityFields[i].controller.text,
        postcode: addressPostcodeFields[i].controller.text,
        region: addressRegionFields[i].controller.text,
        country: addressCountryFields[i].controller.text,
        label: addressLabelStrings[i].value,
      ));
    }
    return addresses;
  }
}
