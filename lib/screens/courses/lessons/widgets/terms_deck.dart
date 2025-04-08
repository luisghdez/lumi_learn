import 'dart:math'; // Need min and max
import 'dart:ui';
import 'package:flutter/material.dart';

// Assuming TermMasteryItem is defined elsewhere as provided before
// import 'term_mastery_item.dart';

// Helper class to hold info about a card to be displayed
class _CardDisplayInfo {
  final int index;
  final double initialOffset; // Offset relative to active card at 0
  final double scale;

  _CardDisplayInfo({
    required this.index,
    required this.initialOffset,
    required this.scale,
  });
}

class TermsDeck extends StatelessWidget {
  final List<String> terms;
  final List<double> progressList;
  final int currentTermIndex;
  final Duration animationDuration;

  // --- Constants for calculation ---
  static const double _containerHeight = 150.0;
  static const double _estimatedCardHeight = 75.0; // Adjust if needed
  static const double _verticalSeparation = 35.0; // Base separation

  // Scales (can be const)
  static const double _activeScale = 1.0;
  static const double _adjacentScale = 0.8;
  static const double _distantScale = 0.6;

  // Initial relative offsets (active card is reference at 0)
  static const double _activeInitialOffset = 0.0;
  static const double _prevInitialOffset = -_verticalSeparation;
  static const double _nextInitialOffset = _verticalSeparation;
  static const double _farPrevInitialOffset = -2 * _verticalSeparation;
  static const double _farNextInitialOffset = 1.8 * _verticalSeparation;
  // --- End Constants ---

  const TermsDeck({
    super.key,
    required this.terms,
    required this.progressList,
    required this.currentTermIndex,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  // Builder remains the same, just takes the final calculated offset
  Widget _buildAnimatedCard({
    required int termIndex,
    required double finalTopOffset, // Renamed for clarity
    required double scale,
    required BuildContext context,
  }) {
    // Check index validity (important!)
    if (termIndex < 0 || termIndex >= terms.length) {
      return const SizedBox.shrink();
    }

    return AnimatedPositioned(
      key: ValueKey(termIndex),
      duration: animationDuration,
      curve: Curves.easeInOut,
      top: finalTopOffset, // Use the final calculated offset
      left: 0,
      right: 0,
      child: AnimatedScale(
        duration: animationDuration,
        curve: Curves.easeInOut,
        scale: scale,
        alignment: Alignment.center,
        child: TermMasteryItem(
          term: terms[termIndex],
          progress: progressList[termIndex],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<_CardDisplayInfo> cardsToDisplay = [];
    final int lastIndex = terms.length - 1;

    // --- Step 1: Determine which cards to display and their initial info ---
    if (terms.isEmpty) {
      return SizedBox(height: _containerHeight); // Handle empty list
    }

    // Always add active card info
    cardsToDisplay.add(_CardDisplayInfo(
        index: currentTermIndex,
        initialOffset: _activeInitialOffset,
        scale: _activeScale));

    if (terms.length == 2) {
      if (currentTermIndex == 0) {
        cardsToDisplay.add(_CardDisplayInfo(
            index: 1,
            initialOffset: _nextInitialOffset,
            scale: _adjacentScale));
      } else {
        // currentTermIndex == 1
        cardsToDisplay.add(_CardDisplayInfo(
            index: 0,
            initialOffset: _prevInitialOffset,
            scale: _adjacentScale));
      }
    } else if (terms.length >= 3) {
      if (currentTermIndex == 0) {
        // Active(0), Next(1), Far Next(2)
        cardsToDisplay.add(_CardDisplayInfo(
            index: 1,
            initialOffset: _nextInitialOffset,
            scale: _adjacentScale));
        cardsToDisplay.add(_CardDisplayInfo(
            index: 2,
            initialOffset: _farNextInitialOffset,
            scale: _distantScale));
      } else if (currentTermIndex == lastIndex) {
        // Active(last), Previous(last-1), Far Previous(last-2)
        cardsToDisplay.add(_CardDisplayInfo(
            index: lastIndex - 1,
            initialOffset: _prevInitialOffset,
            scale: _adjacentScale));
        cardsToDisplay.add(_CardDisplayInfo(
            index: lastIndex - 2,
            initialOffset: _farPrevInitialOffset,
            scale: _distantScale));
      } else {
        // Middle case: Active, Previous, Next
        cardsToDisplay.add(_CardDisplayInfo(
            index: currentTermIndex - 1,
            initialOffset: _prevInitialOffset,
            scale: _adjacentScale));
        cardsToDisplay.add(_CardDisplayInfo(
            index: currentTermIndex + 1,
            initialOffset: _nextInitialOffset,
            scale: _adjacentScale));
      }
    }

    // --- Step 2: Calculate group bounds based on initial offsets ---
    double groupMinY = double.infinity;
    double groupMaxY = double.negativeInfinity;

    if (cardsToDisplay.isEmpty) {
      // Should not happen if terms is not empty, but safe to check
      return SizedBox(height: _containerHeight);
    }

    for (final cardInfo in cardsToDisplay) {
      // Check index validity again before accessing lists
      if (cardInfo.index < 0 || cardInfo.index >= terms.length) continue;

      final cardHeight = _estimatedCardHeight * cardInfo.scale;
      final cardTop = cardInfo.initialOffset;
      final cardBottom = cardTop + cardHeight;

      groupMinY = min(groupMinY, cardTop);
      groupMaxY = max(groupMaxY, cardBottom);
    }

    // Handle case where only one card exists, min/max might not have updated
    if (groupMinY == double.infinity) groupMinY = 0;
    if (groupMaxY == double.negativeInfinity) groupMaxY = _estimatedCardHeight;

    // --- Step 3: Calculate the vertical shift needed ---
    final double groupHeight = groupMaxY - groupMinY;
    final double groupCenterY = groupMinY + (groupHeight / 2.0);
    const double containerCenterY = _containerHeight / 2.0;
    final double deltaY = containerCenterY - groupCenterY; // Shift needed

    // --- Step 4: Build the widgets with final offsets ---
    final List<Widget> cardWidgets = [];

    // Create widgets for all cards using the calculated deltaY
    // Sort them by scale for correct visual stacking (smallest first)
    cardsToDisplay.sort((a, b) => a.scale.compareTo(b.scale));

    for (final cardInfo in cardsToDisplay) {
      // Check index validity one last time
      if (cardInfo.index < 0 || cardInfo.index >= terms.length) continue;

      final finalOffset = cardInfo.initialOffset + deltaY;
      cardWidgets.add(_buildAnimatedCard(
        termIndex: cardInfo.index,
        finalTopOffset: finalOffset,
        scale: cardInfo.scale,
        context: context,
      ));
    }

    // Return the SizedBox and Stack
    return SizedBox(
      height: _containerHeight,
      child: Stack(
        clipBehavior: Clip.none, // MUST allow overflow for this to work
        children: cardWidgets,
      ),
    );
  }
}

// TermMasteryItem remains the same as in your original code
class TermMasteryItem extends StatelessWidget {
  final String term;
  final double progress;

  const TermMasteryItem({
    Key? key,
    required this.term,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMastered = progress >= 1.0;

    return Container(
      // Removed margin from here, apply spacing via offsets if needed
      // margin: const EdgeInsets.symmetric(vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isMastered
                    ? const Color.fromARGB(99, 255, 217, 0)
                    : Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: Icon(
                    isMastered ? Icons.star_border : Icons.psychology,
                    color: isMastered
                        ? const Color.fromARGB(255, 181, 154, 0)
                        : Colors.white70,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Term + Progress
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            term,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(
                              color: isMastered
                                  ? const Color(0x33FFD700)
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isMastered ? Icons.check : null,
                                  size: isMastered ? 16 : 0,
                                  color: isMastered
                                      ? const Color.fromARGB(255, 181, 154, 0)
                                      : Colors.transparent,
                                ),
                                if (isMastered) const SizedBox(width: 4),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 12, // Consistent size maybe?
                                    color: isMastered
                                        ? const Color(0xFFFFD700)
                                        : const Color.fromARGB(
                                            129, 255, 255, 255),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 5,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: progress),
                            duration: const Duration(milliseconds: 300),
                            builder: (context, animatedProgress, child) {
                              // Ensure progress doesn't exceed 1.0 for display
                              final displayProgress =
                                  animatedProgress.clamp(0.0, 1.0);
                              return LinearProgressIndicator(
                                value: displayProgress,
                                backgroundColor:
                                    const Color.fromARGB(113, 158, 158, 158),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isMastered
                                      ? const Color.fromARGB(255, 225, 191, 0)
                                      : Colors
                                          .white, // Use white for non-mastered
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
