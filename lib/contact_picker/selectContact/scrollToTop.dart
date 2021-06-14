import 'package:flutter/material.dart';
import '../../contact_picker/utils/vibration.dart';

import 'package:vector_math/vector_math_64.dart' as VECT;

class ScrollToTopButton extends StatefulWidget {
  const ScrollToTopButton({
    Key key,
    @required this.scrollController,
    @required this.padding,
  }) : super(key: key);

  final ScrollController scrollController;

  final double padding;

  @override
  _ScrollToTopButtonState createState() => _ScrollToTopButtonState();
}

class _ScrollToTopButtonState extends State<ScrollToTopButton> {
  ValueNotifier onTop = ValueNotifier(true);
  ValueNotifier<double> overScroll = ValueNotifier(0);

  updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  updateOnTop() {
    ScrollPosition position = widget.scrollController.position;
    double curr = position.pixels;
    double max = position.maxScrollExtent;
    overScroll.value = (curr < max) ? 0 : curr - max;

    onTop.value = widget.scrollController.offset <= position.minScrollExtent;
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(updateOnTop);
    //hide if needed
    onTop.addListener(updateState);
    //extra spacing if needed
    overScroll.addListener(updateState);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(updateOnTop);
    onTop.removeListener(updateState);
    overScroll.removeListener(updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: (overScroll.value / 2),
      left: 0,
      right: 0,
      child: Container(
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.symmetric(
          vertical: widget.padding,
        ),
        child: AnimatedContainer(
          duration: kTabScrollDuration,
          curve: onTop.value ? Curves.easeIn : Curves.bounceOut,
          transform: Matrix4.translation(
            VECT.Vector3(
              0,
              (onTop.value) ? (widget.padding + 48.0) : 0.0,
              0,
            ),
          ),
          child: FloatingActionButton(
            mini: true,
            elevation: 0,
            backgroundColor: Colors.black.withOpacity(0.5),
            onPressed: () {
              vibrate();
              //scrollToIndex -> too slow to find index
              //jumpTo -> happens instant but scrolling to top should have some animation
              //NOTE: I ended up going with jump since animate was not fully opening the prompt
              widget.scrollController.jumpTo(0.0);
            },
            //slightly shift the combo of the two icons
            child: FittedBox(
              fit: BoxFit.contain,
              child: Transform.translate(
                offset: Offset(0, -12), //-4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: 12,
                      child: Icon(
                        Icons.minimize,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      height: 12,
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
