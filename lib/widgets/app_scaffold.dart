import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  const AppScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      backgroundColor: const Color.fromARGB(255, 12, 12, 12),

      // Wrap the body in Padding
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: body,
        ),
      ),
    );
  }
}
