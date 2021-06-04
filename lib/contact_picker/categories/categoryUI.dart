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
                    top: Radius.circular(index == 0 ? 24 : 0),
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
                      bottom: Radius.circular(24),
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
      leading = IgnorePointer(
        child: Radio(
          value: Boolean.TRUE,
          groupValue: isSelected ? Boolean.TRUE : Boolean.FALSE,
          onChanged: (var value) {},
        ),
      );
    } else {
      leading = Container(
        child: Icon(
          Icons.add,
          color: Colors.green,
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
          ? InkWell(
              onTap: () {
                customTypePopUp(
                  context,
                  create: false,
                  selectedLabel: selectedLabel,
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
          : null,
    );
/*
    return Material(
      color: Colors.transparent,
      child: Row(
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: 
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
                      upperFirst(itemLabel),
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
        ],
      ),
    );
    */
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
