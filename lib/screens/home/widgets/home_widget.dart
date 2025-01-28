// lib/screens/home/widgets/home_widget.dart
import 'package:flutter/material.dart';
import '../components/home_item.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({Key? key}) : super(key: key);

  // Example list of items
  final List<Map<String, dynamic>> items = const [
    {'title': 'Item 1', 'icon': Icons.star},
    {'title': 'Item 2', 'icon': Icons.favorite},
    {'title': 'Item 3', 'icon': Icons.person},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final item = items[index];
        return HomeItem(
          title: item['title'],
          icon: item['icon'],
          onTap: () {
            // Handle item tap, e.g., navigate to detail screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${item['title']} tapped')),
            );
          },
        );
      },
    );
  }
}
