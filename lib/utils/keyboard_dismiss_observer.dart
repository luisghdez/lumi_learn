// lib/utils/keyboard_dismiss_observer.dart
import 'package:flutter/widgets.dart';
import 'keyboard.dart';

class KeyboardDismissObserver extends NavigatorObserver {
  void _hide() => Keyboard.hide();

  @override
  void didPush(Route route, Route? previousRoute) => _hide();
  @override
  void didPop(Route route, Route? previousRoute) => _hide();
  @override
  void didReplace({Route? newRoute, Route? oldRoute}) => _hide();
  @override
  void didRemove(Route route, Route? previousRoute) => _hide();
  void didPopNext(Route nextRoute) => _hide();
}
