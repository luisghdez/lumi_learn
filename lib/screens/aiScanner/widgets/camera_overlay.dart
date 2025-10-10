import 'package:flutter/material.dart';

class CameraOverlay extends StatelessWidget {
  final Color borderColor;

  const CameraOverlay({super.key, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 280,
        height: 280,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 3,
                height: 80,
                color: borderColor,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 3,
                height: 80,
                color: borderColor,
              ),
            ),
            Icon(Icons.add, color: borderColor, size: 32),
          ],
        ),
      ),
    );
  }
}
