// lib/screens/search/components/search_bar.dart
import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onSubmitted: (query) {
          // Handle search query submission
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Searching for "$query"...')),
          );
        },
      ),
    );
  }
}
