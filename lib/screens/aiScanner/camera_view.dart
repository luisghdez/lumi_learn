import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'widgets/camera_overlay.dart';
import 'widgets/instruction_text.dart';
import 'widgets/category_selector.dart';

class CameraView extends StatelessWidget {
  final CameraController controller;
  final bool isInitialized;
  final Color selectedColor;
  final List<Map<String, dynamic>> categories;
  final int selectedIndex;
  final Function(int) onCategoryTap;
  final VoidCallback onCapture;

  const CameraView({
    super.key,
    required this.controller,
    required this.isInitialized,
    required this.selectedColor,
    required this.categories,
    required this.selectedIndex,
    required this.onCategoryTap,
    required this.onCapture,
  });

@override
Widget build(BuildContext context) {
  return Stack(
    children: [
      if (isInitialized)
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller.value.previewSize!.height,
              height: controller.value.previewSize!.width,
              child: CameraPreview(controller),
            ),
          ),
        )
      else
        const Center(child: CircularProgressIndicator()),

      // UI Overlays
      CameraOverlay(borderColor: selectedColor),
      const InstructionText(),
      CategorySelector(
        categories: categories,
        selectedIndex: selectedIndex,
        onPageChanged: onCategoryTap,
        onCapture: onCapture,
      ),
    ],
  );
}


}
