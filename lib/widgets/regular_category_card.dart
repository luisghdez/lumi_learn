import 'package:flutter/material.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/widgets/tag_chip.dart';
import 'package:lumi_learn_app/widgets/course_options_dialog.dart';
import 'package:lumi_learn_app/utils/course_delete_helper.dart';
import 'package:share/share.dart';

class RegularCategoryCard extends StatelessWidget {
  final String? courseId;
  final String imagePath;
  final String courseName;
  final List<String> tags;
  final int bookmarkCount;
  final int lessonCount;
  final VoidCallback? onStartLearning;
  final String? subject;
  final bool hasEmbeddings;
  final bool showOptionsMenu;
  final bool showShareIcon;

  const RegularCategoryCard({
    Key? key,
    this.courseId,
    required this.imagePath,
    required this.courseName,
    required this.tags,
    required this.bookmarkCount,
    required this.lessonCount,
    this.onStartLearning,
    this.subject,
    this.hasEmbeddings = false,
    this.showOptionsMenu = false,
    this.showShareIcon = false,
  }) : super(key: key);

  void _shareCourse() {
    if (courseId != null) {
      final shareLink = 'https://www.lumilearnapp.com/course/$courseId';
      Share.share(
        "🚀 Check out $courseName on Lumi Learn: \n$shareLink",
      );
    }
  }

  Widget _buildTopRightIcon(BuildContext context) {
    // Priority: Options menu > Share icon > Arrow icon
    if (showOptionsMenu && courseId != null) {
      // Saved courses: Show options menu
      return GestureDetector(
        onTap: () {
          showCourseOptionsDialog(
            context: context,
            courseId: courseId!,
            courseTitle: courseName,
            onDelete: () async {
              Navigator.of(context).pop();

              // Use the helper to handle deletion
              await CourseDeleteHelper.showDeleteConfirmationAndDelete(
                context: context,
                courseId: courseId!,
                courseTitle: courseName,
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
      );
    } else if (showShareIcon && courseId != null) {
      // Browsable courses: Show direct share icon
      return GestureDetector(
        onTap: _shareCourse,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.share,
            size: 14,
            color: Colors.white54,
          ),
        ),
      );
    } else {
      // Default: Show arrow icon
      return Container(
        padding: const EdgeInsets.all(6),
        child: const Icon(
          Icons.arrow_forward,
          size: 14,
          color: Colors.white,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

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
      onTap: onStartLearning,
      child: Container(
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
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    courseName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 18 : 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: displayTags
                            .map((tag) => TagChip(label: tag))
                            .toList(),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.bookmark_border,
                          color: Colors.white60, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$bookmarkCount',
                        style: TextStyle(
                            color: Colors.white60,
                            fontSize: isTablet ? 14 : 12),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '$lessonCount lessons',
                        style: TextStyle(
                            color: Colors.white60,
                            fontSize: isTablet ? 14 : 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _buildTopRightIcon(context),
            ),
          ],
        ),
      ),
    );
  }
}
