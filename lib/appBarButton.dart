import 'package:flutter/material.dart';

class AppBarButton extends StatelessWidget {
  const AppBarButton({
    @required this.toolTip,
    @required this.onTapPassContext,
    @required this.title,
    this.actions,
    this.color,
    this.noBackButton: false,
    Key key,
  }) : super(key: key);

  final String toolTip;
  final Function onTapPassContext;
  final Widget title;
  final List<Widget> actions;
  final Color color;
  final bool noBackButton;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: Tooltip(
        message: toolTip,
        child: InkWell(
          onTap: () => onTapPassContext(context),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: AppBar(
              automaticallyImplyLeading: noBackButton == false,
              backgroundColor: Colors.transparent,
              leading: noBackButton
                  ? null
                  : GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: IconButton(
                        disabledColor: Colors.white,
                        icon: BackButtonIcon(),
                        onPressed: null,
                      ),
                    ),
              title: title,
              actions: actions,
            ),
          ),
        ),
      ),
    );
  }
}
