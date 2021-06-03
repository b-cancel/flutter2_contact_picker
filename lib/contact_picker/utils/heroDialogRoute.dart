//Hero Dialog Route
import 'package:flutter/material.dart';

class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute({
    this.builder,
    this.scrimColor: Colors.black54,
    this.isBarrierDismissable: true,
  }) : super();

  final WidgetBuilder builder;
  final Color scrimColor;
  final bool isBarrierDismissable;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => isBarrierDismissable;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => scrimColor;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  String get barrierLabel => null;
}
