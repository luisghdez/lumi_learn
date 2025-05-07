import 'package:flutter/material.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/screens/courses/widgets/section_header.dart';

class CourseDetailsCard extends StatelessWidget {
  final String title;
  final String description;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescriptionChanged;

  const CourseDetailsCard({
    Key? key,
    required this.title,
    required this.description,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: greyBorder),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(icon: Icons.menu_book, title: "Course Details"),
          const SizedBox(height: 10),

          // Title
          const Text(
            "Course Title (required)",
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: greyBorder),
            ),
            child: TextField(
              maxLength: 30,
              onChanged: onTitleChanged,
              style: const TextStyle(fontSize: 12, color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                hintText: "Enter course title",
                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                border: InputBorder.none,
                counterText: "",
                suffix: Text(
                  "${title.length}/30",
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Description
          const Text(
            "Course Description",
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: greyBorder),
            ),
            child: TextField(
              onChanged: onDescriptionChanged,
              style: const TextStyle(fontSize: 12, color: Colors.white),
              cursorColor: Colors.white,
              minLines: 2,
              maxLines: 2,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                hintText: "Briefly describe what this course is about",
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
