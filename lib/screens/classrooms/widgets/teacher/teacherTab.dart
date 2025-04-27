import 'package:flutter/material.dart';

class TeacherTabs extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const TeacherTabs({
    Key? key,
    required this.selectedIndex,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTabletOrBigger = screenWidth > 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _TabButton(
            label: 'My Classrooms',
            isSelected: selectedIndex == 0,
            onTap: () => onTabSelected(0),
            isTabletOrBigger: isTabletOrBigger,
          ),
          _TabButton(
            label: 'Recent Submissions',
            isSelected: selectedIndex == 1,
            onTap: () => onTabSelected(1),
            isTabletOrBigger: isTabletOrBigger,
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isTabletOrBigger;

  const _TabButton({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isTabletOrBigger,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                vertical: isTabletOrBigger ? 16 : 10,
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isTabletOrBigger ? 18 : 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
