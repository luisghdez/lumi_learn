import 'dart:ui';
import 'package:flutter/material.dart';
// Remove Get import if not used elsewhere, it's not needed for this specific widget anymore
// import 'package:get/get.dart';

class TermsDeck extends StatelessWidget {
  final List<String> terms;
  final List<double> progressList;
  final int currentTermIndex;
  final Duration animationDuration; // Allow customizing duration

  const TermsDeck({
    super.key, // Use super parameters
    required this.terms,
    required this.progressList,
    required this.currentTermIndex,
    this.animationDuration =
        const Duration(milliseconds: 300), // Default duration
  });

  // Helper to build the animated card widget
  Widget _buildAnimatedCard({
    required int termIndex,
    required double targetOffset,
    required double targetScale,
    required BuildContext context, // Pass context if needed by TermMasteryItem
  }) {
    // Ensure index is valid before building
    if (termIndex < 0 || termIndex >= terms.length) {
      return const SizedBox.shrink(); // Return empty if index is out of bounds
    }

    return AnimatedPositioned(
      key: ValueKey(termIndex), // Crucial for smooth animation tracking
      duration: animationDuration,
      curve: Curves.easeInOut, // Smooth animation curve
      top: targetOffset, // Animate the vertical position
      left: 0,
      right: 0,
      child: AnimatedScale(
        duration: animationDuration,
        curve: Curves.easeInOut,
        scale: targetScale, // Animate the scale
        alignment: Alignment.topCenter,
        child: TermMasteryItem(
          // No need for Obx here if TermMasteryItem handles its own state
          term: terms[termIndex],
          progress: progressList[termIndex],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define styles for different card states
    const double activeScale = 1.0;
    const double adjacentScale = 0.9; // Scale for immediate neighbors
    const double distantScale = 0.8; // Scale for cards further away

    const double activeOffset = 0.0;
    const double nextOffset = 35.0; // Offset for the card below active
    const double previousOffset = -35.0; // Offset for the card above active
    const double farNextOffset = 70.0; // Offset for the card 2 steps below
    const double farPreviousOffset = -70.0; // Offset for the card 2 steps above

    List<Widget> cardWidgets = [];

    // Determine indices and styles based on currentTermIndex
    final int prevIndex = currentTermIndex - 1;
    final int nextIndex = currentTermIndex + 1;
    final int prev2Index = currentTermIndex - 2;
    final int next2Index = currentTermIndex + 2;

    // --- Logic to determine which cards to show and their styles ---

    // Always add the active card (will be visually on top)
    final activeCard = _buildAnimatedCard(
      termIndex: currentTermIndex,
      targetOffset: activeOffset,
      targetScale: activeScale,
      context: context,
    );

    Widget? previousCard;
    Widget? nextCard;
    Widget? bottomCard; // For the card visually at the bottom

    if (terms.length == 1) {
      // Only the active card
    } else if (terms.length == 2) {
      if (currentTermIndex == 0) {
        // Active (0) and Next (1)
        nextCard = _buildAnimatedCard(
            termIndex: nextIndex,
            targetOffset: nextOffset,
            targetScale: adjacentScale,
            context: context);
      } else {
        // currentTermIndex == 1
        // Active (1) and Previous (0)
        previousCard = _buildAnimatedCard(
            termIndex: prevIndex,
            targetOffset: previousOffset,
            targetScale: adjacentScale,
            context: context);
      }
    } else {
      // terms.length >= 3
      if (currentTermIndex == 0) {
        // Active(0), Next(1), Far Next(2)
        nextCard = _buildAnimatedCard(
            termIndex: nextIndex,
            targetOffset: nextOffset,
            targetScale: adjacentScale,
            context: context);
        bottomCard = _buildAnimatedCard(
            // Visually bottom-most
            termIndex: next2Index,
            targetOffset: farNextOffset,
            targetScale: distantScale,
            context: context);
      } else if (currentTermIndex == terms.length - 1) {
        // Active(last), Previous(last-1), Far Previous(last-2)
        previousCard = _buildAnimatedCard(
            termIndex: prevIndex,
            targetOffset: previousOffset,
            targetScale: adjacentScale,
            context: context);
        bottomCard = _buildAnimatedCard(
            // Visually bottom-most
            termIndex: prev2Index,
            targetOffset: farPreviousOffset,
            targetScale: distantScale,
            context: context);
      } else {
        // Active, Previous, Next
        previousCard = _buildAnimatedCard(
            termIndex: prevIndex,
            targetOffset: previousOffset,
            targetScale: adjacentScale,
            context: context);
        nextCard = _buildAnimatedCard(
            termIndex: nextIndex,
            targetOffset: nextOffset,
            targetScale: adjacentScale,
            context: context);
        // In the middle case, decide which one is visually "bottom"
        // Often, the 'next' card feels more natural at the bottom visually
        // when both prev/next have the same scale. Let's try putting 'next'
        // below 'previous' visually by adding it first to the stack.
        // (We'll add them in visual order below)
      }
    }

    // Build the stack children list IN VISUAL ORDER (bottom first)
    // Add the card that should appear furthest back / smallest first.
    if (currentTermIndex == 0 && terms.length >= 3) {
      // Order: Far Next (bottom), Next, Active (top)
      if (bottomCard != null) cardWidgets.add(bottomCard);
      if (nextCard != null) cardWidgets.add(nextCard);
    } else if (currentTermIndex == terms.length - 1 && terms.length >= 3) {
      // Order: Far Previous (bottom), Previous, Active (top)
      if (bottomCard != null) cardWidgets.add(bottomCard);
      if (previousCard != null) cardWidgets.add(previousCard);
    } else if (terms.length >= 3) {
      // Middle case: Active, Previous, Next. Let's put Next visually below Previous.
      // Order: Next (bottom), Previous, Active (top)
      if (nextCard != null) cardWidgets.add(nextCard);
      if (previousCard != null) cardWidgets.add(previousCard);
    } else if (terms.length == 2) {
      // Only one other card besides active
      if (nextCard != null) cardWidgets.add(nextCard); // If index 0 is active
      if (previousCard != null)
        cardWidgets.add(previousCard); // If index 1 is active
    }
    // Always add active card last so it's visually on top
    cardWidgets.add(activeCard);

    return SizedBox(
      // Height remains constant
      height: 150, // Adjust if TermMasteryItem base height changes
      child: Stack(
        clipBehavior: Clip.none, // Allow cards to draw outside bounds slightly
        alignment: Alignment.topCenter, // Align stack items centrally
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
                                  isMastered
                                      ? 'Mastered' // Show text when mastered
                                      : '${(progress * 100).toInt()}%',
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
