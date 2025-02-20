// lib/screens/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:lumi_learn_app/widgets/app_scaffold.dart';
import 'components/search_bar.dart' as custom;
import 'widgets/search_widget.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Main layout of the Search Screen
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: const Column(
        children: [
          custom.SearchBar(),
          Expanded(
            child: SearchWidget(),
          ),
        ],
      ),
    );
  }
}
