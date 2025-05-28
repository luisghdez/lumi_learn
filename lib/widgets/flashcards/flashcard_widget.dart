import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/models/question.dart';
import 'package:lumi_learn_app/utils/latex_text.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Individual flip card widget
/// ─────────────────────────────────────────────────────────────────────────────
class FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;

  const FlashcardWidget({Key? key, required this.flashcard}) : super(key: key);

  @override
  _FlashcardWidgetState createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));
  late final Animation<double> _anim =
      Tween<double>(begin: 0, end: pi).animate(_controller);

  bool isFront = true;

  @override
  void didUpdateWidget(covariant FlashcardWidget old) {
    super.didUpdateWidget(old);
    if (old.flashcard != widget.flashcard) {
      _controller.reset();
      isFront = true;
    }
  }

  void _flip() {
    if (isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => isFront = !isFront);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;
    final frontSize = isTablet ? 32.0 : 24.0;
    final backSize = isTablet ? 26.0 : 20.0;

    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final angle = _anim.value;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: angle <= pi / 2
                ? _card(
                    SmartText(
                      widget.flashcard.term,
                      style: TextStyle(
                        fontSize: frontSize,
                        fontWeight: FontWeight.w200,
                        color: Colors.white,
                      ),
                      align: TextAlign.center,
                    ),
                  )
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: _card(
                      SmartText(
                        widget.flashcard.definition,
                        style: TextStyle(
                          fontSize: backSize,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                        align: TextAlign.center,
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _card(Widget child) {
    final height = MediaQuery.of(context).size.height * 0.6;

    return Container(
      height: height,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            BackdropFilter(filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5)),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: greyBorder, width: 1),
              ),
              padding: const EdgeInsets.all(24),
              child: Center(child: child),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
} 