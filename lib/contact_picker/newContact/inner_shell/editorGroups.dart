import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/curvedCorner.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../newContactPage.dart';
import 'fieldEditor.dart';
import 'specialField.dart';

class NamesEditor extends StatelessWidget {
  const NamesEditor({
    Key key,
    @required this.namesSpread,
    @required this.bottomBarHeight,
    @required this.nameField,
    @required this.nameRows,
  }) : super(key: key);

  final ValueNotifier<bool> namesSpread;
  final double bottomBarHeight;
  final FieldData nameField;
  final List<Widget> nameRows;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: (namesSpread.value == false),
          child: TheField(
            label: "Name",
            bottomBarHeight: bottomBarHeight,
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
          ),
        ),
        Visibility(
          visible: (namesSpread.value == true),
          child: IntrinsicHeight(
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
          ),
        ),
      ],
    );
  }
}

class PhoneNumbersEditor extends StatelessWidget {
  const PhoneNumbersEditor({
    Key key,
    @required this.phoneRows,
    @required this.addPhone,
  }) : super(key: key);

  final List<Widget> phoneRows;
  final Function addPhone;

  @override
  Widget build(BuildContext context) {
    return StickyHeader(
      header: (phoneRows.length > 0)
          ? Title(
              icon: Icons.phone,
              name: "Phone Number" + (phoneRows.length > 1 ? "s" : ""),
            )
          : Container(),
      content: Column(
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
    @required this.emailRows,
    @required this.addEmail,
  }) : super(key: key);

  final List<Widget> emailRows;
  final Function addEmail;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: emailRows.length > 0,
          child: Title(
            icon: Icons.email,
            name: "Email" + (emailRows.length > 1 ? "s" : ""),
          ),
        ),
        Column(
          children: emailRows,
        ),
        FieldAdder(
          add: addEmail,
          fieldName: "email address",
        ),
      ],
    );
  }
}

class WorkEditor extends StatelessWidget {
  const WorkEditor({
    Key key,
    @required this.workOpen,
    @required this.jobTitleField,
    @required this.bottomBarHeight,
    @required this.companyField,
  }) : super(key: key);

  final ValueNotifier<bool> workOpen;
  final FieldData jobTitleField;
  final double bottomBarHeight;
  final FieldData companyField;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: workOpen.value,
          child: Column(
            children: <Widget>[
              Title(
                icon: Icons.work,
                name: "Work",
              ),
              TheField(
                focusNode: jobTitleField.focusNode,
                textEditingController: jobTitleField.controller,
                bottomBarHeight: bottomBarHeight,
                nextFunction: jobTitleField.nextFunction,
                label: "Job title",
              ),
              TheField(
                focusNode: companyField.focusNode,
                textEditingController: companyField.controller,
                bottomBarHeight: bottomBarHeight,
                nextFunction: companyField.nextFunction,
                label: "Company",
              ),
            ],
          ),
        ),
        Visibility(
          visible: workOpen.value == false,
          child: FieldAdder(
            add: () {
              workOpen.value = true;
            },
            fieldName: "job title or company",
          ),
        ),
      ],
    );
  }
}

class AddressesEditor extends StatelessWidget {
  const AddressesEditor({
    Key key,
    @required this.addressRows,
    @required this.addAddress,
  }) : super(key: key);

  final List<Widget> addressRows;
  final Function addAddress;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: addressRows.length > 0,
          child: Title(
            icon: Icons.location_on,
            name: "Address" + (addressRows.length > 1 ? "es" : ""),
          ),
        ),
        Column(
          children: addressRows,
        ),
        FieldAdder(
          add: addAddress,
          fieldName: "address",
        ),
      ],
    );
  }
}

//--------------------------------------------------
//--------------------------------------------------
//Helper Widgets
//--------------------------------------------------
//--------------------------------------------------

class Title extends StatelessWidget {
  final IconData icon;
  final String name;

  const Title({
    @required this.icon,
    @required this.name,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 48,
          width: MediaQuery.of(context).size.width,
          color: Colors.black,
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: 8,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    icon,
                    //hidden for now
                    color: Colors.transparent,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(0, -24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CurvedCorner(
                isTop: false,
                isLeft: true,
                cornerColor: Colors.black,
                size: 24,
              ),
              CurvedCorner(
                isTop: false,
                isLeft: false,
                cornerColor: Colors.black,
                size: 24,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FieldAdder extends StatelessWidget {
  const FieldAdder({
    @required this.add,
    @required this.fieldName,
    Key key,
  }) : super(key: key);

  final Function add;
  final String fieldName;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => add(),
        child: Row(
          children: [
            RightIconButton(
              onLeft: true,
              iconData: Icons.add,
              color: Colors.green,
            ),
            Expanded(
              child: Text(
                "add a " + fieldName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
