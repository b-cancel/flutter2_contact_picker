import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/newContact/inner_shell/addressEditor.dart';
import 'package:flutter2_contact_picker/contact_picker/newContact/inner_shell/otherEditors.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import '../newContactPage.dart';
import 'avatarEditor.dart';
import 'editorHelpers.dart';

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
    //prep vars
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double smaller = screenHeight < screenWidth ? screenHeight : screenWidth;
    double imageDiameter = smaller / 2;

    //build
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
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(
                    0,
                    //push CARD CONTENT down to past the picture
                    imageDiameter * (2 / 7) + 16 * 2,
                    0,
                    0,
                  ),
                  child: NameEditor(
                    namesSpread: namesSpread,
                    nameField: nameField,
                    nameFields: nameFields,
                    nameLabels: nameLabels,
                  ),
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
        SliverStickyHeader(
          header: SectionTitle(
            rightIcon: Icons.phone,
            name: "Phone Number" + (phoneFields.length == 1 ? "" : "s"),
          ),
          sliver: SliverToBoxAdapter(
            child: PhoneNumbersEditor(
              addPhone: addPhone,
              removePhone: removePhone,
              phoneFields: phoneFields,
              phoneLabels: phoneLabels,
            ),
          ),
        ),
        SliverStickyHeader(
          header: SectionTitle(
            rightIcon: Icons.email,
            name: "Email" + (emailFields.length == 1 ? "" : "s"),
          ),
          sliver: SliverToBoxAdapter(
            child: EmailsEditor(
              addEmail: addEmail,
              removeEmail: removeEmail,
              emailFields: emailFields,
              emailLabels: emailLabels,
            ),
          ),
        ),
        SliverStickyHeader(
          header: SectionTitle(
            rightIcon: Icons.work,
            name: "Work",
          ),
          sliver: SliverToBoxAdapter(
            child: WorkEditor(
              jobTitleField: jobTitleField,
              companyField: companyField,
            ),
          ),
        ),
        SliverStickyHeader(
          header: SectionTitle(
            rightIcon: Icons.location_on,
            name: "Address" + (addressStreetFields.length == 1 ? "" : "es"),
          ),
          sliver: SliverToBoxAdapter(
            child: AddressesEditor(
              addAddress: addAddress,
              removeAddress: removeAddress,
              addressStreetAddressFields: addressStreetFields,
              addressCityFields: addressCityFields,
              addressPostcodeFields: addressPostcodeFields,
              addressRegionFields: addressRegionFields,
              addressCountryFields: addressCountryFields,
              addressLabels: addressLabels,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            height: 56,
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
    );
  }
}
