import 'package:flutter/material.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/screens/courses/widgets/badge.dart';

class SummaryCard extends StatelessWidget {
  final int totalItems;
  final int fileCount;
  final int imageCount;
  final bool hasText;

  const SummaryCard({
    Key? key,
    required this.totalItems,
    required this.fileCount,
    required this.imageCount,
    required this.hasText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Course Content",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: greyBorder),
                ),
                child: Text(
                  "$totalItems item${totalItems != 1 ? "s" : ""}",
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // badges
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (fileCount > 0)
                CustomBadge(
                    icon: Icons.file_copy,
                    label: "$fileCount file${fileCount != 1 ? "s" : ""}"),
              if (imageCount > 0)
                CustomBadge(
                    icon: Icons.image_outlined,
                    label: "$imageCount image${imageCount != 1 ? "s" : ""}"),
              if (hasText)
                const CustomBadge(icon: Icons.text_fields, label: "Text"),
            ],
          ),
        ],
      ),
    );
  }
}
