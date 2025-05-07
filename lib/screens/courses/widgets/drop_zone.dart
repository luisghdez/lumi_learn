import 'package:flutter/material.dart';
import 'package:lumi_learn_app/constants.dart';

class DropZone extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final String subLabel;

  const DropZone({
    Key? key,
    required this.onTap,
    required this.label,
    required this.subLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  children: [
                    const TextSpan(
                      text: "Click to upload ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    TextSpan(text: label),
                  ],
                ),
              ),
              Text(
                subLabel,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
