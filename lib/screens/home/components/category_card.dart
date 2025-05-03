import 'package:flutter/material.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/widgets/tag_chip.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final int completedLessons;
  final int totalLessons;
  final String imagePath;
  final List<String> tags;
  final VoidCallback onTap;

  const CategoryCard({
    Key? key,
    required this.title,
    required this.completedLessons,
    required this.totalLessons,
    required this.imagePath,
    required this.tags,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    final double cardHeight = isTablet ? 180.0 : 120.0;

    final double progress =
        totalLessons > 0 ? completedLessons / totalLessons : 0.0;

    final List<String> displayTags =
        tags.isEmpty ? ['#LumiOG', '#classic'] : tags;

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          border: Border.all(
            color: greyBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: -6,
                      children: displayTags
                          .map((tag) => TagChip(label: tag))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final barWidth = constraints.maxWidth * 0.45;

                        return Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: barWidth,
                                height: 8,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: progress),
                                  duration: const Duration(milliseconds: 300),
                                  builder: (context, animatedProgress, child) {
                                    return LinearProgressIndicator(
                                      value: animatedProgress,
                                      backgroundColor: Colors.white30,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "$completedLessons/$totalLessons Lessons",
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 11,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
