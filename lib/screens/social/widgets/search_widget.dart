// lib/screens/search/widgets/search_widget.dart
import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({Key? key}) : super(key: key);

  // Example search results
  final List<String> searchResults = const [
    'Result 1',
    'Result 2',
    'Result 3',
    'Result 4',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final result = searchResults[index];
        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(result),
          onTap: () {
            // Handle result tap
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selected "$result"')),
            );
          },
        );
      },
    );
  }
}
