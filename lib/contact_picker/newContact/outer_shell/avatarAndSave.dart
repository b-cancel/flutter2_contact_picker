import 'dart:io';

import 'package:flutter/material.dart';

import 'imagePicker.dart';

class NewContactAvatarAndSave extends StatelessWidget {
  NewContactAvatarAndSave({
    @required this.createContact,
    @required this.imageLocation,
    @required this.fields,
    //determines how large the contact image is
    @required this.isPortrait,
  });

  final Function createContact;
  final ValueNotifier<String> imageLocation;
  final Widget fields;

  //determines how large the contact image is
  final bool isPortrait;

  @override
  Widget build(BuildContext context) {
    //calc imageDiameter
    double imageDiameter = MediaQuery.of(context).size.width / 2;
    if (isPortrait == false) {
      imageDiameter = MediaQuery.of(context).size.height / 2;
    }

    //make new contact UX
    Widget bodyWidget = ListView(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              color: Theme.of(context).primaryColorDark,
              padding: EdgeInsets.fromLTRB(
                0,
                //push CARD down to the ABOUT middle of the picture
                imageDiameter * (5 / 7),
                0,
                16,
              ),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Card(
                    margin: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(
                        0,
                        //push CARD CONTENT down to past the picture
                        imageDiameter * (2 / 7) + 16 * 2,
                        0,
                        16,
                      ),
                      child: fields,
                    ),
                  ),
                ],
              ),
            ),
            //-------------------------Picture UX
            Container(
              padding: EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  showImagePicker(
                    context,
                    imageLocation,
                  );
                },
                child: Stack(
                  children: <Widget>[
                    new Container(
                        width: imageDiameter,
                        height: imageDiameter,
                        decoration: new BoxDecoration(
                          color: Theme.of(context).indicatorColor,
                          shape: BoxShape.circle,
                        ),
                        child: (imageLocation.value == "")
                            ? Icon(
                                Icons.camera_alt,
                                size: imageDiameter / 2,
                                color: Theme.of(context).primaryColor,
                              )
                            : ClipOval(
                                child: FittedBox(
                                fit: BoxFit.cover,
                                child: Image.file(
                                  File(imageLocation.value),
                                ),
                              ))),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: new Container(
                        padding: EdgeInsets.all(8),
                        decoration: new BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          border: Border.all(
                            width: 3,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: <Widget>[
          ElevatedButton(
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
        ],
      ),
      body: bodyWidget,
    );
  }
}
