import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/models/question.dart';
import 'package:lumi_learn_app/utils/latex_text.dart';

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
  bool isListView = false;
  int get _known => _status.where((s) => s == true).length;
  int get _unknown => _status.where((s) => s == false).length;
  Color _cardTint = Colors.transparent; // current overlay color
  void _resetTint() => _cardTint = Colors.transparent;

  late final List<bool?> _status =
      List<bool?>.filled(widget.flashcards.length, null, growable: false);

  void _moveToPreviousCard() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
    }
  }

  void _moveToNextCard() {
    if (currentIndex < widget.flashcards.length - 1) {
      setState(() => currentIndex++);
    }
  }

  Widget _bubble(int value, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(.15),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          value.toString(),
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      );

  Widget _counterStrip() {
    final isTablet = MediaQuery.of(context).size.width >= 768;
    final padding = isTablet ? 32.0 : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _bubble(_unknown, Colors.red),
          const SizedBox(width: 6),
          _bubble(_known, Colors.green),
        ],
      ),
    );
  }

  /// One‑by‑one flashcard view
  Widget _buildFlashcardView() {
    final current = widget.flashcards[currentIndex];
    final isTablet = MediaQuery.of(context).size.width >= 768;
    final padding = isTablet ? 32.0 : 16.0;

    return Column(
      children: [
        _counterStrip(),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Dismissible(
                    key: ValueKey('card_$currentIndex'),
                    direction: DismissDirection.horizontal,
                    background:
                        const SizedBox.shrink(), // no external background
                    secondaryBackground: const SizedBox.shrink(),

                    // ⏪⏩ GRADUAL COLOR UPDATE
                    onUpdate: (details) {
                      final p = details.progress; // 0 → 1
                      setState(() {
                        _cardTint = Color.lerp(
                          Colors.transparent,
                          details.direction == DismissDirection.startToEnd
                              ? Colors.green // RIGHT swipe  = known
                              : Colors.red, // LEFT swipe   = unknown
                          p,
                        )!;
                      });
                    },

                    // ✔️ final classification
                    onDismissed: (dir) {
                      final isKnown = dir == DismissDirection.startToEnd;
                      _status[currentIndex] = isKnown;

                      _resetTint(); // clear overlay for next card
                      if (currentIndex < widget.flashcards.length - 1) {
                        setState(() => currentIndex++);
                      } else {
                        setState(() {}); // just refresh counters
                      }
                    },

                    // 🃏 the actual card, wrapped with AnimatedContainer for the tint
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      decoration: BoxDecoration(
                        color: _cardTint,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: FlashcardWidget(flashcard: current),
                    ),
                  )),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Tap the card to flip',
            style: TextStyle(
              fontSize: isTablet ? 20 : 16,
              fontWeight: FontWeight.w200,
              color: Colors.white,
            ),
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
            Text(
              '${currentIndex + 1}/${widget.flashcards.length}',
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 20 : 16,
                fontWeight: FontWeight.w200,
              ),
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

  /// Scrollable list view
  Widget _buildListView() {
    final isTablet = MediaQuery.of(context).size.width >= 768;
    final termSize = isTablet ? 22.0 : 18.0;
    final defSize = isTablet ? 18.0 : 14.0;
    final padding = isTablet ? 32.0 : 16.0;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: widget.flashcards.length,
      itemBuilder: (context, index) {
        final f = widget.flashcards[index];
        return Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
          ),
          child: ListTile(
            onTap: () {
              setState(() {
                currentIndex = index;
                isListView = false;
              });
            },
            contentPadding:
                EdgeInsets.symmetric(vertical: 12, horizontal: padding),
            title: SmartText(
              f.term,
              style: TextStyle(
                color: Colors.white,
                fontSize: termSize,
                fontWeight: FontWeight.w400,
              ),
            ),
            subtitle: SmartText(
              f.definition,
              style: TextStyle(
                color: Colors.white70,
                fontSize: defSize,
              ),
            ),
          ),
        );
      },
      separatorBuilder: (_, __) =>
          const Divider(color: greyBorder, thickness: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;
    final iconSize = isTablet ? 28.0 : 20.0;
    final appBarPad = isTablet ? 32.0 : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + appBarPad * 2),
        child: Padding(
          padding: EdgeInsets.all(appBarPad),
          child: AppBar(
            backgroundColor: const Color(0xFF0A0A0A),
            elevation: 0,
            leading: IconButton(
              iconSize: iconSize,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: Get.back,
            ),
            actions: [
              IconButton(
                iconSize: iconSize,
                icon: Icon(isListView ? Icons.view_carousel : Icons.view_list),
                onPressed: () => setState(() => isListView = !isListView),
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
          child: isListView
              ? Container(key: const ValueKey('list'), child: _buildListView())
              : Container(
                  key: const ValueKey('cards'), child: _buildFlashcardView()),
        ),
      ),
    );
  }
}

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
