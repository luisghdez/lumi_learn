import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lumi_learn_app/widgets/lumi_text_input_field.dart';

class ChatInputArea extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String text) onSend;
  final void Function(File image)? onImagePicked;
  final void Function(File file)? onFilePicked;

  const ChatInputArea({
    Key? key,
    required this.suggestions,
    required this.onSend,
    this.onImagePicked,
    this.onFilePicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // You can customize the suggestion chips here if needed
        LumiTextInputField(
          onSend: onSend,
          onImagePicked: onImagePicked,
          onFilePicked: onFilePicked,
        ),
      ],
    );
  }
}
