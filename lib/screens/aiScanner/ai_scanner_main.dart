import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'camera_view.dart';
import 'image_cropper_view.dart';
import 'package:lumi_learn_app/screens/lumiTutor/lumi_tutor_main.dart';
import 'package:lumi_learn_app/widgets/no_swipe_route.dart';
import 'package:lumi_learn_app/application/controllers/tutor_controller.dart';
import 'package:lumi_learn_app/screens/main/main_screen.dart';

class AiScannerMain extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String?
      existingThreadId; // If provided, add image to this thread instead of creating new one

  const AiScannerMain({
    super.key,
    required this.cameras,
    this.existingThreadId,
  });

  @override
  State<AiScannerMain> createState() => _AiScannerMainState();
}

class _AiScannerMainState extends State<AiScannerMain> {
  late final CameraController _controller;

  bool _isCameraInitialized = false;
  bool _isCropping = false;
  bool _isCroppingInProgress = false;

  int _selectedIndex = 0;

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
    _controller = CameraController(widget.cameras.first, ResolutionPreset.high);
    try {
      await _controller.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      Get.snackbar("Camera Error", "Failed to initialize camera: $e");
    }
  }

  Future<void> _captureImage() async {
    if (!_controller.value.isInitialized || _controller.value.isTakingPicture)
      return;

    try {
      final XFile rawImage = await _controller.takePicture();
      final bytes = await rawImage.readAsBytes();
      HapticFeedback.mediumImpact();

      setState(() {
        _isCropping = true;
      });

      final selectedColor = _categories[_selectedIndex]['color'] as Color;

      await Navigator.of(context).push(
        NoSwipePageRoute(
          builder: (_) => ImageCropperView(
            imageBytes: bytes,
            dotColor: selectedColor,
            isCroppingInProgress: _isCroppingInProgress,
            onCropPressed: () => setState(() => _isCroppingInProgress = true),
            onImageCropped: _submitCroppedImage,
            onCropError: () => setState(() => _isCroppingInProgress = false),
          ),
        ),
      );

      setState(() {
        _isCropping = false;
        _isCroppingInProgress = false;
      });
    } catch (e) {
      Get.snackbar("Capture Error", "Failed to capture image: $e");
    }
  }

  void _submitCroppedImage(Uint8List croppedBytes) async {
    final directory = await getTemporaryDirectory();
    final filename = '${const Uuid().v4()}.png';
    final filePath = '${directory.path}/$filename';

    final file = File(filePath);
    await file.writeAsBytes(croppedBytes);

    setState(() {
      _isCropping = false;
      _isCroppingInProgress = false;
    });

    // Call the new image thread creation method
    await _handleScannedInput(filePath, _categories[_selectedIndex]['name']);
  }

  Future<void> _handleScannedInput(String imagePath, String category) async {
    try {
      final tutorController = TutorController.instance;

      // Check if we should add to existing thread or create a new one
      if (widget.existingThreadId != null) {
        // Add image to existing thread
        tutorController.sendImageToThread(
          threadId: widget.existingThreadId!,
          imagePath: imagePath,
        );

        // Just pop back to the tutor screen
        Get.back();
        Get.back();
      } else {
        // Create a new image thread (this sets up the UI immediately)
        tutorController.createImageThread(imagePath, category);

        Get.offAll(
          () => MainScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 300),
        );
        Get.to(
          () => const LumiTutorMain(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 300),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to process image: $e",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  void _handleCategoryScroll(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<bool> _onWillPop() async {
    if (_isCropping) {
      setState(() {
        _isCropping = false;
        _isCroppingInProgress = false;
      });
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = _categories[_selectedIndex]['color'] as Color;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: CameraView(
          controller: _controller,
          isInitialized: _isCameraInitialized,
          selectedColor: selectedColor,
          categories: _categories,
          selectedIndex: _selectedIndex,
          onCategoryTap: _handleCategoryScroll,
          onCapture: _captureImage,
        ),
      ),
    );
  }
}
