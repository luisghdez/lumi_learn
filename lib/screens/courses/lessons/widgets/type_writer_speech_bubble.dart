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
  /// The text typed so far
  String typedSoFar = "";

  /// Index of the next character to add
  int charIndex = 0;
  Timer? _typingTimer;

  /// Overlay entry to show the expanded message
  OverlayEntry? _overlayEntry;

  /// Animation controller for smooth scale-in/out
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  /// We now have two controllers:
  final ScrollController _inlineScrollController = ScrollController();
  final ScrollController _overlayScrollController = ScrollController();

  bool get isFinished => charIndex >= widget.message.length;

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

    _startTyping();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _scaleController.dispose();
    _inlineScrollController.dispose();
    _overlayScrollController.dispose();
    super.dispose();
  }

  void _startTyping() {
    _typingTimer?.cancel();
    _typingTimer = Timer.periodic(widget.speed, (timer) {
      if (charIndex < widget.message.length) {
        setState(() {
          typedSoFar += widget.message[charIndex];
          charIndex++;
        });

        _overlayEntry?.markNeedsBuild();

        // Auto-scroll both controllers
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_inlineScrollController.hasClients) {
            _inlineScrollController
                .jumpTo(_inlineScrollController.position.maxScrollExtent);
          }
          if (_overlayScrollController.hasClients) {
            _overlayScrollController
                .jumpTo(_overlayScrollController.position.maxScrollExtent);
          }
        });
      } else {
        timer.cancel();
        widget.onFinished?.call();
      }
    });
  }

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

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _scaleController.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }

  Widget _buildExpandedMessage(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // absorb taps so it doesn't dismiss if user taps inside
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF191D2D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: SingleChildScrollView(
          // Use the overlay controller here
          controller: _overlayScrollController,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
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
              // minHeight: widget.maxHeight,
            ),
            child: SingleChildScrollView(
              // Use the inline controller here
              controller: _inlineScrollController,
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
        Positioned(
          top: 12,
          right: -4,
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
