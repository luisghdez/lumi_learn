import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;

import 'widgets/camera_overlay.dart';
import 'widgets/instruction_text.dart';
import 'widgets/category_selector.dart';
import 'package:image_cropper/image_cropper.dart';


class AiScannerMain extends StatefulWidget {
  final List<CameraDescription> cameras;
  const AiScannerMain({super.key, required this.cameras});

  @override
  State<AiScannerMain> createState() => _AiScannerMainState();
}

class _AiScannerMainState extends State<AiScannerMain> {
  late CameraController _controller;
  bool _isCameraInitialized = false;
  bool _showSubmitButton = false;

  int _selectedIndex = 2;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Math', 'color': Colors.blue, 'icon': Icons.calculate},
    {'name': 'Science', 'color': Colors.green, 'icon': Icons.science},
    {'name': 'English', 'color': Colors.purple, 'icon': Icons.menu_book},
    {'name': 'History', 'color': Colors.orange, 'icon': Icons.history_edu},
    {'name': 'Anything', 'color': Colors.pink, 'icon': Icons.all_inclusive},
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    await _controller.initialize();
    if (!mounted) return;
    setState(() => _isCameraInitialized = true);
  }


Future<void> _captureAndSend(String category) async {
  try {
    if (!_controller.value.isInitialized) return;

    final XFile rawImage = await _controller.takePicture();
    final path = rawImage.path;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop your question',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: _categories[_selectedIndex]['color'],
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop your question',
        ),
      ],
    );

    if (croppedFile == null) return;

    final bytes = await croppedFile.readAsBytes();

    Get.toNamed('/lumiTutorChat', arguments: {
      'type': 'image',
      'imageBytes': bytes,
      'category': category,
    });
  } catch (e) {
    Get.snackbar("Error", "Could not crop or send image: $e");
  }
}


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleCategoryTap(int index) {
    if (index >= 0 && index < _categories.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedIndex = index;
          _showSubmitButton = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final selectedColor = _categories[_selectedIndex]['color'] as Color;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(_controller)),
          CameraOverlay(borderColor: selectedColor),
          const InstructionText(),
          CategorySelector(
            categories: _categories,
            selectedIndex: _selectedIndex,
            onCategoryTap: _handleCategoryTap,
          ),
          if (_showSubmitButton)
            Positioned(
              bottom: 140,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => _captureAndSend(_categories[_selectedIndex]['name']),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text("Submit", style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
