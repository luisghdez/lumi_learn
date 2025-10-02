import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
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

  Widget _buildCameraPreview(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use FittedBox with cover to fill screen and crop excess
        return FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.previewSize!.height,
            height: controller.value.previewSize!.width,
            child: CameraPreview(controller),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (isInitialized)
          Positioned.fill(
            child: _buildCameraPreview(context),
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

        // Back Button
        Positioned(
          top: 10,
          left: 20,
          child: SafeArea(
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Get.back(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.3),
                padding: const EdgeInsets.only(
                    left: 14, right: 10, top: 12, bottom: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
