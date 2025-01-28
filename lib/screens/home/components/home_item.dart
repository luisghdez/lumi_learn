// lib/screens/home/components/home_item.dart
import 'package:flutter/material.dart';

class HomeItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const HomeItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
