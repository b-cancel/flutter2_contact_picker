import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/customField.dart';

class TheField extends StatelessWidget {
  const TheField({
    this.label,
    @required this.focusNode,
    @required this.textEditingController,
    @required this.nextFunction,
    this.labelField,
    this.leftIconButton,
    this.rightIconButton,
    this.textInputType: TextInputType.text,
  });

  final String label;
  final FocusNode focusNode;
  final TextEditingController textEditingController;
  final Function nextFunction;
  final Widget labelField;
  final Widget leftIconButton;
  final Widget rightIconButton;
  final TextInputType textInputType;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        leftIconButton ?? Container(),
        labelField ?? Container(),
        Flexible(
          child: CustomField(
            focusNode: focusNode,
            textEditingController: textEditingController,
            textInputType: textInputType,
            notMultilineInputAction: (nextFunction == null)
                ? TextInputAction.done
                : TextInputAction.next,

            label: label,
            errorOnEmptyField: false,
            showClearRegardlessOfFocus: false,
            //TODO: might need to fix
            autofocus: true, //unknown how this was working
            onEditingComplete: (nextFunction == null)
                ? null
                : () {
                    nextFunction();
                  },
          ),
        ),
        rightIconButton ?? Container(),
      ],
    );
  }
}
