import 'dart:io';
import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'categorySelect.dart';
import 'inner_shell/nameHandler.dart';
import 'newContactUX.dart';
import 'outer_shell/appBarAndHeader.dart';

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

  toFirstItem(
    List<FieldData> fields,
    bool autoAddFirstField,
    Function addFirst, {
    Function alternative,
  }) {
    bool fieldsPresent = (fields.length > 0);
    bool canAddFirstField = fieldsPresent == false && autoAddFirstField;
    if (fieldsPresent || canAddFirstField) {
      if (canAddFirstField) {
        addFirst(); //will focus after build
      } else {
        FocusScope.of(context).requestFocus(fields[0].focusNode);
      }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(allFields[0][newIndex].focusNode);
    });
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
    workOpen.addListener(workOpenChanged);

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
    namesSpread.addListener(namesSpreadChanged);

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
        if (i < (addressCount - 1)) {
          FocusScope.of(context)
              .requestFocus(addressStreetFields[i + 1].focusNode);
        }
      };
    }

    return OrientationBuilder(builder: (context, orientation) {
      bool isPortrait = (orientation == Orientation.portrait);

      //calc bottom bar height
      double bottomBarHeight = 32;
      if (isPortrait == false) bottomBarHeight = 0;

      return NewContactAppBarAndHeader(
        createContact: createContact,
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
        ),
      );
    });
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
    bool hasNumber = (phoneValueFields.length > 0);

    //we can create the contact ONLY IF we have a first name
    if (hasName && hasNumber) {
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

      /*
      bool permissionGranted = await requestPermission(
                  context,
                  requestedAutomatically: false,
                  permission: Permission.contacts,
                  permissionName: "contacts",
                  permissionJustification: JustifyContactsPermission(),
                );

                //go to the contact picker if the permission is granted
                if (permissionGranted) {
                  goToContactPicker();
                }
      */

      //handle permissions
      PermissionStatus permissionStatus =
          (await Permission.getPermissionsStatus([PermissionName.Contacts]))[0]
              .permissionStatus;
      if (isAuthorized(permissionStatus)) {
        //with permission we can both
        //1. add the contact
        //NOTE: The contact must have a firstName / lastName to be successfully added
        await ContactsService.addContact(newContact);
        //2. and update the contact
        widget.onSelect(context, newContact);
      } else {}
    } else {
      //create the message
      String requiredFields;
      if (hasNumber == false && hasName)
        requiredFields = "Number is";
      else if (hasName == false && hasNumber)
        requiredFields = "Name is";
      else
        requiredFields = "Name and Number are";

      //inform the user of why their command didn't go through
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("The " + requiredFields + " Required"),
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
    }
  }

  Future<Uint8List> getAvatar() async {
    //save the image
    if (imageLocation.value != "") {
      List<int> dataList = await File(imageLocation.value).readAsBytes();
      Uint8List eightList = Uint8List.fromList(dataList);

      //take extra steps if needed
      if (isFromCamera.value) {
        var res = await ImageGallerySaver.save(eightList);
        print("*******" + res.toString());
        /*
        new File(path).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
        */
        /*
        var buffer = new Uint8List(8).buffer;
        var bdata = new ByteData.view(buffer);
        bdata.setFloat32(0, 3.04);
        int huh = bdata.getInt32(0);
        */
        /*
        ByteData bytes = 
        await rootBundle.load('assets/flutter.png');
        */
        //save the file since right now its only in temp memory
        imageLocation.value = await ImagePickerSaver.saveFile(
          fileData: eightList,
          title: "some title",
          description: "some description",
        );

        //get a reference to the file and update values
        File ref = File.fromUri(Uri.file(imageLocation.value));
        dataList = await ref.readAsBytes();
        eightList = Uint8List.fromList(dataList);
      }

      print("-----");
      print(eightList.toString());
      print("-----");

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
