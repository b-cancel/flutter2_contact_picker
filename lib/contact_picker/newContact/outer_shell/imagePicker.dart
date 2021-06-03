import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

void showImagePicker(
    BuildContext context, ValueNotifier<String> imageLocation) {
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext context) {
      bool showRemoveImage = (imageLocation.value != "");
      Widget removeImage = Container();
      if (showRemoveImage) {
        removeImage = FlatButton(
          onPressed: () {
            Navigator.pop(context);
            imageLocation.value = "";
          },
          child: Text(
            "Remove Image",
          ),
        );
      }

      // return object of type Dialog
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
                    bigIcon(
                        context, imageLocation, false, FontAwesomeIcons.images),
                    bigIcon(context, imageLocation, true, Icons.camera),
                  ],
                ),
              ),
              Container(
                child: removeImage,
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget bigIcon(
  BuildContext context,
  ValueNotifier<String> imageLocation,
  bool fromCamera,
  IconData icon,
) {
  return Container(
    padding: EdgeInsets.all(4),
    child: IconButton(
      onPressed: () => changeImage(context, imageLocation, fromCamera),
      icon: Icon(icon),
    ),
  );
}

//return whether or not you should set state
changeImage(BuildContext context, ValueNotifier<String> imageLocation,
    bool fromCamera) async {
  if (fromCamera) {
    askPermission(
      context,
      //from camera
      () => actuallyChangeImage(context, imageLocation, true),
      PermissionBeingRequested.camera,
    );
  } else {
    askPermission(
      context,
      //not from camera
      () => actuallyChangeImage(context, imageLocation, false),
      PermissionBeingRequested.storage,
    );
  }
}

actuallyChangeImage(BuildContext context, ValueNotifier<String> imageLocation,
    bool fromCamera) async {
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
