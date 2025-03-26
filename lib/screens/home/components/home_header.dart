import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String userName;

  const HomeHeader({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.8),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userName.length > 15 ? '${userName.substring(0, 15)}-' : userName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 0.9,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}
