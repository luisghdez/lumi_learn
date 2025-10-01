import 'package:flutter/material.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/widgets/tag_chip.dart';

class RegularCategoryCard extends StatelessWidget {
  final String imagePath;
  final String courseName;
  final List<String> tags;
  final int bookmarkCount;
  final int lessonCount;
  final VoidCallback? onStartLearning;
  final String? subject;
  final bool hasEmbeddings;

  const RegularCategoryCard({
    Key? key,
    required this.imagePath,
    required this.courseName,
    required this.tags,
    required this.bookmarkCount,
    required this.lessonCount,
    this.onStartLearning,
    this.subject,
    this.hasEmbeddings = false,
  }) : super(key: key);

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
