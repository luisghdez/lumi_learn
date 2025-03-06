import 'package:flutter/material.dart';

class AppScaffoldHome extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  const AppScaffoldHome({
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
      backgroundColor: Colors.black,

      // Wrap the body in Padding
      body: SafeArea(
        bottom: false,
        child: Padding(
          // not bottom padding
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
          // padding: const EdgeInsets.all(16.0), // or whatever spacing
          child: body,
        ),
      ),
    );
  }
}
