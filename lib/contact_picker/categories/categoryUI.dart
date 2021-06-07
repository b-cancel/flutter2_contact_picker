import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter2_contact_picker/contact_picker/newContact/outer_shell/editorHelpers.dart';
import 'package:flutter2_contact_picker/contact_picker/tile/tile.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/customField.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/permissions/standardDialog.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:page_transition/page_transition.dart';
import 'categoryData.dart';

enum Boolean { TRUE, FALSE }

//used to be stateful
//Tap To Edit Category
class CategorySelector extends StatelessWidget {
  CategorySelector({
    this.labelIsFor,
    @required this.alternativeLabelIsFor,
    @required this.labelType,
    @required this.labelSelected,
  });

  final TextEditingController labelIsFor;
  final String alternativeLabelIsFor;
  final LabelType labelType;
  final ValueNotifier<String> labelSelected;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        //label title
        String thingLabelIsFor = "this " + alternativeLabelIsFor;
        if (labelIsFor != null && labelIsFor.text.length > 0) {
          thingLabelIsFor = labelIsFor.text;
        }

        //label selector page
        var newValue = await Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.bottomToTop,
            child: Theme(
              data: ThemeData.dark(),
              child: CategorySelectionPage(
                labelType: labelType,
                initialLabelValue: labelSelected.value,
                labelIsFor: thingLabelIsFor,
              ),
            ),
          ),
        );

        //set the new value if possible
        if (newValue != null && newValue.length > 0) {
          labelSelected.value = newValue;
        }
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
    @required this.initialLabelValue,
    @required this.labelIsFor,
  });

  final LabelType labelType;
  final String initialLabelValue;
  final String labelIsFor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Label for " + labelIsFor,
        ),
      ),
      body: Theme(
        data: ThemeData.light(),
        child: CategorySelectionPageBody(
          labelType: labelType,
          initialLabelValue: initialLabelValue,
        ),
      ),
    );
  }
}

class CategorySelectionPageBody extends StatefulWidget {
  const CategorySelectionPageBody({
    Key key,
    @required this.labelType,
    @required this.initialLabelValue,
  }) : super(key: key);

  final LabelType labelType;
  final String initialLabelValue;

  @override
  _CategorySelectionPageBodyState createState() =>
      _CategorySelectionPageBodyState();
}

class _CategorySelectionPageBodyState extends State<CategorySelectionPageBody> {
  updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    CategoryData.labelTypeToCustomLabelNotifiers[widget.labelType].addListener(
      updateState,
    );
  }

  @override
  void dispose() {
    CategoryData.labelTypeToCustomLabelNotifiers[widget.labelType]
        .removeListener(
      updateState,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //handle default labels
    List<String> defaultLabels =
        CategoryData.labelTypeToDefaultLabels[widget.labelType];
    int selectedDefaultLabelIndex =
        defaultLabels.indexOf(widget.initialLabelValue);

    //handle non default labels
    List<String> customLabels =
        CategoryData.labelTypeToCustomLabelNotifiers[widget.labelType].value;
    int selectedCustomLabelIndex =
        customLabels.indexOf(widget.initialLabelValue);

    //build all the stuffs
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    String labelString = defaultLabels[index];
                    bool isFirstIndex = (index == 0);
                    bool isLastIndex = index == (defaultLabels.length - 1);
                    return LabelTile(
                      isSelected: index == selectedDefaultLabelIndex,
                      //if we have custom labels, keep the pattern
                      isLastIndex: isLastIndex,
                      isFirstIndex: isFirstIndex,
                      labelString: labelString,
                      blackBottom: customLabels.length > 0,
                    );
                  },
                  childCount: defaultLabels.length,
                ),
              ),
              SliverStickyHeader(
                header: customLabels.length > 0
                    ? SectionTitle(
                        name: "Custom Labels",
                      )
                    : Container(),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      String labelString = customLabels[index];
                      bool isFirstIndex = (index == 0);
                      bool isLastIndex = index == (customLabels.length - 1);
                      return LabelTile(
                        isSelected: index == selectedCustomLabelIndex,
                        isLastIndex: isLastIndex,
                        isFirstIndex: isFirstIndex,
                        labelString: labelString,
                        onRemove: () {
                          CategoryData.removeFromCustomLabels(
                            widget.labelType,
                            labelString,
                          );
                        },
                      );
                    },
                    childCount: customLabels.length,
                  ),
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
          ),
        ),
        Container(
          color: ThemeData.dark().primaryColor,
          padding: EdgeInsets.all(8),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 48,
              child: Padding(
                padding: EdgeInsets.only(
                  right: 16,
                ),
                child: NewCustomLabelField(
                  labelType: widget.labelType,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NewCustomLabelField extends StatefulWidget {
  const NewCustomLabelField({
    Key key,
    @required this.labelType,
  }) : super(key: key);

  final LabelType labelType;

  @override
  _NewCustomLabelFieldState createState() => _NewCustomLabelFieldState();
}

class _NewCustomLabelFieldState extends State<NewCustomLabelField> {
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomField(
      noBorder: true,
      noButtonFillMode: true,
      prefixIcon: Container(
        height: 48,
        width: 48,
        child: Center(
          child: Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ),
      focusNode: new FocusNode(),
      textEditingController: textEditingController,
      textInputType: TextInputType.text,
      notMultilineInputAction: TextInputAction.done,
      label: "Custom Label",
      errorOnEmptyField: false,
      showClearRegardlessOfFocus: false,
      autofocus: false,
      onEditingComplete: () {
        String submittedValue = textEditingController.text;
        if (submittedValue.length == 0) {
          FocusScope.of(context).requestFocus(new FocusNode());
        } else {
          //save potentially new value
          CategoryData.addToCustomLabels(
            widget.labelType,
            submittedValue,
          );

          //return the new value
          Navigator.of(context).pop(submittedValue);
        }
      },
    );
  }
}

class LabelTile extends StatelessWidget {
  const LabelTile({
    Key key,
    @required this.isSelected,
    @required this.isLastIndex,
    @required this.isFirstIndex,
    @required this.labelString,
    this.blackBottom: false,
    this.onRemove,
  }) : super(key: key);

  final bool isSelected;
  final bool isLastIndex;
  final bool isFirstIndex;
  final String labelString;
  final Function onRemove;
  final bool blackBottom;

  @override
  Widget build(BuildContext context) {
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
                  color: isLastIndex && blackBottom == false
                      ? ThemeData.dark().primaryColor
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(isFirstIndex ? 16 : 0),
            bottom: Radius.circular(isLastIndex ? 16 : 0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: Colors.grey[300],
                ),
              ),
            ),
            child: ListTile(
              visualDensity: VisualDensity.compact,
              onTap: () {
                return Navigator.of(context).pop(labelString);
              },
              leading: Icon(
                Icons.check,
                color: isSelected ? Colors.blue : Colors.transparent,
              ),
              title: Text(labelString),
              contentPadding: EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
              trailing: onRemove == null
                  ? null
                  : IconButton(
                      onPressed: () => onRemove(),
                      icon: Icon(
                        Icons.close,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
