import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/vibration.dart';

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
  ValueNotifier onTop = new ValueNotifier(true);

  updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  updateOnTop() {
    onTop.value = widget.scrollController.offset <= 0;
  }

  @override
  void initState() {
    super.initState();
    onTop.addListener(updateState);
    widget.scrollController.addListener(updateOnTop);
  }

  @override
  void dispose() {
    onTop.removeListener(updateState);
    widget.scrollController.removeListener(updateOnTop);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
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
