import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpgradePopup extends StatelessWidget {
  final String title;
  final String? subtitle;

  const UpgradePopup({
    Key? key,
    required this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null) ...[
            Text(
              subtitle!,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 12),
          ],
          const Text(
            "✨ Upgrade to Premium and get:",
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 10),
          const BenefitItem(text: "• Unlimited course creation"),
          const BenefitItem(text: "• Full access to all lessons"),
          const BenefitItem(
              text: "• Copy as many featured courses as you want"),
          const BenefitItem(text: "• Support continued development 🚀"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text("Not now", style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent.shade700,
          ),
          onPressed: () {
            Get.back();
            // Navigate to upgrade screen here
            // Get.to(() => const UpgradeScreen());
          },
          child: const Text("Upgrade"),
        ),
      ],
    );
  }
}

class BenefitItem extends StatelessWidget {
  final String text;
  const BenefitItem({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white60, fontSize: 14),
      ),
    );
  }
}
