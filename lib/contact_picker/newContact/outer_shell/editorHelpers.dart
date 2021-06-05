import 'package:flutter/material.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/curvedCorner.dart';

class SectionTitle extends StatelessWidget {
  final IconData icon;
  final String name;

  const SectionTitle({
    @required this.icon,
    @required this.name,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
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
                  Icon(
                    icon,
                    //hidden for now
                    color: Colors.transparent,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(0, -24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CurvedCorner(
                isTop: false,
                isLeft: true,
                cornerColor: Colors.black,
                size: 24,
              ),
              CurvedCorner(
                isTop: false,
                isLeft: false,
                cornerColor: Colors.black,
                size: 24,
              ),
            ],
          ),
        ),
      ],
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
            RightIconButton(
              iconData: Icons.add,
              color: Colors.green,
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

class RightIconButton extends StatelessWidget {
  RightIconButton({
    @required this.iconData,
    @required this.color,
    this.onTapped,
    this.size,
  });

  final IconData iconData;
  final Color color;
  final Function onTapped;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      //color: Colors.grey,
      height: 8 + 8 + 32.0,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 0,
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
              size: size,
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