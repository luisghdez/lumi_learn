import 'dart:async';
import 'package:flutter/material.dart';

class TypewriterSpeechBubbleMessage extends StatefulWidget {
  final String message;
  final TextStyle? textStyle;
  final Duration speed;
  final VoidCallback? onFinished;
  final double maxHeight;

  const TypewriterSpeechBubbleMessage({
    Key? key,
    required this.message,
    this.textStyle,
    this.speed = const Duration(milliseconds: 30),
    this.onFinished,
    this.maxHeight = 200,
  }) : super(key: key);

  @override
  State<TypewriterSpeechBubbleMessage> createState() =>
      _TypewriterSpeechBubbleMessageState();
}

class _TypewriterSpeechBubbleMessageState
    extends State<TypewriterSpeechBubbleMessage>
    with SingleTickerProviderStateMixin {
  /// The text that has been typed so far
  String typedSoFar = "";

  /// Index of the next character to add
  int charIndex = 0;

  /// Timer for the manual typewriter effect
  Timer? _typingTimer;

  /// Overlay entry to show our expanded message
  OverlayEntry? _overlayEntry;

  /// Animation controller for smooth scale-in/out
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  bool get isFinished => charIndex >= widget.message.length;

  /// ScrollController to enable auto-scroll
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 150),
      value: 0,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    );

    // Start typing character by character
    _startTyping();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _scaleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Manually type out the message one character at a time
  void _startTyping() {
    _typingTimer?.cancel(); // cancel any previous timer
    _typingTimer = Timer.periodic(widget.speed, (timer) {
      if (charIndex < widget.message.length) {
        setState(() {
          typedSoFar += widget.message[charIndex];
          charIndex++;
        });

        // Mark the overlay as needing a rebuild so it also sees the updated text
        _overlayEntry?.markNeedsBuild();

        // After rebuilding, scroll to bottom so user sees the new text
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
            // If you prefer a smooth scroll instead:
            // _scrollController.animateTo(
            //   _scrollController.position.maxScrollExtent,
            //   duration: const Duration(milliseconds: 100),
            //   curve: Curves.easeOut,
            // );
          }
        });
      } else {
        timer.cancel();
        widget.onFinished?.call();
      }
    });
  }

  /// Create an overlay entry with a dark background and centered “expanded bubble.”
  void _showOverlay() {
    if (_overlayEntry != null) return; // already visible

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return GestureDetector(
          behavior:
              HitTestBehavior.opaque, // so taps outside bubble are detected
          onTap: _removeOverlay, // tap outside to dismiss
          child: Material(
            color: const Color.fromARGB(193, 0, 0, 0), // dim background
            child: Stack(
              children: [
                // Center the expanded bubble
                Center(
                  child: FadeTransition(
                    opacity: _scaleAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildExpandedMessage(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    _scaleController.forward();
  }

  /// Close the overlay with a smooth reverse animation
  void _removeOverlay() {
    if (_overlayEntry != null) {
      _scaleController.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }

  /// Expanded version of the message that appears in the overlay.
  Widget _buildExpandedMessage(BuildContext context) {
    return GestureDetector(
      // Absorb taps so it doesn't dismiss if user taps inside bubble
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF191D2D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          // Notice we are NOT using `reverse: true`:
          // This means text starts at the top, flows downward.
          child: Text(
            typedSoFar, // same typed text
            style: widget.textStyle ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // The main typed bubble
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: widget.maxHeight,
              minHeight: widget.maxHeight,
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              // We keep this the same so it also auto-scrolls in the normal bubble
              child: Text(
                typedSoFar,
                style: widget.textStyle ??
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ),
        ),
        // Small expand icon in bottom-right corner
        Positioned(
          bottom: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(
              Icons.fullscreen,
              color: Color.fromARGB(74, 255, 255, 255),
            ),
            onPressed: _showOverlay,
          ),
        ),
      ],
    );
  }
}
