// lib/utils/keyboard.dart
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Keyboard {
  static void hide() {
    // Drop focus
    FocusManager.instance.primaryFocus?.unfocus();
    // Tell the platform to hide (covers edge cases)
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}
