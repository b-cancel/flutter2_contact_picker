import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/categories/categoryUI.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../categories/categoryData.dart';
import '../newContactPage.dart';
import 'editorGroups.dart';
import 'specialField.dart';

//phones, emails, work (job title, company), addresses, note

double titleRightPadding = 16;
double iconRightPadding = 32;

class NewContactEditFields extends StatelessWidget {
  NewContactEditFields({
    @required this.bottomBarHeight,
    @required this.namesSpread,
    //handle names
    @required this.nameField,
    @required this.nameFields,
    @required this.nameLabels,
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

  final double bottomBarHeight;
  final ValueNotifier<bool> namesSpread;
  //handle names
  final FieldData nameField;
  final List<FieldData> nameFields;
  final List<String> nameLabels;
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
    //create all the needed rows
    List<Widget> nameRows = [];
    for (int i = 0; i < nameLabels.length; i++) {
      FieldData thisField = nameFields[i];
      nameRows.add(
        TheField(
          bottomBarHeight: bottomBarHeight,
          focusNode: thisField.focusNode,
          textEditingController: thisField.controller,
          nextFunction: thisField.nextFunction,
          label: nameLabels[i],
          noPadding: true,
        ),
      );
    }

    //create all needed phone rows
    List<Widget> phoneRows = [];
    for (int i = 0; i < phoneFields.length; i++) {
      FieldData thisField = phoneFields[i];
      phoneRows.add(
        TheField(
          focusNode: thisField.focusNode,
          textEditingController: thisField.controller,
          bottomBarHeight: bottomBarHeight,
          nextFunction: thisField.nextFunction,
          label: "Phone",
          labelField: CategorySelector(
            labelType: LabelType.phone,
            labelSelected: phoneLabels[i],
          ),
          rightIconButton: RightIconButton(
            onTapped: () => removePhone(i),
            iconData: FontAwesomeIcons.minus,
            color: Colors.red,
            size: 16,
          ),
          textInputType: TextInputType.phone,
        ),
      );
    }

    //create all needed email rows
    List<Widget> emailRows = [];
    for (int i = 0; i < emailFields.length; i++) {
      FieldData thisField = emailFields[i];
      emailRows.add(
        TheField(
          focusNode: thisField.focusNode,
          textEditingController: thisField.controller,
          bottomBarHeight: bottomBarHeight,
          nextFunction: thisField.nextFunction,
          label: "Email",
          labelField: CategorySelector(
            labelType: LabelType.email,
            labelSelected: emailLabels[i],
          ),
          rightIconButton: RightIconButton(
            onTapped: () => removeEmail(i),
            iconData: FontAwesomeIcons.minus,
            color: Colors.red,
            size: 16,
          ),
          textInputType: TextInputType.emailAddress,
        ),
      );
    }

    List<Widget> addressRows = [];
    for (int i = 0; i < addressStreetFields.length; i++) {
      addressRows.add(
        AddressField(
          addressStuff: [
            addressStreetFields[i],
            addressCityFields[i],
            addressPostcodeFields[i],
            addressRegionFields[i],
            addressCountryFields[i],
          ],
          //other
          bottomBarHeight: bottomBarHeight,
          removeTheAddress: () {
            removeAddress(i);
          },
          addressLabel: addressLabels[i],
        ),
      );
    }

    //build
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        NamesEditor(
          namesSpread: namesSpread,
          bottomBarHeight: bottomBarHeight,
          nameField: nameField,
          nameRows: nameRows,
        ),
        PhoneNumbersEditor(
          phoneRows: phoneRows,
          addPhone: addPhone,
        ),
        EmailsEditor(
          emailRows: emailRows,
          addEmail: addEmail,
        ),
        WorkEditor(
          workOpen: workOpen,
          jobTitleField: jobTitleField,
          bottomBarHeight: bottomBarHeight,
          companyField: companyField,
        ),
        AddressesEditor(
          addressRows: addressRows,
          addAddress: addAddress,
        ),
      ],
    );
  }
}

class RightIconButton extends StatelessWidget {
  RightIconButton({
    @required this.iconData,
    @required this.color,
    this.onTapped,
    this.size,
    this.onLeft: false,
  });

  final IconData iconData;
  final Color color;
  final Function onTapped;
  final double size;
  final bool onLeft;

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      //color: Colors.grey,
      height: 8 + 8 + 32.0,
      padding: EdgeInsets.symmetric(
        horizontal: onLeft ? titleRightPadding : iconRightPadding,
        vertical: 0,
      ),
      child: SizedBox(
        width: 24,
        height: 24,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              iconData,
              color: Colors.white,
              size: size,
            ),
          ),
        ),
      ),
    );

    //button or no button
    if (onTapped == null) {
      return child;
    } else {
      return InkWell(
        onTap: onTapped,
        child: child,
      );
    }
  }
}

//-------------------------ADDRESS FIELDS-------------------------(extension of TheField class)
List<String> addressLabels = [
  "Street",
  "City",
  "Postal Code",
  "Region",
  "Country"
];

class AddressField extends StatelessWidget {
  const AddressField({
    @required this.addressStuff,
    //other
    @required this.bottomBarHeight,
    @required this.addressLabel,
    @required this.removeTheAddress,
  });

  final List<FieldData> addressStuff;
  //other
  final double bottomBarHeight;
  final ValueNotifier<String> addressLabel;
  final Function removeTheAddress;

  @override
  Widget build(BuildContext context) {
    List<Widget> fields = [];
    for (int i = 0; i < 5; i++) {
      FieldData thisField = addressStuff[i];
      fields.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: (i == 4) ? 0 : 12,
          ),
          child: TextFormField(
            focusNode: thisField.focusNode,
            controller: thisField.controller,
            scrollPadding: EdgeInsets.only(
              bottom: bottomBarHeight * 2 + 8,
            ),
            style: TextStyle(
              fontSize: 18,
            ),
            onEditingComplete: () => thisField.nextFunction(),
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(bottom: 4),
              hintText: addressLabels[i],
              hintStyle: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      //color: Colors.purple,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: fields,
              ),
            ),
          ),
          CategorySelector(
            labelType: LabelType.address,
            labelSelected: addressLabel,
          ),
          RightIconButton(
            onTapped: () => removeTheAddress(),
            iconData: FontAwesomeIcons.minus,
            color: Colors.red,
            size: 16,
          ),
        ],
      ),
    );
  }
}
