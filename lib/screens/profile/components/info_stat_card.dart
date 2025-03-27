import 'package:flutter/material.dart';
import 'package:lumi_learn_app/constants.dart';

class InfoStatCard extends StatelessWidget {
  final IconData? icon; // Made icon optional
  final String value;
  final String label;
  final bool background;

  const InfoStatCard({
    super.key,
    this.icon, // No longer required
    required this.value,
    required this.label,
    this.background = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: background
          ? BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: greyBorder, width: 0.8),
            )
          : null,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 6),
              ],
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
