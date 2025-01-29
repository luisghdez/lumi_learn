import 'package:flutter/material.dart';
import 'package:vibra_app/widgets/starry_background.dart';

class StarryAppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  const StarryAppScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: appBar,
      // floatingActionButton: floatingActionButton,
      // Wrap the body in Padding
      body: SafeArea(
        child: Stack(
          children: [const GalaxyBackground(), body],
        ),
      ),
    );
  }
}
