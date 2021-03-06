import 'package:flutter/material.dart';
import '../../../contact_picker/newContact/inner_shell/addressEditor.dart';
import '../../../contact_picker/newContact/inner_shell/otherEditors.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import '../newContactPage.dart';
import 'avatarEditor.dart';
import 'editorHelpers.dart';

class ScrollableEditor extends StatelessWidget {
  ScrollableEditor({
    @required this.portraitMode,
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

  final bool portraitMode;

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
        SliverToBoxAdapter(
          child: portraitMode
              ? Container()
              : PhoneNumbersHeader(phoneFields: phoneFields),
        ),
        SliverStickyHeader(
          header: portraitMode
              ? PhoneNumbersHeader(phoneFields: phoneFields)
              : Container(),
          sliver: SliverToBoxAdapter(
            child: PhoneNumbersEditor(
              addPhone: addPhone,
              removePhone: removePhone,
              phoneFields: phoneFields,
              phoneLabels: phoneLabels,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: portraitMode
              ? Container()
              : EmailsHeader(emailFields: emailFields),
        ),
        SliverStickyHeader(
          header: portraitMode
              ? EmailsHeader(emailFields: emailFields)
              : Container(),
          sliver: SliverToBoxAdapter(
            child: EmailsEditor(
              addEmail: addEmail,
              removeEmail: removeEmail,
              emailFields: emailFields,
              emailLabels: emailLabels,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: portraitMode ? Container() : WorkHeader(),
        ),
        SliverStickyHeader(
          header: portraitMode ? WorkHeader() : Container(),
          sliver: SliverToBoxAdapter(
            child: WorkEditor(
              jobTitleField: jobTitleField,
              companyField: companyField,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: portraitMode
              ? Container()
              : AddressHeader(addressStreetFields: addressStreetFields),
        ),
        SliverStickyHeader(
          header: portraitMode
              ? AddressHeader(addressStreetFields: addressStreetFields)
              : Container(),
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

class AddressHeader extends StatelessWidget {
  const AddressHeader({
    Key key,
    @required this.addressStreetFields,
  }) : super(key: key);

  final List<FieldData> addressStreetFields;

  @override
  Widget build(BuildContext context) {
    return SectionTitle(
      rightIcon: Icons.location_on,
      name: "Address" + (addressStreetFields.length == 1 ? "" : "es"),
    );
  }
}

class WorkHeader extends StatelessWidget {
  const WorkHeader({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SectionTitle(
      rightIcon: Icons.work,
      name: "Work",
    );
  }
}

class EmailsHeader extends StatelessWidget {
  const EmailsHeader({
    Key key,
    @required this.emailFields,
  }) : super(key: key);

  final List<FieldData> emailFields;

  @override
  Widget build(BuildContext context) {
    return SectionTitle(
      rightIcon: Icons.email,
      name: "Email" + (emailFields.length == 1 ? "" : "s"),
    );
  }
}

class PhoneNumbersHeader extends StatelessWidget {
  const PhoneNumbersHeader({
    Key key,
    @required this.phoneFields,
  }) : super(key: key);

  final List<FieldData> phoneFields;

  @override
  Widget build(BuildContext context) {
    return SectionTitle(
      rightIcon: Icons.phone,
      name: "Phone Number" + (phoneFields.length == 1 ? "" : "s"),
    );
  }
}
