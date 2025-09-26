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
        height: 170,
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
              //  add a upload icon
              const Icon(Icons.ios_share_outlined,
                  size: 42, color: Colors.grey),
              const SizedBox(height: 16),
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
