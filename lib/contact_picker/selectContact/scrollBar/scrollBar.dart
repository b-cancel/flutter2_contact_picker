//only use to debug
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'alphaScrollBarOverlay.dart';
import 'scroller.dart';

bool scrollBarColors = true;

//scroll bar widgets
class ScrollBar extends StatefulWidget {
  ScrollBar({
    @required this.sectionKeyToContactCount,
    @required this.scrollController,
    @required this.expandedBannerHeight,
    //56 REGARDLESS OF SIZE OF ACTUAL BOTTOM APP BAR
    this.bottomAppBarHeight: 56,
    @required this.toolbarHeight,
  });

  final Map<String, int> sectionKeyToContactCount;
  final ScrollController scrollController;
  final double expandedBannerHeight;
  final double bottomAppBarHeight;
  final double toolbarHeight;

  @override
  _ScrollBarState createState() => _ScrollBarState();
}

class _ScrollBarState extends State<ScrollBar> {
  //with absolutely no padding
  ValueNotifier<double> maxScrollBarHeight = ValueNotifier(0);

  //when the user is using the scroll bar, don't allow it to resize
  //if its does at the begining the behavior will be wack
  ValueNotifier<bool> retainScrollBarSize = ValueNotifier(false);

  updateScrollBarHeight() {
    if (widget.scrollController.hasClients == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateScrollBarHeight();
      });
    } else {
      bool attached = widget.scrollController.hasClients;
      double currentOffset = attached ? widget.scrollController.offset : 0;

      //overscrolling from the top
      double bannerSize = widget.expandedBannerHeight;
      //overscrolling handled here as well
      if (currentOffset != 0) {
        bannerSize -= currentOffset;
      }
      //banner also technically includes the bottom bar, but shouldn't
      bannerSize += widget.toolbarHeight;

      //make sure the scroll bar doesn't get too big
      double screenHeight = MediaQuery.of(context).size.height;
      double potentialScrollBarHeight = screenHeight - bannerSize;
      double absoluteMaxScrollBarHeight =
          screenHeight - widget.toolbarHeight - 56;
      if (potentialScrollBarHeight > absoluteMaxScrollBarHeight) {
        potentialScrollBarHeight = absoluteMaxScrollBarHeight;
      }
      maxScrollBarHeight.value = potentialScrollBarHeight;
    }
  }

  updateStateOnManualScroll() {
    if (retainScrollBarSize.value == false) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    //if we are scroll manually, update the scroll bar
    widget.scrollController.addListener(updateStateOnManualScroll);
    //if we finish automatic scrolling, update the scroll bar
    retainScrollBarSize.addListener(updateStateOnManualScroll);
  }

  @override
  void dispose() {
    retainScrollBarSize.removeListener(updateStateOnManualScroll);
    widget.scrollController.addListener(updateStateOnManualScroll);
    super.dispose();
  }

  //build
  @override
  Widget build(BuildContext context) {
    //by placing it here we cover
    //1. update to the height
    //2. orientation changes
    //3. initialization
    updateScrollBarHeight();

    //for scroll bar overall
    //48 is sticky header
    double visualScrollBarPadding = 16;
    double stickyHeaderHeight = 48;
    double scrollBarTopPadding = stickyHeaderHeight + visualScrollBarPadding;
    double scrollBarBottomPadding = visualScrollBarPadding;

    //for alpha scroll bar
    double itemHeight = 14;
    double spacingVertical = 0;
    double alphaScrollBarPadding = 16;

    //actually build
    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        height: maxScrollBarHeight.value,
        width: 24.0 + (16 * 2),
        child: Stack(
          children: [
            Container(
              height: maxScrollBarHeight.value,
              padding: EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: scrollBarTopPadding,
                  bottom: scrollBarBottomPadding,
                ),
                child: Container(
                  width: 24,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.all(
                      Radius.circular(16.0),
                    ),
                  ),
                  child: Container(),
                ),
              ),
            ),
            //----Scroll Bar Function
            DraggableScrollBar(
              scrollController: widget.scrollController,
              sectionKeyToContactCount: widget.sectionKeyToContactCount,
              retainScrollBarSize: retainScrollBarSize,
              //---other
              stickyHeaderHeight: stickyHeaderHeight,
              maxScrollBarHeight: maxScrollBarHeight,
              visualScrollBarPadding: visualScrollBarPadding,
              alphaScrollBarPadding: alphaScrollBarPadding,

              /*
              scrollController: widget.autoScrollController,
              //set once and done
              visualScrollBarHeight: scrollBarVisualHeight,
              programaticScrollBarHeight: scrollBarAreaHeight,
              alphaOverlayHeight: alphaOverlayHeight,
              scrollThumbHeight: 4 * itemHeight,
              paddingAll: paddingAll,
              thumbColor: Theme.of(context).accentColor.withOpacity(0.25),
              expandedBannerHeight: widget.expandedBannerHeight,
              //value notifiers, don't need to notify since we KNOW when we pass these they will already not be empty
              sortedLetterCodes: widget.sortedLetterCodes.value,
              letterToListItems: widget.letterToListItems.value,
              showSlider: showSlider,
              */
            ),
            Positioned(
              right: 0,
              child: IgnorePointer(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: scrollBarTopPadding + alphaScrollBarPadding,
                      bottom: scrollBarBottomPadding + alphaScrollBarPadding,
                    ),
                    child: AlphaScrollBarOverlay(
                      scrollBarHeight: maxScrollBarHeight.value -
                          scrollBarTopPadding -
                          scrollBarBottomPadding -
                          (alphaScrollBarPadding * 2),
                      itemHeight: itemHeight,
                      spacingVertical: spacingVertical,
                      letterCodes: [
                        "*", //favorites
                        "A",
                        "B",
                        "C",
                        "D",
                        "E",
                        "F",
                        "G",
                        "H",
                        "I",
                        "J",
                        "K",
                        "L",
                        "M",
                        "N",
                        "O",
                        "P",
                        "Q",
                        "R",
                        "S",
                        "T",
                        "U",
                        "V",
                        "W",
                        "X",
                        "Y",
                        "Z",
                        "#", //every thing else
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
