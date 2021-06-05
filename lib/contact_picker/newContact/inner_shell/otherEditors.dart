import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/categories/categoryData.dart';
import 'package:flutter2_contact_picker/contact_picker/categories/categoryUI.dart';
import 'package:flutter2_contact_picker/contact_picker/newContact/inner_shell/specialField.dart';
import 'package:flutter2_contact_picker/contact_picker/newContact/outer_shell/editorHelpers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../newContactPage.dart';

class NameEditor extends StatelessWidget {
  const NameEditor({
    @required this.namesSpread,
    @required this.nameField,
    @required this.nameFields,
    @required this.nameLabels,
    Key key,
  }) : super(key: key);

  final ValueNotifier<bool> namesSpread;
  final FieldData nameField;
  final List<FieldData> nameFields;
  final List<String> nameLabels;

  @override
  Widget build(BuildContext context) {
    //create all the needed rows
    List<Widget> nameRows = [];
    for (int i = 0; i < nameLabels.length; i++) {
      FieldData thisField = nameFields[i];
      nameRows.add(
        TheField(
          focusNode: thisField.focusNode,
          textEditingController: thisField.controller,
          nextFunction: thisField.nextFunction,
          label: nameLabels[i],
          noPadding: true,
        ),
      );
    }

    if (namesSpread.value) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                children: nameRows,
              ),
            ),
            Container(
              child: InkWell(
                onTap: () {
                  namesSpread.value = false;
                },
                child: Container(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 16,
                    ),
                    child: RightIconButton(
                      iconData: Icons.keyboard_arrow_up,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return TheField(
        label: "Name",
        focusNode: nameField.focusNode,
        textEditingController: nameField.controller,
        nextFunction: nameField.nextFunction,
        rightIconButton: RightIconButton(
          onTapped: () {
            namesSpread.value = true;
          },
          iconData: Icons.keyboard_arrow_down,
          color: Colors.black,
        ),
      );
    }
  }
}

class PhoneNumbersEditor extends StatelessWidget {
  const PhoneNumbersEditor({
    Key key,
    @required this.addPhone,
    @required this.removePhone,
    @required this.phoneFields,
    @required this.phoneLabels,
  }) : super(key: key);

  final Function addPhone;
  final Function removePhone;
  final List<FieldData> phoneFields;
  final List<ValueNotifier<String>> phoneLabels;

  @override
  Widget build(BuildContext context) {
    //create all needed phone rows
    List<Widget> phoneRows = [];
    for (int i = 0; i < phoneFields.length; i++) {
      FieldData thisField = phoneFields[i];
      phoneRows.add(
        TheField(
          focusNode: thisField.focusNode,
          textEditingController: thisField.controller,
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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: phoneRows,
          ),
          FieldAdder(
            add: addPhone,
            fieldName: "phone number",
          ),
        ],
      ),
    );
  }
}

class EmailsEditor extends StatelessWidget {
  const EmailsEditor({
    Key key,
    @required this.addEmail,
    @required this.removeEmail,
    @required this.emailFields,
    @required this.emailLabels,
  }) : super(key: key);

  final Function addEmail;
  final Function removeEmail;
  final List<FieldData> emailFields;
  final List<ValueNotifier<String>> emailLabels;

  @override
  Widget build(BuildContext context) {
    //create all needed email rows
    List<Widget> emailRows = [];
    for (int i = 0; i < emailFields.length; i++) {
      FieldData thisField = emailFields[i];
      emailRows.add(
        TheField(
          focusNode: thisField.focusNode,
          textEditingController: thisField.controller,
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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: emailRows,
          ),
          FieldAdder(
            add: addEmail,
            fieldName: "email address",
          ),
        ],
      ),
    );
  }
}

class WorkEditor extends StatelessWidget {
  const WorkEditor({
    Key key,
    @required this.jobTitleField,
    @required this.companyField,
  }) : super(key: key);

  final FieldData jobTitleField;
  final FieldData companyField;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
      ),
      child: Column(
        children: <Widget>[
          TheField(
            focusNode: jobTitleField.focusNode,
            textEditingController: jobTitleField.controller,
            nextFunction: jobTitleField.nextFunction,
            label: "Job title",
          ),
          TheField(
            focusNode: companyField.focusNode,
            textEditingController: companyField.controller,
            nextFunction: companyField.nextFunction,
            label: "Company",
          ),
        ],
      ),
    );
  }
}