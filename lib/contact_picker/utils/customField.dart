import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Color defaultColor = Colors.black;
Color errorColor = Colors.red;
Color warningColor = Colors.orange;

class CustomField extends StatefulWidget {
  const CustomField({
    Key key,
    this.extraScrollPadding: false,
    @required this.focusNode,
    this.onSubmitted,
    this.onEditingComplete,
    @required this.autofocus,
    @required this.textEditingController,
    this.startInitialValue,
    this.hintBorder,
    this.label,
    @required this.errorOnEmptyField,
    @required this.showClearRegardlessOfFocus,
    this.onClear,
    this.onUndo,

    ///[TextInputType.datetime => best time to contact (keyboard with ':' and '-')]
    ///[TextInputType.phone => homeowner number]
    ///[TextInputType.emailAddress => homeowner email]
    ///[TextInputType.multiline => notes]
    ///[TextInputType.name => keyboard optimized for name or phone number]
    ///[TextInputType.number => the number]
    ///[TextInputType.streetAddress => keyboard optimized for postal address]
    ///[TextInputType.text => default]
    @required this.textInputType,
    @required this.notMultilineInputAction,
    this.showSaveButton: false,
    //false only for 2 main fields, building number and street name
    this.canSaveEmpty: true,
  }) : super(key: key);

  final bool extraScrollPadding;
  final FocusNode focusNode;
  final Function onSubmitted;
  final Function onEditingComplete;
  final bool autofocus;
  final TextEditingController textEditingController;
  final String startInitialValue;
  final ValueNotifier<Color> hintBorder;
  final String label;

  //if false, show
  final bool errorOnEmptyField;
  final bool showClearRegardlessOfFocus;
  final Function onClear;
  final Function onUndo;
  final bool showSaveButton;
  final bool canSaveEmpty;

  ///TextInputType.datetime, => best time to contact (keyboard with ':' and '-')
  ///TextInputType.phone, => homeowner number
  ///TextInputType.emailAddress, => homeowner email
  ///TextInputType.multiline, => notes
  ///TextInputType.name, => keyboard optimized for name or phone number
  ///TextInputType.number, => the number
  ///TextInputType.streetAddress, => keyboard optimized for postal address
  final TextInputType textInputType;
  final TextInputAction notMultilineInputAction;

  @override
  _CustomFieldState createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  String currInitialValue;
  //these two don't allways match, although it may seem like they do or should
  ValueNotifier<bool> fieldCleared = new ValueNotifier(false);
  ValueNotifier<bool> allowClearField = new ValueNotifier(true);

  updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    //inits
    if (widget.startInitialValue != null) {
      widget.textEditingController.text = widget.startInitialValue;
    }
    currInitialValue = widget.textEditingController.text;
    fieldCleared.value =
        (currInitialValue == null || currInitialValue.length == 0);
    allowClearField.value = (fieldCleared.value == false);

    //listeners
    widget.textEditingController.addListener(textChanged);
    fieldCleared.addListener(updateState);
    allowClearField.addListener(updateState);
    if (widget.errorOnEmptyField == false ||
        widget.showClearRegardlessOfFocus == false ||
        widget.showSaveButton) {
      widget.focusNode.addListener(updateState);
    }
    if (widget.hintBorder != null) {
      widget.hintBorder.addListener(updateState);
    }

    //super init
    super.initState();
  }

  @override
  void dispose() {
    //remove listeners
    widget.textEditingController.removeListener(textChanged);
    fieldCleared.removeListener(updateState);
    allowClearField.removeListener(updateState);
    if (widget.errorOnEmptyField == false ||
        widget.showClearRegardlessOfFocus == false ||
        widget.showSaveButton) {
      widget.focusNode.removeListener(updateState);
    }
    if (widget.hintBorder != null) {
      widget.hintBorder.removeListener(updateState);
    }

    //super dispose
    super.dispose();
  }

  textChanged() {
    String newString = widget.textEditingController.text;

    //if normal change
    //error handling
    bool newStringIsEmpty = (newString == null || newString.length == 0);
    fieldCleared.value = newStringIsEmpty;

    //clear or undo
    bool initialExists = currInitialValue.length > 0 ||
        (currInitialValue.length == 0 && widget.canSaveEmpty);
    if (initialExists) {
      //if initial value exists
      //allow clear IF undo isn't possible
      //AND field isn't empty
      if (currInitialValue.length > 0) {
        allowClearField.value = (newString == currInitialValue);
      } else {
        //(currInitialValue.length == 0 && widget.canSaveEmpty)
        allowClearField.value =
            (newString == currInitialValue) && (newStringIsEmpty == false);
      }
    } else {
      //no initial value exists
      //so allow clear field as long as the field isn't empty
      allowClearField.value = (newStringIsEmpty == false);
    }
  }

  newNormal() {
    currInitialValue = widget.textEditingController.text;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //button mode IF field empty (regardless of whether canSaveEmpty)
    //&& widget.errorOnEmptyField == false
    //& we don't have focus
    bool buttonMode = false;
    if (widget.textEditingController.text == null ||
        widget.textEditingController.text.length == 0) {
      if (widget.errorOnEmptyField == false) {
        if (widget.focusNode.hasFocus == false) {
          buttonMode = true;
        }
      }
    }

    //!NOTE: nothing is technically still an init value IF you can save empty
    //initvalue will never be null here
    bool initialValueExists = currInitialValue.length > 0 ||
        (currInitialValue.length == 0 && widget.canSaveEmpty);
    Widget suffixIcon;
    if (allowClearField.value) {
      bool allwaysAllowClear = widget.showClearRegardlessOfFocus;
      if (allwaysAllowClear ||
          (allwaysAllowClear == false && widget.focusNode.hasFocus)) {
        suffixIcon = IconButton(
          icon: Icon(
            Icons.clear,
          ),
          onPressed: () {
            widget.textEditingController.clear();
            widget.onClear();
          },
        );
      }
    } else {
      //TODO: fix issue where we are showing the undo button into nothing
      //case 1: field started null -> read empty -> CANNOT undo regardless of what it is now -> CAN clear IF not empty
      //case 2: field started empty -> read empty -> can undo regardless of what it is now
      if (initialValueExists &&
          widget.textEditingController.text != currInitialValue) {
        bool initialValueIsEmpty = currInitialValue.length == 0;
        suffixIcon = IconButton(
          icon: Icon(
            initialValueIsEmpty ? Icons.clear : Icons.undo,
            color: Colors.blue,
          ),
          onPressed: () {
            widget.textEditingController.text = currInitialValue;

            //since setting the value of the text editing controller didn't work
            //and setting the text and then the selection is not good
            //I just wait and then do exactly that to skip whatever makes it not good practice
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.textEditingController.selection =
                  TextSelection.fromPosition(
                TextPosition(
                  offset: widget.textEditingController.text.length,
                ),
              );
            });

            widget.onUndo();
          },
        );
      }
    }

    //add or don't add save icon
    bool actuallyShowSaveButton = false;
    if (widget.showSaveButton) {
      //check if it's saveable
      String currValue = widget.textEditingController.text;

      //check if saveable under current conditions
      //init value here can be empty IF canSaveEmpty
      bool saveableWithInitValue =
          (initialValueExists && currValue != currInitialValue);
      bool saveableWithoutInitValue = initialValueExists == false &&
          (currValue.length > 0 ||
              (currValue.length == 0 && widget.canSaveEmpty));

      //its maybe saveable
      if (saveableWithInitValue || saveableWithoutInitValue) {
        bool fieldIsEmpty = currValue == null || currValue.length == 0;
        if (fieldIsEmpty) {
          actuallyShowSaveButton = widget.canSaveEmpty;
        } else {
          actuallyShowSaveButton = true;
        }
      }
    }

    //add save button to suffix
    //if field unfocused since otherwise the undo and clear actions should take over
    //and if focused they should click the done button
    Widget saveButton;
    //!caring about focus to show or not show the button is too confusing
    if (actuallyShowSaveButton) {
      saveButton = Padding(
        padding: EdgeInsets.only(
          left: 8.0,
        ),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Colors.black,
            ),
          ),
          onPressed: () {
            if (widget.onSubmitted != null) {
              if (widget.onSubmitted(
                widget.textEditingController.text,
              )) {
                newNormal();
              }
            }
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 3.0,
                    ),
                    child: Icon(
                      Icons.save,
                      color: Colors.white,
                    ),
                  ),
                  Text("Save"),
                ],
              ),
            ),
          ),
        ),
      );
    }

    //determine hint border color
    Color hintBorderColor = Theme.of(context).primaryColorLight;
    bool hintExists = widget.hintBorder != null;
    if (hintExists) {
      hintBorderColor = widget.hintBorder.value;
      if (hintBorderColor == defaultColor) {
        hintBorderColor = Theme.of(context).primaryColorLight;
      }
    }

    String labelPrefix = widget.label ?? "";
    String labelSufix = widget.label ?? "";
    if (labelPrefix != "") {
      labelPrefix += " ";
      labelSufix = " " + labelSufix;
    }

    //error handling with hint
    String requiredError;
    if (widget.errorOnEmptyField && fieldCleared.value) {
      requiredError = (labelPrefix + "Is Required*");
    }
    String neededError;
    if (hintExists && hintBorderColor == errorColor) {
      neededError = (labelPrefix + "NEEDS to change");
    }

    String labelText = (buttonMode ? "Tap to add " : "") + (widget.label ?? "");
    if (widget.label == null) {
      labelText = buttonMode ? "Tap To Type " : "";
    }

    //build
    return Row(
      children: [
        Expanded(
          child: TextField(
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            controller: widget.textEditingController,
            //NOTE: the expands param is different
            maxLines:
                (widget.textInputType == TextInputType.multiline) ? null : 1,
            textInputAction: (widget.textInputType == TextInputType.multiline)
                ? TextInputAction.newline
                : widget.notMultilineInputAction,
            //the more specialized the better
            keyboardType: widget.textInputType,
            scrollPadding: EdgeInsets.only(
              //20 is the default
              bottom: 24.0 + (widget.extraScrollPadding ? (56 + 16) : 0) + 16,
            ),
            //sometimes the default behavior is desired
            onSubmitted: (widget.onSubmitted == null)
                ? null
                : (String newString) {
                    if (widget.onSubmitted(newString)) {
                      newNormal();
                    }
                  },
            //sometimes the default behavior is desired
            onEditingComplete: (widget.onEditingComplete == null)
                ? null
                : () {
                    widget.onEditingComplete();
                  },
            decoration: InputDecoration(
              //tighten up padding
              contentPadding: EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 8,
              ),

              //show "button" if the field is empty & we don't show an error when that happens
              filled: buttonMode,
              fillColor: Colors.blue,

              //top of field
              labelText: labelText,
              labelStyle: TextStyle(
                color: buttonMode ? Colors.white : null,
                fontWeight: buttonMode ? FontWeight.bold : null,
              ),

              //when can undo & clear
              //undo takes priority since they would have always at first had the chance to clear
              //and WILL have the chance to clear after undoing
              suffixIcon: suffixIcon,

              //--------------------------------------------------
              //Hint Border Operates Below
              //--------------------------------------------------

              //standard border
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: hintBorderColor,
                  width: 1,
                ),
              ),

              //only show red if an error is showing up
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),

              //unknown
              //semanticCounterText: "sctext",

              //within field when clicked
              //prefixText: "prefix",
              hintText:
                  (widget.label != null) ? "Type in a " + widget.label : "Type",
              //suffixText: "suffix",

              //bottom left (urgent)
              //either X + " is required"
              //or X + " needs to change"
              errorText: requiredError != null ? requiredError : neededError,

              //bottom left (non urgent)
              helperText: hintExists && hintBorderColor == warningColor
                  ? (labelPrefix + "MIGHT need to change")
                  : null,
              helperStyle: TextStyle(
                color: hintBorderColor,
              ),

              //field bottom right
              //counterText: "counter",
            ),
          ),
        ),
        saveButton != null ? saveButton : Container(),
      ],
    );
  }
}
