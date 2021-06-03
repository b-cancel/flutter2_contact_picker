import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/permissions/ask.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/permissions/justifications.dart';

//plugins
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

Future<String> changeImage(
  BuildContext context, {
  bool imageExists,
}) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ImageGraberButton(
                      fromCamera: false,
                    ),
                    ImageGraberButton(
                      fromCamera: true,
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: imageExists,
                child: Center(
                    child: TextButton(
                  onPressed: () {
                    //remove the image they once had a reference to
                    Navigator.of(context).pop("");
                  },
                  child: Text(
                    "Remove Image",
                  ),
                )),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class ImageGraberButton extends StatelessWidget {
  const ImageGraberButton({
    @required this.fromCamera,
    Key key,
  }) : super(key: key);

  final bool fromCamera;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      child: IconButton(
        onPressed: () async {
          bool permissionGranted = await requestPermission(
            context,
            requestedAutomatically: false,
            permission: Permission.contacts,
            permissionName: "contacts",
            permissionJustification: JustifyContactsPermissionToSaveContact(),
          );

          //go to the contact picker if the permission is granted
          if (permissionGranted) {
            goToContactPicker();
          }

          if (fromCamera) {
            askPermission(
              context,
              //from camera
              () => actuallyChangeImage(context, true),
              PermissionBeingRequested.camera,
            );
          } else {
            askPermission(
              context,
              //not from camera
              () => actuallyChangeImage(context, false),
              PermissionBeingRequested.storage,
            );
          }
        },
        icon: Icon(fromCamera ? Icons.camera : FontAwesomeIcons.images),
      ),
    );
  }
}

actuallyChangeImage(
  BuildContext context,
  ValueNotifier<String> imageLocation,
  bool fromCamera,
) async {
  //NOTE: here we KNOW that we have already been given the permissions we need
  File tempImage = await ImagePicker.pickImage(
    source: (fromCamera) ? ImageSource.camera : ImageSource.gallery,
    maxHeight: 500,
    maxWidth: 500,
  );

  //if an image was actually selected
  if (tempImage != null) {
    //pop the popup
    Navigator.of(context).pop();

    //set the new image location
    imageLocation.value = tempImage.path;
  }
  //ELSE... we back out of selecting it
}
