import 'package:flutter/material.dart';

class PfpViewer extends StatelessWidget {
  final double offsetUp;
  final ImageProvider backgroundImage;

  const PfpViewer({
    Key? key,
    this.offsetUp = 0,
    required this.backgroundImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -offsetUp),
      child: Image(
        image: backgroundImage,
        height: 350,
      ),
    );
  }
}
