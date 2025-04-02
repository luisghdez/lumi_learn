import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HorizontalCategoryCard extends StatefulWidget {
  final String title;
  final String imagePath;
  final VoidCallback onConfirm; // Called when user taps "Yes!"

  const HorizontalCategoryCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<HorizontalCategoryCard> createState() => _HorizontalCategoryCardState();
}

class _HorizontalCategoryCardState extends State<HorizontalCategoryCard> {
  bool _overlayVisible = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      // When the card loses focus, hide the overlay.
      if (!_focusNode.hasFocus) {
        setState(() {
          _overlayVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleCardTap() {
    // Request focus for the card and show the overlay.
    _focusNode.requestFocus();
    setState(() {
      _overlayVisible = true;
    });
  }

  void _handleCancel() {
    // Hide overlay and remove focus.
    setState(() {
      _overlayVisible = false;
    });
    _focusNode.unfocus();
  }

  void _handleConfirm() {
    setState(() {
      _overlayVisible = false;
    });
    _focusNode.unfocus();
    // Proceed with the original onConfirm logic.
    widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      child: GestureDetector(
        onTap: _handleCardTap,
        child: Stack(
          children: [
            /// Main card background & content
            Container(
              width: 170,
              height: 230,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage(widget.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Dark gradient at the bottom
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.9),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Title text
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            widget.title,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Created By: Anonymous',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(255, 200, 200, 200),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// Overlay on top of the card with fade in/out animation
            IgnorePointer(
              ignoring: !_overlayVisible,
              child: AnimatedOpacity(
                opacity: _overlayVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  width: 170,
                  height: 230,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withOpacity(0.75),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Do you want to \nsave and start\nthis course?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // "Yes!" button stretched across the width
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: _handleConfirm,
                            child: const Text(
                              'Yes!',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      // "Cancel" button
                      SizedBox(
                        height: 32,
                        child: TextButton(
                          onPressed: _handleCancel,
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 0.9,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
