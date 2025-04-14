import 'package:flutter/material.dart';
import 'package:lumi_learn_app/constants.dart';

class OptionsList extends StatelessWidget {
  final List<String> options;
  final ValueNotifier<int> selectedOption;
  final bool isTablet;

  const OptionsList({
    Key? key,
    required this.options,
    required this.selectedOption,
    this.isTablet = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = isTablet ? 24.0 : 16.0;
    final double verticalPadding = isTablet ? 26.0 : 12.0;
    final double fontSize = isTablet ? 20.0 : 16.0;
    final double circleSize = isTablet ? 44.0 : 28.0;
    final double letterSize = isTablet ? 16.0 : 14.0;

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
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(122, 0, 0, 0),
                  borderRadius: BorderRadius.circular(32.0),
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 1)
                      : Border.all(color: greyBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: circleSize / 2,
                      backgroundColor:
                          isSelected ? Colors.white : const Color(0xFF4A4A4A),
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C...
                        style: TextStyle(
                          fontSize: letterSize,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        optionText,
                        style: TextStyle(
                          color: const Color.fromARGB(221, 244, 244, 244),
                          fontSize: fontSize,
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
