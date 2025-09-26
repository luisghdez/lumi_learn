import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/widgets/tag_chip.dart';

class HorizontalCategoryCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onConfirm;
  final double height;
  final List<String> tags;
  final String? subject;
  final bool hasEmbeddings;

  const HorizontalCategoryCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.onConfirm,
    required this.height,
    required this.tags,
    this.subject,
    this.hasEmbeddings = false,
  }) : super(key: key);

  static const double _aspectRatio = 220 / 140;

  void _showConfirmationDialog(BuildContext context) {
    List<String> displayTags = List.from(tags);

    // Add subject tag if hasEmbeddings is true and subject is available
    if (hasEmbeddings && subject != null && subject!.isNotEmpty) {
      displayTags.insert(0, subject!);
    } else if (tags.isEmpty) {
      // Only show default tags when no subject and no other tags
      displayTags = ['#LumiOG', '#classic'];
    }

    Get.generalDialog(
      barrierDismissible: true,
      barrierLabel: "Course Confirm",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return const SizedBox.shrink(); // required but unused
      },
      transitionBuilder: (context, animation, _, __) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        return SlideTransition(
          position: offsetAnimation,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {}, // Prevent outside tap
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, right: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Created by: Anonymous',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: -6,
                          children: displayTags
                              .map((tag) => TagChip(label: tag))
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bookmark_border,
                                color: Colors.white60, size: 18),
                            SizedBox(width: 4),
                            Text(
                              '24',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                            SizedBox(width: 16),
                            Icon(Icons.menu_book_rounded,
                                color: Colors.white60, size: 18),
                            SizedBox(width: 4),
                            Text(
                              '4 lessons',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 42,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back(); // Close dialog
                              onConfirm(); // Proceed
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Start Learning'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double cardHeight = height;
    final double cardWidth = cardHeight * _aspectRatio;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    List<String> displayTags = List.from(tags);

    // Add subject tag if hasEmbeddings is true and subject is available
    if (hasEmbeddings && subject != null && subject!.isNotEmpty) {
      displayTags.insert(0, subject!);
    } else if (tags.isEmpty) {
      // Only show default tags when no subject and no other tags
      displayTags = ['#LumiOG', '#classic'];
    }

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: GestureDetector(
        onTap: () => _showConfirmationDialog(context),
        child: Stack(
          children: [
            // Card background
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: greyBorder, width: 1),
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Black overlay
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  // Title and tags
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.left,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: -6,
                            children: displayTags
                                .map((tag) => TagChip(label: tag))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Arrow icon
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
          ],
        ),
      ),
    );
  }
}
