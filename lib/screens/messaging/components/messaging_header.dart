import 'package:flutter/material.dart';

class MessagingHeader extends StatelessWidget {
  const MessagingHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example header for Messaging
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        'Your Conversations',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
