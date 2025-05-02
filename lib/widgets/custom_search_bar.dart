import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final void Function(String) onChanged;
  final TextEditingController? controller;

  const CustomSearchBar({
    Key? key,
    required this.onChanged,
    this.hintText = 'Search...',
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.of(context).textScaleFactor;

    return LayoutBuilder(builder: (context, constraints) {
      final bool isTablet = constraints.maxWidth > 600;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: TextField(
          controller: controller,
          style: TextStyle(color: Colors.white, fontSize: isTablet ? 16 * scale : 14 * scale),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.white54, fontSize: isTablet ? 15 : 13),
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              vertical: isTablet ? 16 : 12,
              horizontal: 16,
            ),
          ),
        ),
      );
    });
  }
}
