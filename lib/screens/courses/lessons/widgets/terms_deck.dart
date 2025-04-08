import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsDeck extends StatelessWidget {
  final List<String> terms;
  final List<double> progressList;
  final int currentTermIndex;

  const TermsDeck({
    Key? key,
    required this.terms,
    required this.progressList,
    required this.currentTermIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We'll always show exactly 3 cards:
    // - For currentTermIndex == 0: active + 2 upcoming cards.
    // - For currentTermIndex == last: active + 2 previous cards.
    // - Otherwise: one previous, active, one upcoming.
    List<Widget> children = [];

    // Helper method to create a positioned card.
    Widget buildCard({
      required int termIndex,
      required double offset,
      required double scale,
    }) {
      return Positioned(
        top: offset,
        left: 0,
        right: 0,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topCenter,
          child: Obx(
            () => TermMasteryItem(
              term: terms[termIndex],
              progress: progressList[termIndex],
            ),
          ),
        ),
      );
    }

    // Determine which cards to show based on the active index.
    if (currentTermIndex == 0) {
      // No previous term exists.
      // Show active (index 0), then upcoming ones (index 1 and 2).
      // Order: bottom (furthest upcoming), then upcoming, then active on top.
      int next1 = currentTermIndex + 1;
      int next2 = currentTermIndex + 2;
      children.add(buildCard(termIndex: next2, offset: 70, scale: 0.8));
      children.add(buildCard(termIndex: next1, offset: 35, scale: 0.9));
      children
          .add(buildCard(termIndex: currentTermIndex, offset: 0, scale: 1.0));
    } else if (currentTermIndex == terms.length - 1) {
      // No upcoming term exists.
      // Show two previous cards (active's older ones) along with the active card.
      // Order: bottom (oldest previous), then previous, then active on top.
      int prev2 = currentTermIndex - 2;
      int prev1 = currentTermIndex - 1;
      children.add(buildCard(termIndex: prev2, offset: -70, scale: 0.8));
      children.add(buildCard(termIndex: prev1, offset: -35, scale: 0.9));
      children
          .add(buildCard(termIndex: currentTermIndex, offset: 0, scale: 1.0));
    } else {
      // In the middle: one previous and one upcoming.
      // Order: bottom (upcoming), then previous, then active on top.
      int prev = currentTermIndex - 1;
      int next = currentTermIndex + 1;
      children.add(buildCard(termIndex: next, offset: 35, scale: 0.9));
      children.add(buildCard(termIndex: prev, offset: -35, scale: 0.9));
      children
          .add(buildCard(termIndex: currentTermIndex, offset: 0, scale: 1.0));
    }

    return SizedBox(
      height: 150,
      child: Stack(
        clipBehavior: Clip.none,
        children: children,
      ),
    );
  }
}

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
      margin: const EdgeInsets.symmetric(vertical: 4),
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
                                      ? ''
                                      : '${(progress * 100).toInt()}%',
                                  style: TextStyle(
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
                              return LinearProgressIndicator(
                                value: animatedProgress,
                                backgroundColor:
                                    const Color.fromARGB(113, 158, 158, 158),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isMastered
                                      ? const Color.fromARGB(255, 225, 191, 0)
                                      : Colors.white,
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
