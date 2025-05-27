import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lumi_learn_app/constants.dart';

/// A tappable box that shows “Click to set due date” or the chosen due date.
class DueDateDropZone extends StatelessWidget {
  final DateTime? dueDate;
  final VoidCallback onTap;

  const DueDateDropZone({
    Key? key,
    required this.dueDate,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(fontSize: 14, color: Colors.grey);
    const valueStyle =
        TextStyle(fontWeight: FontWeight.bold, color: Colors.white);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 98,
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          border: Border.all(color: greyBorder, width: 1),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[1000],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  style: labelStyle,
                  children: [
                    TextSpan(
                      text: dueDate == null ? "Click to set " : "Due Date: ",
                      style: valueStyle,
                    ),
                    TextSpan(
                      text: dueDate == null
                          ? "due date"
                          : DateFormat.yMd().add_jm().format(dueDate!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Set a due date for this course",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
