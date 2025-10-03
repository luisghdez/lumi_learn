import 'package:flutter/material.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/widgets/tag_chip.dart';
import 'package:lumi_learn_app/widgets/course_options_dialog.dart';
import 'package:lumi_learn_app/utils/course_delete_helper.dart';

class CategoryCard extends StatelessWidget {
  final String courseId;
  final String title;
  final int completedLessons;
  final int totalLessons;
  final String imagePath;
  final List<String> tags;
  final VoidCallback onTap;
  final String? subject;
  final bool hasEmbeddings;

  const CategoryCard({
    Key? key,
    required this.courseId,
    required this.title,
    required this.completedLessons,
    required this.totalLessons,
    required this.imagePath,
    required this.tags,
    required this.onTap,
    this.subject,
    this.hasEmbeddings = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    final double cardHeight = isTablet ? 180.0 : 120.0;

    final double progress =
        totalLessons > 0 ? completedLessons / totalLessons : 0.0;

    List<String> displayTags = List.from(tags);

    // Add subject tag if hasEmbeddings is true and subject is available
    if (hasEmbeddings && subject != null && subject!.isNotEmpty) {
      displayTags.insert(0, subject!);
    } else if (tags.isEmpty) {
      // Only show default tags when no subject and no other tags
      displayTags = ['#Classic'];
    }

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
              child: GestureDetector(
                onTap: () {
                  showCourseOptionsDialog(
                    context: context,
                    courseId: courseId,
                    courseTitle: title,
                    onDelete: () async {
                      Navigator.of(context).pop();

                      // Use the helper to handle deletion
                      await CourseDeleteHelper.showDeleteConfirmationAndDelete(
                        context: context,
                        courseId: courseId,
                        courseTitle: title,
                      );
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.more_horiz,
                    size: 16,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
