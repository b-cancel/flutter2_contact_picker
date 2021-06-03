import 'package:flutter/material.dart';

class StandardHeroDialog extends StatelessWidget {
  StandardHeroDialog({
    Key key,
    this.onPop,
    @required this.header,
    this.headerColor: Colors.black,
    @required this.body,
    this.stickyFooter,
    this.rounding: 4,
    this.tag,
  }) : super(key: key);

  final Function onPop;
  final Widget header;
  final Color headerColor;
  final Widget body;
  final Widget stickyFooter;
  final double rounding;
  final String tag;

  @override
  Widget build(BuildContext context) {
    Widget dialogContent = Material(
      borderRadius: BorderRadius.circular(rounding),
      color: Colors.white,
      child: IntrinsicHeight(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(rounding),
                ),
              ),
              child: header,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: body,
              ),
            ),
            Visibility(
              visible: stickyFooter != null,
              child: stickyFooter,
            ),
          ],
        ),
      ),
    );

    //add the tag if it's passed
    if (tag != null) {
      dialogContent = Hero(
        tag: tag,
        child: dialogContent,
      );
    }

    //return it all together now
    return WillPopScope(
      onWillPop: () async {
        if (onPop != null) {
          onPop();
        }

        //don't let them pop naturally IF we have an on pop variable
        return onPop != null ? false : true;
      },
      child: Dialog(
        child: dialogContent,
      ),
    );
  }
}

class DenyOrAllow extends StatelessWidget {
  const DenyOrAllow({
    @required this.onDeny,
    this.denyText,
    this.denyTextColor,
    @required this.onAllow,
    this.allowText,
    this.allowButtonColor,
    Key key,
  }) : super(key: key);

  final Function onDeny;
  final String denyText;
  final Color denyTextColor;

  final String allowText;
  final Function onAllow;
  final Color allowButtonColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(4),
        bottomRight: Radius.circular(4),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.black,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: DenyAllowButton(
                label: denyText ?? "Deny",
                onTap: () => onDeny(),
                textColor: denyTextColor ?? Colors.red,
              ),
            ),
            Expanded(
              child: DenyAllowButton(
                label: allowText ?? "Allow",
                onTap: () => onAllow(),
                buttonColor: allowButtonColor ?? Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DenyAllowButton extends StatelessWidget {
  const DenyAllowButton({
    @required this.onTap,
    @required this.label,
    this.buttonColor: Colors.transparent,
    this.textColor: Colors.white,
    Key key,
  }) : super(key: key);

  final Function onTap;
  final String label;
  final Color buttonColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: buttonColor,
      child: InkWell(
        onTap: () => onTap(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 16,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LineItem extends StatelessWidget {
  const LineItem({
    this.number,
    @required this.item,
    Key key,
  }) : super(key: key);

  final String number;
  final Widget item;

  @override
  Widget build(BuildContext context) {
    double circleSize = 24;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            right: 8.0,
          ),
          child: Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              color: number != null ? Colors.black : Colors.transparent,
              borderRadius: BorderRadius.circular(56),
            ),
            child: Center(
              child: Text(
                number ?? "",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Expanded(child: item),
      ],
    );
  }
}
