import 'package:flutter/material.dart';
import 'package:lumi_learn_app/constants.dart';

class OptionsList extends StatelessWidget {
  final List<String> options;
  final ValueNotifier<int> selectedOption;

  const OptionsList({
    Key? key,
    required this.options,
    required this.selectedOption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedOption,
      builder: (context, selected, _) {
        return ListView.builder(
          padding: const EdgeInsets.only(top: 16.0),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final optionText = options[index];
            final isSelected = selected == index;
            return GestureDetector(
              onTap: () => selectedOption.value = index,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(122, 0, 0, 0),
                  borderRadius: BorderRadius.circular(32.0),
                  border: isSelected
                      ? Border.all(
                          color: Colors.white,
                          width: 1,
                        )
                      : Border.all(
                          // imported from contants.dart
                          color: greyBorder,
                        ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          isSelected ? Colors.white : const Color(0xFF4A4A4A),
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, ...
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        optionText,
                        style: const TextStyle(
                          color: Color.fromARGB(221, 244, 244, 244),
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
