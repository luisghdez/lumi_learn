import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/models/question.dart';

class FlashcardScreen extends StatefulWidget {
  final List<Flashcard> flashcards;

  const FlashcardScreen({
    Key? key,
    required this.flashcards,
  }) : super(key: key);

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final CourseController courseController = Get.find<CourseController>();

  int currentIndex = 0;
  bool isListView = false; // Flag to toggle between view modes

  void _moveToPreviousCard() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      }
    });
  }

  void _moveToNextCard() {
    setState(() {
      if (currentIndex < widget.flashcards.length - 1) {
        currentIndex++;
      }
    });
  }

  /// Builds the one-by-one flashcard view.
  Widget _buildFlashcardView() {
    final currentFlashcard = widget.flashcards[currentIndex];
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 768;
    final double padding = isTablet ? 32.0 : 16.0;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Center(
              child: FlashcardWidget(
                key: ValueKey(currentFlashcard),
                flashcard: currentFlashcard,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Tap the card to flip',
            style: TextStyle(
                fontSize: isTablet ? 20 : 16,
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
              '${currentIndex + 1}/${widget.flashcards.length}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 20 : 16,
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
    );
  }

  /// Builds the list view of flashcards.
  Widget _buildListView() {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 768;

    final double termFontSize = isTablet ? 22 : 18;
    final double definitionFontSize = isTablet ? 18 : 14;
    final double padding = isTablet ? 32.0 : 16.0;

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: widget.flashcards.length,
      itemBuilder: (context, index) {
        final flashcard = widget.flashcards[index];
        return Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
          ),
          child: ListTile(
            onTap: () {
              setState(() {
                currentIndex = index;
                isListView = false; // Switch back to flashcard view.
              });
            },
            contentPadding: EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: padding,
            ),
            title: Text(
              flashcard.term,
              style: TextStyle(
                color: Colors.white,
                fontSize: termFontSize,
                fontWeight: FontWeight.w400,
              ),
            ),
            subtitle: Text(
              flashcard.definition,
              style: TextStyle(
                color: Colors.white70,
                fontSize: definitionFontSize,
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const Divider(
        color: greyBorder,
        thickness: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 768;
    final double iconSize = isTablet ? 28.0 : 20.0;
    final double appBarPadding = isTablet ? 32.0 : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(kToolbarHeight + appBarPadding + appBarPadding),
        child: Padding(
          padding: EdgeInsets.all(appBarPadding),
          child: AppBar(
            surfaceTintColor: Colors.transparent,
            backgroundColor: const Color(0xFF0A0A0A),
            elevation: 0,
            leading: IconButton(
              iconSize: iconSize,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                iconSize: iconSize,
                icon: Icon(isListView ? Icons.view_carousel : Icons.view_list),
                onPressed: () {
                  setState(() {
                    isListView = !isListView;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: isListView
              ? Container(
                  key: const ValueKey('listView'),
                  child: _buildListView(),
                )
              : Container(
                  key: const ValueKey('flashcardView'),
                  child: _buildFlashcardView(),
                ),
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
    // When the flashcard changes, reset the animation and show the front (term)
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
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 768;
    final double fontSize = isTablet ? 32 : 24;

    return _buildCard(
      child: Text(
        widget.flashcard.term,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w200,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBackSide() {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 768;
    final double fontSize = isTablet ? 26 : 20;

    return _buildCard(
      child: Text(
        widget.flashcard.definition,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w300,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.6, // 50% of the screen height
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
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: greyBorder, width: 1),
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
