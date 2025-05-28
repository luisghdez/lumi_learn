import 'package:flutter/material.dart';
import 'package:lumi_learn_app/application/models/chat_sender.dart'; // ✅ Shared enum

class ChatBubble extends StatelessWidget {
  final String message;
  final ChatSender sender;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.sender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isUser = sender == ChatSender.user;
    final Alignment alignment =
        isUser ? Alignment.centerRight : Alignment.centerLeft;
    final CrossAxisAlignment crossAxisAlignment =
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    final Color backgroundColor = isUser
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.04);

    final BorderRadius borderRadius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          border: Border.all(color: Colors.white12),
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
