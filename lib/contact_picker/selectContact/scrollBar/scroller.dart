import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/vibration.dart';

class DraggableScrollBar extends StatefulWidget {
  const DraggableScrollBar({
    @required this.scrollController, //we use
    @required this.retainScrollBarSize, //we update
    @required this.sectionKeyToContactCount, //we use
    //other
    @required this.bannerHeight,
    @required this.maxScrollBarHeight,
    @required this.stickyHeaderHeight,
    @required this.visualScrollBarPadding,
    @required this.alphaScrollBarPadding,
    Key key,
  }) : super(key: key);

  final ScrollController scrollController;
  final ValueNotifier<bool> retainScrollBarSize;
  final Map<String, double> sectionKeyToContactCount;
  //other
  final double bannerHeight;
  final ValueNotifier<double> maxScrollBarHeight;
  final double stickyHeaderHeight;
  final double visualScrollBarPadding;
  final double alphaScrollBarPadding;

  @override
  _DraggableScrollBarState createState() => _DraggableScrollBarState();
}

class _DraggableScrollBarState extends State<DraggableScrollBar> {
  ValueNotifier<String> closestTo = ValueNotifier("");
  double closestToOffset = 0;

  setClosestTo(String char, double offset) {
    closestToOffset = offset;
    closestTo.value = char;
  }

  scrollTo(double scrollValue) {
    double absoluteUpperBound = (widget.maxScrollBarHeight.value - 48);
    //[                                            ]
    double scrollBarPadding =
        widget.visualScrollBarPadding + widget.alphaScrollBarPadding;
    //[ 48 [                                       ]
    double adjustedUpperBound = absoluteUpperBound - (scrollBarPadding * 2);
    //[ 48 [ visual ( alpha * ... # alpha ) visual ]
    double slotSize = adjustedUpperBound / 27;
    //0 to actual upper bound is the middle of * to the middle of #...
    //so 27 spaces although there are 28 characters

    //ensure the value is within bounds
    if (scrollValue < 0) {
      scrollValue = 0;
    } else if (scrollValue > absoluteUpperBound) {
      scrollValue = absoluteUpperBound;
    }

    //most of the top and bottom of the scroll bar
    //is the top or the bottom value
    //since the scroll bar area is bigger than it looks
    //so that its easy to use

    //do math to determine what letter is closer
    if (scrollValue < scrollBarPadding) {
      setClosestTo("*", 0);
    } else if (scrollValue > (absoluteUpperBound - scrollBarPadding)) {
      setClosestTo("#", adjustedUpperBound);
    } else {
      //we are within the alpha scroll bar
      //  [ recents | 26 letters | other ]
      //28 characters in totaly except only 27 spaces
      //because we start midway through * and end midway through #

      double adjustedScrollValue = scrollValue - scrollBarPadding;
      //I'll handle those two halves first
      if (adjustedScrollValue < (slotSize / 2)) {
        setClosestTo("*", 0);
      } else if (adjustedScrollValue > (adjustedUpperBound - (slotSize / 2))) {
        setClosestTo("#", adjustedUpperBound);
      } else {
        //remove the halves (or 1 slot)
        adjustedScrollValue = adjustedScrollValue - (slotSize / 2);
        adjustedUpperBound = adjustedUpperBound - slotSize;

        //given that there are 26 slots to land in
        //anything below (slotSize) is "A"
        //anything below (slotSize * 2) is "B" (as long as its not "A")
        //and so on

        //a is slot 0
        int slotNumber = (adjustedScrollValue / slotSize).ceil() - 1;
        int asciiCodeForA = 65;
        String newChar = String.fromCharCode(asciiCodeForA + slotNumber);
        setClosestTo(newChar, adjustedScrollValue + slotSize);
      }
    }

    print("closest to: " + closestTo.value.toString());

    //now that we know what character they want to go to
    //so if there is a section for that
    if (widget.sectionKeyToContactCount.containsKey(closestTo.value)) {
      double current = widget.scrollController.offset;
      double jumpTo = widget.sectionKeyToContactCount[closestTo.value];
      jumpTo += (widget.bannerHeight - 56);

      //if we aren't there already, go there
      if (current != jumpTo) {
        //jump to does not match to pixel value
        //so I can't use max scroll offset to calculate the extent and stop overscrolling
        widget.scrollController.jumpTo(jumpTo);
        vibrate();
      }
    }
  }

  void onVerticalDragUpdate(DragUpdateDetails details) {
    widget.retainScrollBarSize.value = true;
    //wait for the listener above to take effect
    scrollTo(details.localPosition.dy);
  }

  updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    widget.maxScrollBarHeight.addListener(updateState);
    closestTo.addListener(updateState);
    super.initState();
  }

  @override
  void dispose() {
    widget.maxScrollBarHeight.removeListener(updateState);
    closestTo.removeListener(updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double circleSize = 56;
    return Padding(
      padding: EdgeInsets.only(
        top: widget.stickyHeaderHeight,
      ),
      child: Stack(
        children: [
          Container(
            height: (widget.maxScrollBarHeight.value - 48),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              //NOT true on dragDown or dragStart
              onVerticalDragUpdate: onVerticalDragUpdate,
              onVerticalDragCancel: () {
                widget.retainScrollBarSize.value = false;
                closestTo.value = "";
              },
              onVerticalDragEnd: (dragEndDetails) {
                widget.retainScrollBarSize.value = false;
                closestTo.value = "";
              },
              child: Container(
                color: Colors.red.withOpacity(0),
              ),
            ),
          ),
          Positioned(
            top: closestToOffset +
                widget.visualScrollBarPadding +
                widget.alphaScrollBarPadding,
            child: Visibility(
              visible: closestTo.value != "",
              child: Transform.translate(
                offset: Offset(
                  //the last one is extra
                  -(circleSize / 2) - (24 / 2) - 16,
                  0,
                ),
                child: Center(
                  child: Container(
                    height: 0,
                    width: 0,
                    child: OverflowBox(
                      minWidth: circleSize,
                      maxWidth: circleSize,
                      maxHeight: circleSize,
                      minHeight: circleSize,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(
                            Radius.circular(circleSize / 2),
                          ),
                        ),
                        child: Center(
                          child: closestTo.value == "*"
                              ? Icon(Icons.star)
                              : Text(
                                  closestTo.value,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: circleSize / 2,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
