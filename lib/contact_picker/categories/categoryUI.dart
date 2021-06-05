import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/customField.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/permissions/standardDialog.dart';
import 'package:page_transition/page_transition.dart';
import 'categoryData.dart';

enum Boolean { TRUE, FALSE }

//used to be stateful
//Tap To Edit Category
class CategorySelector extends StatelessWidget {
  CategorySelector({
    @required this.labelType,
    @required this.labelSelected,
  });

  final LabelType labelType;
  final ValueNotifier<String> labelSelected;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.bottomToTop,
            child: Theme(
              data: ThemeData.dark(),
              child: CategorySelectionPage(
                labelType: labelType,
                labelString: labelSelected,
              ),
            ),
          ),
        );
      },
      child: Row(
        children: [
          AnimatedBuilder(
            animation: labelSelected,
            builder: (BuildContext context, Widget child) {
              return SizedBox(
                width: 45,
                child: Text(
                  labelSelected.value,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}

//lets you select between all the default categories
//additionally...
//if you are using a custom category already => it lets you edit it -OR- select from defaults
//if you are not using a custom category => it lets you create it -OR- select from defaults
//BUT this custom category does not save for use elsewhere
class CategorySelectionPage extends StatelessWidget {
  CategorySelectionPage({
    @required this.labelType,
    @required this.labelString,
  });

  final LabelType labelType;
  final ValueNotifier<String> labelString;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Select " + CategoryData.labelTypeToCategoryName[labelType] + " type",
        ),
      ),
      body: Theme(
        data: ThemeData.light(),
        child: CategorySelectionPageBody(
          labelType: labelType,
          labelString: labelString,
        ),
      ),
    );
  }
}

class CategorySelectionPageBody extends StatelessWidget {
  const CategorySelectionPageBody({
    Key key,
    @required this.labelType,
    @required this.labelString,
  }) : super(key: key);

  final LabelType labelType;
  final ValueNotifier<String> labelString;

  @override
  Widget build(BuildContext context) {
    List<String> defaultLabels =
        CategoryData.labelTypeToDefaultLabels[labelType];
    int selectedDefaultLabelIndex = defaultLabels.indexOf(labelString.value);
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              if (index < defaultLabels.length) {
                return ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(index == 0 ? 16 : 0),
                  ),
                  child: Container(
                    color: Colors.white,
                    child: AnItem(
                      isSelected: (index == selectedDefaultLabelIndex),
                      itemLabel: defaultLabels[index],
                      selectedLabel: labelString,
                    ),
                  ),
                );
              } else {
                Widget lastTile;
                if (selectedDefaultLabelIndex == -1) {
                  lastTile = AnItem(
                    itemLabel: labelString.value,
                    selectedLabel: labelString,
                    isSelected: true,
                    showEdit: true,
                  );
                } else {
                  lastTile = AnItem(
                    itemLabel: "Create custom type",
                    selectedLabel: labelString,
                  );
                }

                //tile background
                return Material(
                  color: ThemeData.dark().primaryColor,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                    child: Container(
                      color: Colors.white,
                      child: lastTile,
                    ),
                  ),
                );
              }
            },
            childCount: defaultLabels.length + 1,
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

class AnItem extends StatelessWidget {
  const AnItem({
    @required this.itemLabel,
    @required this.selectedLabel,
    this.isSelected,
    this.showEdit: false,
  });

  final String itemLabel;
  final ValueNotifier<String> selectedLabel;
  final bool isSelected;
  final bool showEdit;

  @override
  Widget build(BuildContext context) {
    Widget leading;
    if (isSelected != null) {
      leading = Container(
        margin: EdgeInsets.only(
          left: 3,
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.blue : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: 2,
          ),
        ),
        child: Icon(
          Icons.check,
          color: Colors.white,
          //24 is default, 16 looks right, 8 diff
          size: 18,
        ),
      );
    } else {
      leading = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green,
          border: Border.all(
            color: Colors.green,
            width: 2,
          ),
        ),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      );
    }

    return ListTile(
      onTap: () {
        if (isSelected == null) {
          //create pop up
          customTypePopUp(
            context,
            create: true,
            selectedLabel: selectedLabel,
          );
        } else {
          //select item
          selectedLabel.value = itemLabel;
          Navigator.pop(context);
        }
      },
      leading: leading,
      title: Text(
        upperFirst(itemLabel),
        style: TextStyle(
          fontSize: 20,
        ),
      ),
      trailing: showEdit
          ? TextButton(
              onPressed: () {
                customTypePopUp(
                  context,
                  create: false,
                  selectedLabel: selectedLabel,
                );
              },
              child: Text(
                "Edit",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            )
          : null,
    );
  }

  upperFirst(String s) {
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }
}

void customTypePopUp(
  BuildContext context, {
  bool create,
  ValueNotifier<String> selectedLabel,
}) {
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return Theme(
        data: ThemeData.light(),
        child: AlertDialog(
          title: Container(
            decoration: BoxDecoration(
              color: ThemeData.dark().primaryColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: 24,
                bottom: 16,
              ),
              child: Text(
                ((create) ? "Create" : "Rename") + " Custom Type",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          titlePadding: EdgeInsets.all(0),
          contentPadding: EdgeInsets.all(0),
          content: AlertContent(
            labelString: selectedLabel,
            //rename set labelString value on init
            create: create,
          ),
        ),
      );
    },
  );
}

class AlertContent extends StatefulWidget {
  const AlertContent({
    Key key,
    @required this.labelString,
    @required this.create,
  }) : super(key: key);

  final ValueNotifier<String> labelString;
  final bool create;

  @override
  _AlertContentState createState() => _AlertContentState();
}

class _AlertContentState extends State<AlertContent> {
  TextEditingController textEditingController = new TextEditingController();
  bool canCreate = false;

  @override
  void initState() {
    if (widget.create == false) {
      textEditingController.text = widget.labelString.value;
    }

    //enable the create button when possible
    textEditingController.addListener(() {
      canCreate = (textEditingController.text.length != 0);
      setState(() {});
    });

    //super init
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: 16,
                bottom: 24,
              ),
              child: CustomField(
                autofocus: true,
                notMultilineInputAction: TextInputAction.done,
                focusNode: FocusNode(),
                textEditingController: textEditingController,
                label: "Custom Type",
                errorOnEmptyField: true,
                textInputType: TextInputType.text,
                showClearRegardlessOfFocus: true,
              ),
            ),
          ),
          DenyOrAllow(
            denyText: "Cancel",
            denyTextColor: Colors.black,
            onDeny: () {
              Navigator.pop(context);
            },
            allowText: "Save",
            allowButtonColor: Colors.blue,
            onAllow: canCreate
                ? () {
                    //save string
                    widget.labelString.value = textEditingController.text;
                    //pop the pop up
                    Navigator.pop(context);
                    //pop the select type window
                    Navigator.pop(context);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
