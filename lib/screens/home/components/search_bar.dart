import 'package:flutter/material.dart';
import 'package:lumi_learn_app/constants.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Find Course...',
        hintStyle: TextStyle(color: Colors.white54),
        prefixIcon:
            const Icon(Icons.search, color: Color.fromARGB(255, 255, 255, 255)),
        // filled: true,
        // fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: greyBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: greyBorder, width: 1.0),
        ),
      ),
    );
  }
}
