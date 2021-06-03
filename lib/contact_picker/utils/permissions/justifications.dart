import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'standardDialog.dart';

capitalizeFirstLetter(String string) {
  return "${string[0].toUpperCase()}${string.substring(1).toLowerCase()}";
}

class EnableManuallyDialog extends StatelessWidget {
  const EnableManuallyDialog({
    @required this.permission,
    @required this.permissionName,
    Key key,
  }) : super(key: key);

  final Permission permission;
  final String permissionName;

  @override
  Widget build(BuildContext context) {
    return ToAppSettingsPopUp(
      permissionName: permissionName,
      permission: permission,
      title: "Enable " + capitalizeFirstLetter(permissionName) + " Manually",
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Text(
                "You need to grant us access manually from this App's Settings",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExplainRestrictionDialog extends StatelessWidget {
  const ExplainRestrictionDialog({
    @required this.permission,
    @required this.permissionName,
    Key key,
  }) : super(key: key);

  final Permission permission;
  final String permissionName;

  @override
  Widget build(BuildContext context) {
    return ToAppSettingsPopUp(
      permissionName: permissionName,
      permission: permission,
      title: capitalizeFirstLetter(permissionName) + " Restricted",
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 8.0,
                    ),
                    child: Text(
                      "This restriction may be due to parental controls.",
                    ),
                  ),
                  Text(
                    "You can try going to the settings page to grant us access.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ToAppSettingsPopUp extends StatelessWidget {
  const ToAppSettingsPopUp({
    @required this.permissionName,
    @required this.title,
    @required this.body,
    @required this.permission,
    Key key,
  }) : super(key: key);

  final String permissionName;
  final String title;
  final Widget body;
  final Permission permission;

  checkStatusThenPopAccordingly(BuildContext context) async {
    //request is allways more accurate that just checking the status
    //and since we are here AFTER confirming that they either
    //1. denied permanently
    //2. OR are restricted
    //the pop up won't come up
    //unless they did some weird settings flickering
    //in which case the pop up comming up will work either way
    PermissionStatus newStatus = await permission.request();
    if (newStatus.isGranted || newStatus.isLimited) {
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StandardHeroDialog(
      tag: permissionName,
      onPop: () => checkStatusThenPopAccordingly(context),
      headerColor: Colors.black,
      header: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: 24,
                bottom: 36,
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                child: body,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Material(
              borderRadius: BorderRadius.circular(56),
              color: Colors.blue,
              child: InkWell(
                borderRadius: BorderRadius.circular(56),
                onTap: () {
                  openAppSettings();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text(
                        "Open App Settings",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      stickyFooter: DenyOrAllow(
        //eventhough this is essentially the same as the button bellow
        //they should have an obvious close button
        onDeny: () => checkStatusThenPopAccordingly(context),
        denyText: "Close",
        denyTextColor: Colors.black,
        //the button that checks if they made the changes
        onAllow: () => checkStatusThenPopAccordingly(context),
        allowText: "Done",
        allowButtonColor: Colors.blue,
      ),
    );
  }
}

class JustificationDialog extends StatelessWidget {
  const JustificationDialog({
    @required this.requestedAutomatically,
    @required this.permissionName,
    @required this.permissionJustification,
    Key key,
  }) : super(key: key);

  final bool requestedAutomatically;
  final String permissionName;
  final Widget permissionJustification;

  @override
  Widget build(BuildContext context) {
    return StandardHeroDialog(
      tag: requestedAutomatically == false ? permissionName : null,
      onPop: () {
        Navigator.of(context).pop(false);
      },
      headerColor: Colors.black,
      header: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          children: [
            Text(
              "Grant Us Access",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              //contacts, photos, camera, location
              "to your " + permissionName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 24,
            bottom: 36,
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            child: permissionJustification,
          ),
        ),
      ),
      stickyFooter: DenyOrAllow(
        onDeny: () {
          Navigator.of(context).pop(false);
        },
        onAllow: () {
          Navigator.of(context).pop(true);
        },
      ),
    );
  }
}

//create standard styles
TextStyle normal = TextStyle(
  fontSize: 16,
  color: Colors.black,
  fontWeight: FontWeight.normal,
);

TextStyle bold = TextStyle(
  fontSize: 16,
  color: Colors.black,
  fontWeight: FontWeight.bold,
);

class JustifyContactsPermissionToSaveContact extends StatelessWidget {
  const JustifyContactsPermissionToSaveContact({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "So you can ",
            style: normal,
          ),
          TextSpan(
            text: "save the contact",
            style: bold,
          ),
        ],
      ),
    );
  }
}

class JustifyCameraPermissionForAvatar extends StatelessWidget {
  const JustifyCameraPermissionForAvatar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "So you can ",
            style: normal,
          ),
          TextSpan(
            text: "take a photo",
            style: bold,
          ),
        ],
      ),
    );
  }
}

class JustifyStoragePermissionForAvatar extends StatelessWidget {
  const JustifyStoragePermissionForAvatar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "So you can ",
            style: normal,
          ),
          TextSpan(
            text: "select a photo",
            style: bold,
          ),
        ],
      ),
    );
  }
}
