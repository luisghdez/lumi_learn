import 'package:flutter/material.dart';
import 'package:lumi_learn_app/screens/profile/profile_screen.dart';
import 'package:lumi_learn_app/widgets/profile_avatar.dart';


class HomeHeader extends StatelessWidget {
  final String userName;

  const HomeHeader({
    Key? key,
    required this.userName,
  }) : super(key: key);

  

  void _navigateToProfile(BuildContext context) {
    // Replace this with your actual navigation logic
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen()), // Ensure you have ProfilePage defined
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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

        // Right side: Profile avatar with glow effect
        ProfileAvatar(
          onTap: () => _navigateToProfile(context),
        ),
      ],
    );
  }
}