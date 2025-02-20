import 'package:flutter/material.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/models/question.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/countdown_timer.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/next_button.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/speach_bubble.dart';
import 'package:lumi_learn_app/widgets/app_scaffold.dart';

class TypeInScreen extends StatefulWidget {
  final Question question;
  final Function() onSubmitAnswer;

  const TypeInScreen({
    Key? key,
    required this.question,
    required this.onSubmitAnswer,
  }) : super(key: key);

  @override
  _TypeInScreenState createState() => _TypeInScreenState();
}

class _TypeInScreenState extends State<TypeInScreen> {
  final TextEditingController _textController = TextEditingController();

  void _submitAnswer(BuildContext context) {
    if (_textController.value.text.isNotEmpty) {
      print('submitted text');
      widget.onSubmitAnswer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an answer.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: [
          // Fixed-size header container
          SizedBox(
            height: 200, // Fixed height for consistency
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CountdownTimer(
                  onComplete: () {
                    print("Time's up!");
                  },
                ),

                // Quesstion text
                SizedBox(
                  width: 120,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'Type everything you remember up to this point\n ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: 'in ONE MINUTE!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold, // Makes this part bold
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Astronaut Image
                SizedBox(
                  child: Image.asset(
                    'assets/astronaut/floating.png', // Ensure correct path
                    width: 100,
                    height: 140,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: TextField(
              textAlignVertical: TextAlignVertical.top,
              controller: _textController,
              keyboardType: TextInputType.multiline,
              maxLines: null, // Allow for unlimited lines
              expands: true, // Ensures it fills available space
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: "Start typing...",
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor:
                    Colors.black.withOpacity(0.3), // Slight background tint
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: greyBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: greyBorder),
                ),
              ),
            ),
          ),
          NextButton(
            onPressed: () => _submitAnswer(context),
          ),
        ],
      ),
    );
  }
}
