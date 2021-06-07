import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/curvedCorner.dart';

class SectionTitle extends StatelessWidget {
  final IconData rightIcon;
  final String name;

  const SectionTitle({
    this.rightIcon,
    @required this.name,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: MediaQuery.of(context).size.width,
      color: Colors.black,
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 8,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              rightIcon == null
                  ? Container()
                  : Icon(
                      rightIcon,
                      //hidden for now
                      color: Colors.transparent,
                      size: 18,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class FieldAdder extends StatelessWidget {
  const FieldAdder({
    @required this.add,
    @required this.fieldName,
    Key key,
  }) : super(key: key);

  final Function add;
  final String fieldName;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => add(),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: 8.0,
              ),
              child: FieldIconButton(
                iconData: Icons.add,
                color: Colors.green,
              ),
            ),
            Expanded(
              child: Text(
                "add a " + fieldName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FieldIconButton extends StatelessWidget {
  FieldIconButton({
    @required this.iconData,
    @required this.color,
    this.onTapped,
    this.iconSize,
    this.lessRightPadding: true,
  });

  final IconData iconData;
  final Color color;
  final Function onTapped;
  final double iconSize;
  final bool lessRightPadding;

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      //color: Colors.grey,
      height: 8 + 8 + 32.0,
      padding: EdgeInsets.symmetric(
        vertical: 0,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: (lessRightPadding ? 8 : 16),
        ),
        child: SizedBox(
          width: 24,
          height: 24,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                iconData,
                color: Colors.white,
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );

    //button or no button
    if (onTapped == null) {
      return child;
    } else {
      return InkWell(
        onTap: onTapped,
        child: child,
      );
    }
  }
}
