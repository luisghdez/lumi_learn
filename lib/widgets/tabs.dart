import 'package:flutter/material.dart';

class CustomTab {
  final String label;
  final IconData? icon;

  const CustomTab({required this.label, this.icon});
}

class CustomTabSelector extends StatelessWidget {
  final List<CustomTab> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const CustomTabSelector({
    Key? key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.of(context).textScaleFactor;

    return LayoutBuilder(builder: (context, constraints) {
      final bool isTablet = constraints.maxWidth > 600;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        padding: const EdgeInsets.all(4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(tabs.length, (index) {
              return _TabButton(
                label: tabs[index].label,
                icon: tabs[index].icon,
                isSelected: selectedIndex == index,
                onTap: () => onTabSelected(index),
                isTablet: isTablet,
                scale: scale,
              );
            }),
          ),
        ),
      );
    });
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isTablet;
  final double scale;

  const _TabButton({
    Key? key,
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isTablet,
    required this.scale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color textColor = isSelected ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? 14 : 10,
                horizontal: isTablet ? 20 : 14,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: textColor, size: isTablet ? 20 : 16),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 16 * scale : 14 * scale,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
