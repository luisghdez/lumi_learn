import 'package:flutter/material.dart';

class NoSwipePageRoute<T> extends PageRouteBuilder<T> {
  NoSwipePageRoute({required WidgetBuilder builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionDuration: Duration(milliseconds: 0),
          reverseTransitionDuration: Duration(milliseconds: 0),
        );

  @override
  bool get opaque => true;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  bool get fullscreenDialog => false;

  // ❌ Completely disables swipe-back gesture on iOS
  @override
  bool get popGestureEnabled => false;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // No transition animation
    return child;
  }
}
