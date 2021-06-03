import 'dart:io';
import 'package:flutter/material.dart';
import 'imagePicker.dart';

class NewContactAppBarAndHeader extends StatelessWidget {
  NewContactAppBarAndHeader({
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Cancel'),
        actions: <Widget>[
          Center(
            child: Hero(
              tag: 'contacts',
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
        ],
      ),
      body: Theme(
        data: ThemeData.light(),
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                children: <Widget>[
                  //shifted down so the picture can be slightly on top
                  FieldsEditor(
                    imageDiameter: imageDiameter,
                    fields: fields,
                  ),
                  //is slightly on top of fields editor
                  AvatarEditor(
                    imageLocation: imageLocation,
                    imageDiameter: imageDiameter,
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 16,
                width: MediaQuery.of(context).size.width,
                color: ThemeData.dark().primaryColor,
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: true,
              child: Container(
                color: ThemeData.dark().primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FieldsEditor extends StatelessWidget {
  const FieldsEditor({
    Key key,
    @required this.imageDiameter,
    @required this.fields,
  }) : super(key: key);

  final double imageDiameter;
  final Widget fields;

  @override
  Widget build(BuildContext context) {
    double curvature = 24;
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(
        0,
        //push CARD down to the ABOUT middle of the picture
        imageDiameter * (5 / 7),
        0,
        0,
      ),
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: ThemeData.dark().primaryColor,
              height: curvature,
            ),
          ),
          Card(
            margin: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(curvature),
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
    );
  }
}

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
        },
        child: Stack(
          children: <Widget>[
            new Container(
              width: imageDiameter,
              height: imageDiameter,
              decoration: new BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: (imageLocation.value == "")
                  ? Icon(
                      Icons.camera_alt,
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
