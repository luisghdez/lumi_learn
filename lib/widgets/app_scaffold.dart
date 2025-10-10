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
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/black_moons_lighter.png',
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          appBar: appBar,
          floatingActionButton: floatingActionButton,
          backgroundColor: Colors.transparent,

          // Wrap the body in Padding
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: body,
            ),
          ),
        ),
      ],
    );
  }
}