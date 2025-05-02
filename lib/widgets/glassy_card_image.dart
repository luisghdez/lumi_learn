import 'dart:ui';
import 'package:flutter/material.dart';

class GlassyCardSideImage extends StatelessWidget {
  final String imagePath;
  final String courseName;
  final String description;
  final List<String> tags;
  final int bookmarkCount;
  final int lessonCount;
  final VoidCallback? onStartLearning;

  const GlassyCardSideImage({
    Key? key,
    required this.imagePath,
    required this.courseName,
    required this.description,
    required this.tags,
    required this.bookmarkCount,
    required this.lessonCount,
    this.onStartLearning,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Glass blur background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          // Border and content
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left image strip
                  Container(
                    width: 20,
                    height: double.infinity,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Right content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            courseName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11.5,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.bookmark_border,
                                  color: Colors.white60, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '$bookmarkCount',
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 11.5),
                              ),
                              const Spacer(),
                              Text(
                                '$lessonCount lessons',
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 11.5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children:
                                tags.map((tag) => _TagChip(label: tag)).toList(),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: onStartLearning,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white24),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              child: const Text('Start Learning!'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
        ),
      ),
    );
  }
}
