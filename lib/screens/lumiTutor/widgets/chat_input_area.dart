import 'package:flutter/material.dart';
import 'package:lumi_learn_app/widgets/lumi_text_input_field.dart';
import 'package:lumi_learn_app/screens/lumiTutor/widgets/suggestion_chips.dart';

class ChatInputArea extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String message) onSend;

  const ChatInputArea({
    Key? key,
    required this.suggestions,
    required this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (suggestions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SuggestionChips(
              suggestions: suggestions,
              onTap: onSend, // Sends suggestion as message
            ),
          ),
        LumiTextInputField(onSend: onSend),
      ],
    );
  }
}
