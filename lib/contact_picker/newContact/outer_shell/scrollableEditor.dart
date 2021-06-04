import 'package:flutter/material.dart';

import '../newContactPage.dart';
import 'avatarEditor.dart';

class ScrollableEditor extends StatelessWidget {
  ScrollableEditor({
    @required this.imageLocation,
    //handle names
    @required this.nameField,
    @required this.nameFields,
    @required this.nameLabels,
    @required this.namesSpread,
    //phones
    @required this.addPhone,
    @required this.removePhone,
    @required this.phoneFields,
    @required this.phoneLabels,
    //email
    @required this.addEmail,
    @required this.removeEmail,
    @required this.emailFields,
    @required this.emailLabels,
    //handle work
    @required this.jobTitleField,
    @required this.companyField,
    @required this.workOpen,
    //address
    @required this.addAddress,
    @required this.removeAddress,
    @required this.addressStreetFields,
    @required this.addressCityFields,
    @required this.addressPostcodeFields,
    @required this.addressRegionFields,
    @required this.addressCountryFields,
    @required this.addressLabels,
  });

  final ValueNotifier<String> imageLocation;

  //handle names
  final FieldData nameField;
  final List<FieldData> nameFields;
  final List<String> nameLabels;
  final ValueNotifier<bool> namesSpread;
  //phones
  final Function addPhone;
  final Function removePhone;
  final List<FieldData> phoneFields;
  final List<ValueNotifier<String>> phoneLabels;
  //emails
  final Function addEmail;
  final Function removeEmail;
  final List<FieldData> emailFields;
  final List<ValueNotifier<String>> emailLabels;
  //handle work
  final FieldData jobTitleField;
  final FieldData companyField;
  final ValueNotifier<bool> workOpen;
  //address
  final Function addAddress;
  final Function removeAddress;
  final List<FieldData> addressStreetFields;
  final List<FieldData> addressCityFields;
  final List<FieldData> addressPostcodeFields;
  final List<FieldData> addressRegionFields;
  final List<FieldData> addressCountryFields;
  final List<ValueNotifier<String>> addressLabels;

  @override
  Widget build(BuildContext context) {
    double curvature = 24;
    return OrientationBuilder(builder: (context, orientation) {
      bool isPortrait = (orientation == Orientation.portrait);

      //calc bottom bar height
      double bottomBarHeight = 32;
      if (isPortrait == false) bottomBarHeight = 0;

      //calc imageDiameter
      double imageDiameter = MediaQuery.of(context).size.width / 2;
      if (isPortrait == false) {
        imageDiameter = MediaQuery.of(context).size.height / 2;
      }

      return CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: <Widget>[
                //shifted down so the picture can be slightly on top
                Container(
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
                          child: NewContactEditFields(
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
                        ),
                      ),
                    ],
                  ),
                ),
                //is slightly on top of fields editor
                AvatarEditor(
                  imageLocation: imageLocation,
                  imageDiameter: imageDiameter,
                ),
              ],
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
      );
    });
  }
}
