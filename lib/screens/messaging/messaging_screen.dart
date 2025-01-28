import 'package:flutter/material.dart';
import 'components/messaging_header.dart';
import 'widgets/messaging_widget.dart';

class MessagingScreen extends StatelessWidget {
  const MessagingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Main layout of the Messaging Screen
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messaging'),
      ),
      body: const Column(
        children: [
          MessagingHeader(),
          Expanded(
            child: MessagingWidget(),
          ),
        ],
      ),
    );
  }
}
