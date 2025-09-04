import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumi_learn_app/constants.dart';

class TextInputSection extends StatelessWidget {
  final String text;
  final int maxLength;
  final int minLength;
  final ValueChanged<String> onChanged;

  const TextInputSection({
    Key? key,
    required this.text,
    this.maxLength = 10000,
    this.minLength = 250,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 150),
      decoration: BoxDecoration(
        color: Colors.grey[1000],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: greyBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: TextField(
                inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
                minLines: 4,
                maxLines: null,
                style: const TextStyle(fontSize: 12, color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  hintText:
                      "Enter course content here... (minimum 250 characters)",
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                  border: InputBorder.none,
                ),
                onChanged: onChanged,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${text.length}/$maxLength",
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                ),
                Text(
                  "Min: $minLength chars ${text.length >= minLength ? '✓' : ''}",
                  style: TextStyle(
                    fontSize: 9,
                    color:
                        text.length >= minLength ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
