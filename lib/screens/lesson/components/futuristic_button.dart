import 'package:flutter/material.dart';

class FuturisticButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;

  const FuturisticButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.black),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
