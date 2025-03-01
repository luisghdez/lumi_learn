import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final VoidCallback onAvatarTap;

  const HomeHeader({
    Key? key,
    required this.userName,
    required this.onAvatarTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      // Space between text on the left and avatar on the right
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side: Welcome text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Onboard,',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),

        // Right side: Profile avatar
        InkWell(
          onTap: onAvatarTap,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade300,
            // Replace with actual user profile image if available
            backgroundImage: AssetImage(
              'assets/worlds/trees2.png', 
            ),
          ),
        ),
      ],
    );
  }
}
