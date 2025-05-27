import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crop_your_image/crop_your_image.dart';

class ImageCropperView extends StatefulWidget {
  final Uint8List imageBytes;
  final Color dotColor;
  final VoidCallback onCropPressed;
  final ValueChanged<Uint8List> onImageCropped;
  final VoidCallback onCropError;
  final bool isCroppingInProgress;

  const ImageCropperView({
    super.key,
    required this.imageBytes,
    required this.dotColor,
    required this.onCropPressed,
    required this.onImageCropped,
    required this.onCropError,
    required this.isCroppingInProgress,
  });

  @override
  State<ImageCropperView> createState() => _ImageCropperViewState();
}

class _ImageCropperViewState extends State<ImageCropperView> {
  late final CropController _controller;
  Uint8List? _resizedImageBytes;

  @override
  void initState() {
    super.initState();
    _controller = CropController();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _resizeImageToScreen();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _handleSubmit() {
  if (!widget.isCroppingInProgress) {
    widget.onCropPressed();        // Set loading flag
    _controller.crop();            // Start the actual crop
  }
}


  Future<void> _resizeImageToScreen() async {
    final screenSize = ui.window.physicalSize / ui.window.devicePixelRatio;

    final codec = await ui.instantiateImageCodec(
      widget.imageBytes,
      targetWidth: screenSize.width.toInt(),
      targetHeight: screenSize.height.toInt(),
    );
    final frame = await codec.getNextFrame();
    final byteData = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    final resized = byteData!.buffer.asUint8List();

    setState(() {
      _resizedImageBytes = resized;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_resizedImageBytes == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Crop(
            image: _resizedImageBytes!,
            controller: _controller,
            onCropped: (CropResult result) {
              switch (result) {
                case CropSuccess(:final croppedImage):
                  widget.onImageCropped(croppedImage);
                case CropFailure():
                  widget.onCropError();
              }
            },
            initialRectBuilder: InitialRectBuilder.withSizeAndRatio(
              size: 0.85,
              aspectRatio: null,
            ),
            interactive: false,
            fixCropRect: false,
            baseColor: Colors.black,
            maskColor: Colors.black.withOpacity(0.65),
            withCircleUi: false,
            cornerDotBuilder: (size, _) => Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: widget.dotColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.dotColor.withOpacity(0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),

          // Close Button
          Positioned(
            top: 40,
            right: 24,
            child: IconButton(
              icon: Icon(Icons.close, color: widget.dotColor),
              iconSize: 28,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Submit Button
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: 
              GestureDetector(
                onTap: _handleSubmit,
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: widget.dotColor, width: 2),
                      ),
                      child: Icon(Icons.check, color: widget.dotColor, size: 28),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            ),
          ),

          // Undo/Redo Buttons
          Positioned(
            bottom: 80,
            left: 24,
            child: IconButton(
              icon: Icon(Icons.undo, color: widget.dotColor),
              onPressed: () => _controller.undo(),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 24,
            child: IconButton(
              icon: Icon(Icons.redo, color: widget.dotColor),
              onPressed: () => _controller.redo(),
            ),
          ),
        ],
      ),
    );
  }
}
