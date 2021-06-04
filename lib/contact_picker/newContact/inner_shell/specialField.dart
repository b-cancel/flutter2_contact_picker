import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/customField.dart';

import 'fieldEditor.dart';

class TheField extends StatelessWidget {
  const TheField({
    this.label,
    @required this.focusNode,
    @required this.textEditingController,
    @required this.nextFunction,
    @required this.bottomBarHeight,
    this.labelField,
    this.rightIconButton,
    this.noPadding: false,
    this.textInputType: TextInputType.text,
    this.isRequired: false,
  });

  final String label;
  final FocusNode focusNode;
  final TextEditingController textEditingController;
  final Function nextFunction;
  final double bottomBarHeight;
  final Widget labelField;
  final Widget rightIconButton;
  final bool noPadding;
  final TextInputType textInputType;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.purple,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Flexible(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: (rightIconButton == null)
                      ? ((noPadding) ? 0 : iconRightPadding)
                      : 0,
                ),
                child: CustomField(
                  focusNode: focusNode,
                  textEditingController: textEditingController,
                  textInputType: textInputType,
                  notMultilineInputAction: (nextFunction == null)
                      ? TextInputAction.done
                      : TextInputAction.next,

                  label: label,
                  errorOnEmptyField: isRequired,
                  showClearRegardlessOfFocus: false,
                  //TODO: might need to fix
                  autofocus: true, //unknown how this was working
                  onEditingComplete: (nextFunction == null)
                      ? null
                      : () {
                          nextFunction();
                        },
                ),

                /*TextFormField(
                  scrollPadding:
                      EdgeInsets.only(bottom: bottomBarHeight * 2 + 8),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 4),
                    hintText: label,
                    hintStyle: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),*/
              ),
            ),
          ),
          labelField ?? Container(),
          rightIconButton ?? Container(),
        ],
      ),
    );
  }
}
