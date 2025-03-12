import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/models/question.dart';

class FlashcardScreen extends StatefulWidget {
  final Question question;
  final String backgroundImage;

  const FlashcardScreen({
    Key? key,
    required this.question,
    required this.backgroundImage,
  }) : super(key: key);

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final CourseController courseController = Get.find<CourseController>();

  int currentIndex = 0;

  List<Flashcard> get flashcards => widget.question.flashcards;

  void _moveToPreviousCard() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      }
    });
  }

  void _moveToNextCard() {
    setState(() {
      if (currentIndex < flashcards.length - 1) {
        currentIndex++;
      } else {
        courseController.nextQuestion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentFlashcard = flashcards[currentIndex];

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            // 1) Background image
            Positioned.fill(
              child: Image.asset(
                widget.backgroundImage,
                fit: BoxFit.fitHeight,
              ),
            ),

            // 2) Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color.fromARGB(255, 12, 12, 12),
                    ],
                  ),
                ),
              ),
            ),

            // 3) Main UI content on top
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: FlashcardWidget(
                        key: ValueKey(currentFlashcard),
                        flashcard: currentFlashcard,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Tap the card to flip',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w200,
                        color: Colors.white),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: _moveToPreviousCard,
                      icon: const Icon(Icons.navigate_before),
                      color: Colors.white,
                    ),
                    // Display current flashcard count
                    Text(
                      '${currentIndex + 1}/${flashcards.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w200),
                    ),
                    IconButton(
                      onPressed: _moveToNextCard,
                      icon: const Icon(Icons.navigate_next),
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;

  const FlashcardWidget({
    Key? key,
    required this.flashcard,
  }) : super(key: key);

  @override
  _FlashcardWidgetState createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  bool isFront = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: pi).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the flashcard changes, reset the animation and show the term (front side)
    if (oldWidget.flashcard != widget.flashcard) {
      _controller.reset();
      setState(() {
        isFront = true;
      });
    }
  }

  void _flipCard() {
    if (isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      isFront = !isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: angle <= pi / 2
                ? _buildFrontSide()
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: _buildBackSide(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFrontSide() {
    return _buildCard(
      child: Text(
        widget.flashcard.term,
        style: const TextStyle(
            fontSize: 24, fontWeight: FontWeight.w200, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBackSide() {
    return _buildCard(
      child: Text(
        widget.flashcard.definition,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w300, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            // Backdrop blur filter
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(),
            ),
            // Semi-transparent black overlay
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(24.0),
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
