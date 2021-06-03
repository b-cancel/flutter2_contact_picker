import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'newContactHelper.dart';

/*
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
        //note
        note: noteField.controller.text,
      );

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
      } else {
      }
    } else {
      //create the message
      String message;
      if (hasNumber == false && hasName)
        message = "The Number is";
      else if (hasName == false && hasNumber)
        message = "The Name is";
      else
        message = "The Name and Number are";

      //inform the user of why their command didn't go through
      Fluttertoast.showToast(
        msg: message + " Required",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 3,
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

  //-------------------------Submit Action Functionality-------------------------
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
  */

//-------------------------Save Contact Helper-------------------------
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

/*
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
  */