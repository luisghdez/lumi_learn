// lib/screens/search/components/search_bar.dart
import 'package:flutter/material.dart';

// search_bar.dart
class SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
      color: Colors.white24, width: 0.8),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFFB0B0B0)),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                hintText: 'Search friends...',
                hintStyle: TextStyle(
                  color: Color(0xFFB0B0B0),
                  fontFamily: 'Inter',
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

