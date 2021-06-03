import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'contact_picker/contact_picker.dart';

void main() => runApp(
      MaterialApp(
        home: MyApp(),
      ),
    );

const Duration normalHumanReactionTime = Duration(milliseconds: 250);

//this is by no means a thorough solution for handling permission request
//! It never explains WHY the app needs a permission
//but the contact picker assumes that you KNOW you have access to contacts
//before you attempt to select a contact
//so I needed to make this
Future tryToGoToContactPicker(
  BuildContext context, {
  @required bool allowPop,
}) async {
  //ask for permission, or confirm that we have it
  DateTime timeBeforeRequest = DateTime.now();
  PermissionStatus status = await Permission.contacts.request();
  DateTime timeAfterRequest = DateTime.now();
  Duration durationBetweenRequestAndResult =
      timeAfterRequest.difference(timeBeforeRequest);
  bool weAssumeTheRequestWasMade =
      durationBetweenRequestAndResult > normalHumanReactionTime;

  //if we have it, then open the contact picker
  if (status.isGranted || status.isLimited) {
    //select a contact, or decide to back out
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return ContactPicker(
            //wether or not they are forced to select a contact before continuing
            allowPop: allowPop,
          );
        },
      ),
    );
  } else {
    //handle the edge case
    if (weAssumeTheRequestWasMade) {
      return null;
    }

    //open app settings automatically if possible
    bool couldOpenAppSettings = await openAppSettings();

    //if I can't do that then explain what I need to do
    //to enable the contact permission
    if (couldOpenAppSettings == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open App Settings Automatically' +
                "\n" +
                "Go into this App's Settings, and enable the Contacts Permission",
          ),
        ),
      );
    }

    //a contact hasn't been selected this time around
    //when they come back from app settings they may have enable the permission
    //but they will simply have to call [tryToGoToContactPicker] again
    return null;
  }
}

//--------------------------------------------------
//Automatically ask for contacts permission
//If rejected allow user to ask again
//and provide explanations to how they can do that
//upon approval force the user to select a contact
//--------------------------------------------------
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  tryToDisplayContact() async {
    //try to get a contact (ask permission first)
    var result = await tryToGoToContactPicker(
      context,
      //force contact selection once we have permission
      allowPop: false,
    );

    //when we get a contact
    //display it and allow the user to change it
    if (result != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) {
            return ContactDisplay(
              initialContactInfo: result,
            );
          },
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    tryToDisplayContact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            tryToDisplayContact();
          },
          child: Text("Try To Select A Contact"),
        ),
      ),
    );
  }
}

//--------------------------------------------------
//Show the currently select contact
//allow another contact to be selected
//--------------------------------------------------
class ContactDisplay extends StatefulWidget {
  const ContactDisplay({
    @required this.initialContactInfo,
    Key key,
  }) : super(key: key);

  final initialContactInfo;

  @override
  _ContactDisplayState createState() => _ContactDisplayState();
}

class _ContactDisplayState extends State<ContactDisplay> {
  ValueNotifier currentContactInfo;

  @override
  void initState() {
    super.initState();
    currentContactInfo = new ValueNotifier(widget.initialContactInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: currentContactInfo,
          builder: (context, snapshot) {
            return ElevatedButton(
              onPressed: () async {
                //go to contact picker
                var result = await tryToGoToContactPicker(
                  context,
                  allowPop: true,
                );

                //grab result and make needed modifications
                if (result != null) {
                  currentContactInfo.value = result;
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Tap To Pick New Contact"),
                  Text(
                    currentContactInfo.value.toString(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
