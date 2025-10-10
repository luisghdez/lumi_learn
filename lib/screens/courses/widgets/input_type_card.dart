import 'package:flutter/material.dart';

class InputTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String examples;
  final bool isSelected;
  final VoidCallback onTap;

  const InputTypeCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.examples,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive sizing - bigger for tablets/iPads
    final cardPadding = screenWidth > 600 ? 28.0 : 20.0;
    final iconSize = screenWidth > 600 ? 64.0 : 48.0;
    final iconInnerSize = screenWidth > 600 ? 32.0 : 24.0;
    final horizontalSpacing = screenWidth > 600 ? 24.0 : 16.0;
    final indicatorSize = screenWidth > 600 ? 16.0 : 12.0;
    
    // Font sizes - bigger for tablets/iPads
    final titleSize = screenWidth > 600 ? 22.0 : 18.0;
    final descSize = screenWidth > 600 ? 16.0 : 14.0;
    final exampleSize = screenWidth > 600 ? 14.0 : 12.0;
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween<double>(begin: 1.0, end: isSelected ? 1.02 : 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: EdgeInsets.all(cardPadding),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected ? Colors.white : Colors.grey.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Icon
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: iconInnerSize,
                    ),
                  ),
                  SizedBox(width: horizontalSpacing),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: descSize,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          examples,
                          style: TextStyle(
                            fontSize: exampleSize,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Selection indicator
                  AnimatedScale(
                    scale: isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: indicatorSize,
                      height: indicatorSize,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}