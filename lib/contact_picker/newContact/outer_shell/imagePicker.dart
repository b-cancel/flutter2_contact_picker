import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/permissions/ask.dart';

//plugins
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

Future<String> changeImage(
  BuildContext context, {
  bool imageExists,
}) async {
  final imagePicker = ImagePicker();
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async {
          //pop without sending any data over
          Navigator.of(context).pop();
          //don't allow default (potentially unpredictable) pop
          return false;
        },
        child: Dialog(
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
                        imagePicker: imagePicker,
                        fromCamera: false,
                      ),
                      ImageGraberButton(
                        imagePicker: imagePicker,
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
        ),
      );
    },
  );
}

class ImageGraberButton extends StatelessWidget {
  const ImageGraberButton({
    @required this.fromCamera,
    @required this.imagePicker,
    Key key,
  }) : super(key: key);

  final bool fromCamera;
  final ImagePicker imagePicker;

  @override
  Widget build(BuildContext context) {
    String permissionName = fromCamera ? 'camera' : 'photos';
    Permission permission = fromCamera ? Permission.camera : Permission.storage;
    ImageSource permissionImageSource =
        fromCamera ? ImageSource.camera : ImageSource.gallery;
    //TODO: get platform specific
    IconData permissionIcon =
        fromCamera ? Icons.camera : FontAwesomeIcons.images;

    //build the hero button
    return Hero(
      tag: permissionName,
      child: Container(
        padding: EdgeInsets.all(4),
        child: IconButton(
          onPressed: () async {
            //! according to https://pub.dev/packages/image_picker Android doesn't have to ask for permissions for this
            //BUT this is because they are asking for permission themeselves
            //instead I will ask and cover more edge cases

            //ask permission specific to the request
            bool permissionGranted = await requestPermission(
              context,
              permissionName: permissionName,
              permission: permission,
            );

            //continue if they granted us permission
            if (permissionGranted) {
              //NOTE: here we KNOW that we have already been given the permissions we need
              PickedFile tempPickedFile = await imagePicker.getImage(
                source: permissionImageSource,
                maxHeight: 500,
                maxWidth: 500,
              );

              //if an image was actually selected
              if (tempPickedFile != null) {
                //TODO: avoid this conversion IF (it isn't required && takes up too much time)
                //convert to what we have tested before, just in case
                File tempFile = File(tempPickedFile.path);

                //ship over the temporary path to that image
                Navigator.of(context).pop(tempFile.path);
              }
              //ELSE... we backed out of selecting it, AFTER granting permission
            }
            //ELSE... we backed out of selecting it, BEFORE granting permission
          },
          icon: Icon(permissionIcon),
        ),
      ),
    );
  }
}
