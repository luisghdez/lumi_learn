import 'package:flutter/material.dart';
import 'category_card.dart';

class CategoryList extends StatelessWidget {
  final Function(String) onCategoryTap;

  const CategoryList({
    Key? key,
    required this.onCategoryTap,
  }) : super(key: key);

  final List<Map<String, String>> categories = const [
    {
      'title': 'Our Daily Random',
      'subtitle': 'Lesson',
      'imagePath': 'assets/galaxies/galaxy3.png',
    },
    {
      'title': 'Math',
      'subtitle': 'Galaxy',
      'imagePath': 'assets/galaxies/galaxy3.png',
    },
    {
      'title': 'English',
      'subtitle': 'Galaxy',
      'imagePath': 'assets/galaxies/galaxy3.png',
    },
    {
      'title': 'Science',
      'subtitle': 'Galaxy',
      'imagePath': 'assets/galaxies/galaxy3.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: categories.map((category) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: CategoryCard(
            title: category['title']!,
            subtitle: category['subtitle']!,
            imagePath: category['imagePath']!,
            onTap: () => onCategoryTap(category['title']!),
          ),
        );
      }).toList(),
    );
  }
}
