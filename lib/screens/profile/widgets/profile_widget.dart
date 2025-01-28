// lib/screens/profile/widgets/profile_widget.dart
import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({Key? key}) : super(key: key);

  // Example profile options
  final List<Map<String, dynamic>> options = const [
    {'title': 'Settings', 'icon': Icons.settings},
    {'title': 'Notifications', 'icon': Icons.notifications},
    {'title': 'Help & Support', 'icon': Icons.help},
    {'title': 'Logout', 'icon': Icons.logout},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: options.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final option = options[index];
        return ListTile(
          leading: Icon(option['icon'], color: Colors.blue),
          title: Text(option['title']),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Handle option tap
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${option['title']} tapped')),
            );
          },
        );
      },
    );
  }
}
