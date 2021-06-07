import 'dart:io';

import 'package:flutter/material.dart';

import 'imagePicker.dart';

class AvatarEditor extends StatelessWidget {
  const AvatarEditor({
    Key key,
    @required this.imageLocation,
    @required this.imageDiameter,
  }) : super(key: key);

  final ValueNotifier<String> imageLocation;
  final double imageDiameter;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () async {
          if (Platform.isAndroid) {
            //TODO: eventually remove this
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
                content: Text(
                  "Android Related Error: Switch to iOS",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            );
          } else {
            //request a new image location
            String newImageLocation = await changeImage(
              context,
              imageExists: (imageLocation.value.length > 0),
            );

            //update the image location
            //if a new one was passed
            if (newImageLocation != null) {
              imageLocation.value = newImageLocation;
            }
          }
        },
        child: Stack(
          children: <Widget>[
            AnimatedBuilder(
              animation: imageLocation,
              builder: (context, snapshot) {
                return Container(
                  width: imageDiameter,
                  height: imageDiameter,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: (imageLocation.value == "")
                      ? Icon(
                          Icons.person,
                          size: imageDiameter / 2,
                          color: Colors.white,
                        )
                      : ClipOval(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: Image.file(
                              File(imageLocation.value),
                            ),
                          ),
                        ),
                );
              },
            ),
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
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
