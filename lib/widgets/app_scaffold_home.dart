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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background image stretched fully
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: body,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
