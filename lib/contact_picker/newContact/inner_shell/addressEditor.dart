import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/categories/categoryData.dart';
import 'package:flutter2_contact_picker/contact_picker/categories/categoryUI.dart';
import 'package:flutter2_contact_picker/contact_picker/newContact/inner_shell/specialField.dart';
import 'package:flutter2_contact_picker/contact_picker/newContact/outer_shell/editorHelpers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../newContactPage.dart';

class AddressesEditor extends StatelessWidget {
  const AddressesEditor({
    Key key,
    @required this.addAddress,
    @required this.removeAddress,
    @required this.addressStreetAddressFields,
    @required this.addressCityFields,
    @required this.addressPostcodeFields,
    @required this.addressRegionFields,
    @required this.addressCountryFields,
    @required this.addressLabels,
  }) : super(key: key);

  final Function addAddress;
  final Function removeAddress;
  final List<FieldData> addressStreetAddressFields;
  final List<FieldData> addressCityFields;
  final List<FieldData> addressPostcodeFields;
  final List<FieldData> addressRegionFields;
  final List<FieldData> addressCountryFields;
  final List<ValueNotifier<String>> addressLabels;

  @override
  Widget build(BuildContext context) {
    List<Widget> addressRows = [];
    for (int i = 0; i < addressStreetAddressFields.length; i++) {
      addressRows.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: 16, //on top of the 12 below every field
          ),
          child: AddressField(
            addressStuff: [
              addressStreetAddressFields[i],
              addressCityFields[i],
              addressRegionFields[i],
              addressPostcodeFields[i],
              addressCountryFields[i],
            ],
            //other
            removeTheAddress: () {
              removeAddress(i);
            },
            addressLabel: addressLabels[i],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: Container(
                  color: ThemeData.dark().primaryColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: addressRows.length > 0 ? 16 : 0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: addressRows,
                ),
                FieldAdder(
                  add: addAddress,
                  fieldName: "address",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

//-------------------------ADDRESS FIELDS-------------------------(extension of TheField class)
List<String> addressLabels = [
  "Street Address",
  "City",
  "Region",
  "Postal Code",
  "Country"
];

class AddressField extends StatelessWidget {
  const AddressField({
    @required this.addressStuff,
    //other
    @required this.addressLabel,
    @required this.removeTheAddress,
  });

  final List<FieldData> addressStuff;
  //other
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
            bottom: 12,
          ),
          child: TheField(
            focusNode: thisField.focusNode,
            textEditingController: thisField.controller,
            nextFunction: () => thisField.nextFunction(),
            label: addressLabels[i],
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
          FieldIconButton(
            onTapped: () => removeTheAddress(),
            iconData: FontAwesomeIcons.minus,
            color: Colors.red,
            iconSize: 16,
          ),
          CategorySelector(
            labelType: LabelType.address,
            labelSelected: addressLabel,
          ),
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(
                right: 16,
              ),
              child: Column(
                children: fields,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
