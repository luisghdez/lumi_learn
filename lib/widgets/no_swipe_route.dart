import 'package:flutter/material.dart';

class NoSwipePageRoute<T> extends PageRouteBuilder<T> {
  NoSwipePageRoute({
    required WidgetBuilder builder,
    Duration duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
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
}
