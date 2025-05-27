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

  double _knownScale = 1.0;
  double _unknownScale = 1.0;
  Color _knownGlow = Colors.transparent;
  Color _unknownGlow = Colors.transparent;

  bool _completed = false;

  void _animateBubble(bool isKnown) {
    setState(() {
      if (isKnown) {
        _knownScale = 1.25;
        _knownGlow = Colors.green.withOpacity(.5);
      } else {
        _unknownScale = 1.25;
        _unknownGlow = Colors.red.withOpacity(.5);
      }
    });

    // snap back after 300 ms
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        if (isKnown) {
          _knownScale = 1.0;
          _knownGlow = Colors.transparent;
        } else {
          _unknownScale = 1.0;
          _unknownGlow = Colors.transparent;
        }
      });
    });
  }

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

  Widget _nextCard() {
    if (currentIndex + 1 >= widget.flashcards.length) {
      return const SizedBox.shrink();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),   // ⬅️ smooth fade-in
      child: Transform.translate(
      key: ValueKey('peek_${currentIndex + 1}'),        // ⬅️ new key each time
        offset: Offset(0, 40 * (1 - _dragProgress)),      // slides up as you drag
        child: Transform.scale(
          scale: 0.9 + 0.1 * _dragProgress,               // grows 0.9 → 1.0
          child: FlashcardWidget(
            flashcard: widget.flashcards[currentIndex + 1],
          ),
        ),
      ),
    );
  }


  // ②  ADD: track drag progress (0‒1) so we can animate the back card
  double _dragProgress = 0.0;


  void _resetDeck() {
    setState(() {
      currentIndex = 0;
      _completed = false;
      for (var i = 0; i < _status.length; i++) {
        _status[i] = null;
      }
      _knownScale = 1.0;
      _unknownScale = 1.0;
      _knownGlow = Colors.transparent;
      _unknownGlow = Colors.transparent;
      _resetTint();
    });
  }

  Widget _bubble(int value, Color color, double scale, Color glow) =>
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: scale),
        duration: const Duration(milliseconds: 200),
        builder: (_, s, child) => Transform.scale(
          scale: s,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(.15),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(20),
            boxShadow: glow == Colors.transparent
                ? null
                : [
                    BoxShadow(
                      color: glow,
                      blurRadius: 12,
                      spreadRadius: 1,
                    )
                  ],
          ),
          child: Text(
            value.toString(),
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      );

  Widget _counterStrip() {
    final isTablet = MediaQuery.of(context).size.width >= 768;
    final padding = isTablet ? 32.0 : 16.0;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _bubble(_unknown, Colors.red, _unknownScale, _unknownGlow),
          const SizedBox(width: 6),
          _bubble(_known, Colors.green, _knownScale, _knownGlow),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final total = widget.flashcards.length;
    final known = _known;
    final unknown = total - known;
    final percent = ((known / total) * 100).round();

    final isTablet = MediaQuery.of(context).size.width >= 768;
    final buttonFont = isTablet ? 20.0 : 16.0;
    final buttonPad = isTablet ? 24.0 : 16.0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _AnimatedPieChart(
                  knownFraction: known / total,
                  knownColor: Colors.green,
                  unknownColor: Colors.red,
                ),
                Text(
                  '$known/$total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (_) {
              String comment;
              if (known == total) {
                comment = 'Amazing! You mastered the topic.';
              } else if (known >= (0.8 * total).ceil()) {
                comment = 'Great job! Just a little more practice.';
              } else if (known >= (0.5 * total).ceil()) {
                comment = 'Good effort! Review the ones you missed.';
              } else if (known > 0) {
                comment = 'Keep practicing! You can do it!';
              } else {
                comment = 'Don\'t give up! Try again and you\'ll improve.';
              }
              return Text(
                comment,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isTablet ? 20 : 16,
                  fontWeight: FontWeight.w400,
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _resetDeck,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: EdgeInsets.symmetric(horizontal: buttonPad * 2, vertical: buttonPad / 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Try Again',
              style: TextStyle(
                color: Colors.white,
                fontSize: buttonFont,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
            child: Stack(                                     // <──── NEW
              alignment: Alignment.center,
              children: [
                _nextCard(),                                  // back-card
                Dismissible(                                  // front-card
                  key: ValueKey('card_$currentIndex'),
                  direction: DismissDirection.horizontal,
                  resizeDuration: null,                       // keeps size constant
                  background: const SizedBox.shrink(),
                  secondaryBackground: const SizedBox.shrink(),
                  onUpdate: (details) {
                    // store progress for the parallax
                    setState(() {
                      _dragProgress = (details.progress * 2).clamp(0.0, 1.0);
                      _cardTint = Color.lerp(
                        Colors.transparent,
                        details.direction == DismissDirection.startToEnd
                            ? Colors.green
                            : Colors.red,
                        _dragProgress,
                      )!;
                    });
                  },
                  onDismissed: (dir) {
                    final isKnown = dir == DismissDirection.startToEnd;
                    _status[currentIndex] = isKnown;
                    _animateBubble(isKnown);
                    _resetTint();
                    _dragProgress = 0.0;                      // reset for next pair

                    if (currentIndex < widget.flashcards.length - 1) {
                      setState(() => currentIndex++);
                    } else {
                      setState(() => _completed = true);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 50),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    foregroundDecoration: BoxDecoration(
                      color: _cardTint,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: FlashcardWidget(flashcard: current),
                  ),
                ),
              ],
            ),
          ),
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
        child: _completed
            ? _buildSummary()
            : Column(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isListView
                          ? KeyedSubtree(
                              key: const ValueKey('list'),
                              child: _buildListView(),
                            )
                          : KeyedSubtree(
                              key: const ValueKey('cards'),
                              child: _buildFlashcardView(),
                            ),
                    ),
                  ),
                ],
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

class _PiePainter extends CustomPainter {
  final double knownFraction;
  final Color knownColor;
  final Color unknownColor;

  _PiePainter({
    required this.knownFraction,
    required this.knownColor,
    required this.unknownColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 16.0;
    final rect = Offset.zero & size;
    final startAngle = -pi / 2; // start at top
    final knownSweep = 2 * pi * knownFraction;
    final unknownSweep = 2 * pi * (1 - knownFraction);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // draw unknown first (so it shows as the "back")
    paint.color = unknownColor.withOpacity(.7);
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      startAngle + knownSweep,
      unknownSweep,
      false,
      paint,
    );

    // draw known
    paint.color = knownColor.withOpacity(.7);
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      startAngle,
      knownSweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PiePainter old) =>
      old.knownFraction != knownFraction;
}

class _AnimatedPieChart extends StatefulWidget {
  final double knownFraction;
  final Color knownColor;
  final Color unknownColor;
  final Duration duration;

  const _AnimatedPieChart({
    Key? key,
    required this.knownFraction,
    required this.knownColor,
    required this.unknownColor,
    this.duration = const Duration(milliseconds: 1200),
  }) : super(key: key);

  @override
  State<_AnimatedPieChart> createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<_AnimatedPieChart> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _animation =
      CurvedAnimation(parent: _controller, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.knownFraction != widget.knownFraction) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 200),
          painter: _PiePainter(
            knownFraction: widget.knownFraction * _animation.value,
            knownColor: widget.knownColor,
            unknownColor: widget.unknownColor,
          ),
        );
      },
    );
  }
}
