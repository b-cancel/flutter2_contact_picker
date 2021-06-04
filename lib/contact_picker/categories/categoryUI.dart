import 'package:flutter/material.dart';
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.bottomToTop,
              child: CategorySelectionPage(
                labelType: labelType,
                labelString: labelSelected,
              ),
            ),
          );
        },
        child: Container(
          width: 100,
          height: 8 + 32.0 + 8,
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(
            left: 16,
            bottom: 11,
          ),
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 12),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).primaryColorLight,
                ),
              ),
            ),
            child: AnimatedBuilder(
              animation: labelSelected,
              builder: (BuildContext context, Widget child) {
                return Text(
                  labelSelected.value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CategorySelectionPage extends StatelessWidget {
  CategorySelectionPage({
    @required this.labelType,
    @required this.labelString,
  });

  final LabelType labelType;
  final ValueNotifier<String> labelString;

  @override
  Widget build(BuildContext context) {
    List<String> labels = CategoryData.labelTypeToLabels[labelType];

    //check if the label we passed is contained within the defaults
    bool hadDefault = labels.contains(labelString.value);
    int theIndexSelected = 0;
    Widget bottomContent;
    if (hadDefault) {
      bottomContent = AnItem(
        label: "Create custom type",
        labelString: labelString,
      );

      //determine which default is selected
      theIndexSelected = labels.indexOf(labelString.value);
    } else {
      bottomContent = AnItem(
        label: labelString.value,
        labelString: labelString,
        selected: true,
        showEdit: true,
      );
    }

    //build the widgets
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text(
          "Select " + CategoryData.labelTypeToCategoryName[labelType] + " type",
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            if (index == labels.length + 1) {
              return bottomContent;
            } else {
              //mark the selected index as selected
              bool markSelected;
              if (hadDefault == false)
                markSelected = false;
              else {
                markSelected = (index == theIndexSelected) ? true : false;
              }

              //build
              return AnItem(
                selected: markSelected,
                label: labels[index],
                labelString: labelString,
              );
            }
          },
          itemCount: labels.length + 1,
        ),
      ),
    );
  }
}

class PopUpButton extends StatelessWidget {
  const PopUpButton({
    Key key,
    @required this.onTapped,
    @required this.text,
  }) : super(key: key);

  final Function onTapped;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTapped,
          child: Container(
            padding: EdgeInsets.all(24),
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).primaryColorLight.withOpacity(
                      (onTapped == null) ? 0.5 : 1,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnItem extends StatelessWidget {
  const AnItem({
    @required this.label,
    @required this.labelString,
    this.selected,
    this.showEdit: false,
  });

  final String label;
  final ValueNotifier<String> labelString;
  final bool selected;
  final bool showEdit;

  @override
  Widget build(BuildContext context) {
    Widget leading;
    if (selected != null) {
      leading = IgnorePointer(
        child: Radio(
          value: Boolean.TRUE,
          groupValue: selected ? Boolean.TRUE : Boolean.FALSE,
          onChanged: (var value) {},
        ),
      );
    } else {
      leading = Icon(
        Icons.add,
        color: Colors.green,
      );
    }

    return Material(
      color: Colors.transparent,
      child: Row(
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () {
                if (selected == null) {
                  //create pop up
                  customTypePopUp(
                    context,
                    true,
                    labelString,
                  );
                } else {
                  //select item
                  labelString.value = label;
                  Navigator.pop(context);
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: leading,
                        ),
                      ),
                    ),
                    Text(
                      upperFirst(label),
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          showEdit
              ? InkWell(
                  onTap: () {
                    customTypePopUp(
                      context,
                      false,
                      labelString,
                    );
                  },
                  child: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "Edit",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  upperFirst(String s) {
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }
}

void customTypePopUp(
  BuildContext context,
  bool create,
  ValueNotifier<String> labelString,
) {
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        title: new Text(
          ((create) ? "Create" : "Rename") + " custom type",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        contentPadding: EdgeInsets.only(left: 24, right: 24),
        content: AlertContent(
          labelString: labelString,
          //rename set labelString value on init
          create: create,
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
  TextEditingController customType = new TextEditingController();
  bool canCreate = false;

  @override
  void initState() {
    if (widget.create == false) {
      customType.text = widget.labelString.value;
    }

    //enable the create button when possible
    customType.addListener(() {
      canCreate = (customType.text.length != 0);
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
          TextField(
            autofocus: true,
            controller: customType,
            textInputAction: TextInputAction.done,
          ),
          Row(
            children: <Widget>[
              new PopUpButton(
                onTapped: () {
                  Navigator.pop(context);
                },
                text: "Cancel",
              ),
              Center(
                child: Container(
                  width: 2,
                  height: 26,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              new PopUpButton(
                onTapped: canCreate
                    ? () {
                        //save string
                        widget.labelString.value = customType.text;
                        //pop the pop up
                        Navigator.pop(context);
                        //pop the select type window
                        Navigator.pop(context);
                      }
                    : null,
                text: "Create",
              ),
            ],
          )
        ],
      ),
    );
  }
}
