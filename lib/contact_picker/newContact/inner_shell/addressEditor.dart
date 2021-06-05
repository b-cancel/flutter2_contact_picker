import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/categories/categoryData.dart';
import 'package:flutter2_contact_picker/contact_picker/categories/categoryUI.dart';
import 'package:flutter2_contact_picker/contact_picker/newContact/outer_shell/editorHelpers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../newContactPage.dart';

class AddressesEditor extends StatelessWidget {
  const AddressesEditor({
    Key key,
    @required this.addAddress,
    @required this.removeAddress,
    @required this.addressStreetFields,
    @required this.addressCityFields,
    @required this.addressPostcodeFields,
    @required this.addressRegionFields,
    @required this.addressCountryFields,
    @required this.addressLabels,
  }) : super(key: key);

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
    List<Widget> addressRows = [];
    for (int i = 0; i < addressStreetFields.length; i++) {
      addressRows.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: 12,
          ),
          child: AddressField(
            addressStuff: [
              addressStreetFields[i],
              addressCityFields[i],
              addressPostcodeFields[i],
              addressRegionFields[i],
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
            bottom: (i == 4) ? 0 : 12,
          ),
          //TODO: replace this
          child: TextFormField(
            focusNode: thisField.focusNode,
            controller: thisField.controller,
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
          FieldIconButton(
            onTapped: () => removeTheAddress(),
            iconData: FontAwesomeIcons.minus,
            color: Colors.red,
            iconSize: 16,
          ),
        ],
      ),
    );
  }
}
