import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';

/// Shows a course options dialog with share and delete options
void showCourseOptionsDialog({
  required BuildContext context,
  required String courseId,
  required String courseTitle,
  VoidCallback? onDelete,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => CourseOptionsDialog(
      courseId: courseId,
      courseTitle: courseTitle,
      onDelete: onDelete,
    ),
  );
}

class CourseOptionsDialog extends StatelessWidget {
  final String courseId;
  final String courseTitle;
  final VoidCallback? onDelete;

  const CourseOptionsDialog({
    Key? key,
    required this.courseId,
    required this.courseTitle,
    this.onDelete,
  }) : super(key: key);

  void _shareCourse() {
    final shareLink = 'https://www.lumilearnapp.com/course/$courseId';

    // Copy to clipboard
    Share.share(
        "🚀 Dive into $courseTitle with me on Lumi Learn: \n$shareLink");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Course title
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              courseTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Options
          _buildOption(
            icon: Icons.share,
            title: 'Share Course',
            subtitle: 'Copy link to share with others',
            onTap: _shareCourse,
          ),

          const Divider(
            color: Colors.white12,
            height: 1,
            indent: 20,
            endIndent: 20,
          ),

          _buildOption(
            icon: Icons.delete_outline,
            title: 'Delete Course',
            subtitle: 'Remove from your courses',
            onTap: onDelete,
            isDestructive: true,
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDestructive ? Colors.red : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDestructive
                          ? Colors.red.withOpacity(0.7)
                          : Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
