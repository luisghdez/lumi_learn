import 'package:flutter/material.dart';
import 'package:lumi_learn_app/widgets/starry_background.dart';

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
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const Positioned.fill(child: GalaxyBackground()),
          SafeArea(
            bottom: false,
            child: body,
          ),
        ],
      ),
    );
  }
}
