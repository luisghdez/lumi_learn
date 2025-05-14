import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final int selectedIndex;
  final void Function(int) onCategoryTap;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final item = categories[index];
            final isSelected = index == selectedIndex;

            return GestureDetector(
              onTap: () => onCategoryTap(index),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: isSelected ? 75 : 65,
                    height: isSelected ? 75 : 65,
                    decoration: BoxDecoration(
                      color: item['color'],
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: item['color'].withOpacity(0.4),
                            blurRadius: 10,
                          ),
                      ],
                    ),
                    child: Icon(
                      item['icon'],
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['name'],
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
