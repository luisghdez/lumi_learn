import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/models/question.dart';

class FlashcardScreen extends StatefulWidget {
  final Question question;

  const FlashcardScreen({
    Key? key,
    required this.question,
  }) : super(key: key);

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final CourseController courseController =
      Get.find<CourseController>(); // GetX controller

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
                'assets/bg/red1bg.png',
                fit: BoxFit.cover,
              ),
            ),

            // 2) Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center, // adjust as needed
                    end: Alignment.bottomCenter, // adjust as needed
                    colors: [
                      Colors.transparent, // start color
                      Color.fromARGB(255, 12, 12, 12), // end color
                    ],
                  ),
                ),
              ),
            ),

            // 3) Your main UI content on top
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: FlashcardWidget(flashcard: currentFlashcard),
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 8.0),
                //   child: Text(
                //     'Tap the card to flip',
                //     style: TextStyle(
                //         fontSize: 16,
                //         color: Colors.white), // White to stand out
                //   ),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: _moveToPreviousCard,
                      icon: Icon(Icons.navigate_before),
                      // label: Text(''),
                    ),
                    IconButton(
                      onPressed: _moveToNextCard,
                      icon: Icon(Icons.navigate_next),
                      // label: Text('Next'),
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
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: pi).animate(_controller);
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
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBackSide() {
    return _buildCard(
      child: Text(
        widget.flashcard.definition,
        style: const TextStyle(fontSize: 20, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      height: 400,
      // We only apply the outer shadow to the parent container
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            // 1) This BackdropFilter will blur whatever is *behind* this card
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(),
            ),

            // 2) Semi-transparent black overlay
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
