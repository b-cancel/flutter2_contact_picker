//modification of inverted circle clipper taken from somewhere on the internet
import 'package:flutter/material.dart';

//build
class CurvedCorner extends StatelessWidget {
  CurvedCorner({
    @required this.isTop,
    @required this.isLeft,
    this.backgroundColor,
    @required this.cornerColor,
    this.size: 24,
  });

  final bool isTop;
  final bool isLeft;
  final Color backgroundColor;
  final Color cornerColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.transparent,
      height: size,
      width: size,
      child: FittedBox(
        fit: BoxFit.contain,
        child: ClipPath(
          clipper: CornerClipper(
            isTop: isTop,
            isLeft: isLeft,
          ),
          child: Container(
            color: cornerColor,
            height: 1,
            width: 1,
          ),
        ),
      ),
    );
  }
}

class CornerClipper extends CustomClipper<Path> {
  CornerClipper({
    @required this.isTop,
    this.isLeft: true,
  });

  final bool isTop;
  final bool isLeft;

  @override
  Path getClip(Size size) {
    return new Path()
      ..addOval(new Rect.fromCircle(
          center:
              new Offset((isLeft ? size.width : 0), (isTop ? size.height : 0)),
          radius: size.width * 1))
      ..addRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CurvedFrame extends StatelessWidget {
  const CurvedFrame({
    @required this.size,
    @required this.topColor,
    @required this.bottomColor,
    @required this.slightShift,
    Key key,
  }) : super(key: key);

  final double size;
  final Color topColor;
  final Color bottomColor;
  final bool slightShift;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CurvedCorner(
              isTop: true,
              isLeft: true,
              cornerColor: topColor,
              size: size,
            ),
            CurvedCorner(
              isTop: true,
              isLeft: false,
              cornerColor: topColor,
              size: size,
            ),
          ],
        ),
        Transform.translate(
          offset: Offset(0, slightShift ? 1 : 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CurvedCorner(
                isTop: false,
                isLeft: true,
                cornerColor: bottomColor,
                size: size,
              ),
              CurvedCorner(
                isTop: false,
                isLeft: false,
                cornerColor: bottomColor,
                size: size,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
