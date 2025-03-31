import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/models/question.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/countdown_timer.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
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
  bool _isCountdownCompleted = false;

  @override
  void initState() {
    super.initState();
    // Play the writing lesson sound with a fade-in effect when the screen is active.
    final courseController = Get.find<CourseController>();
    courseController.fadeInWriteLessonSound();
  }

  void _onCountdownComplete() {
    // Fade out and stop the sound immediately when countdown finishes.
    final courseController = Get.find<CourseController>();
    courseController.fadeOutWriteLessonSound();

    setState(() {
      _isCountdownCompleted = true;
    });

    // Check if the user's input is sufficiently detailed.
    bool isGood = _textController.text.length > 50;

    if (isGood) {
      // Green dialog for a good answer.
      Get.dialog(
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 26, 26, 26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green.shade700, size: 30),
                    const SizedBox(width: 8),
                    const Text(
                      'Good job!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {
                        Get.back(); // Close the dialog
                        widget.onSubmitAnswer();
                      },
                      child: const Text('CONTINUE'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } else {
      // Red dialog for an insufficient answer.
      Get.dialog(
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 26, 26, 26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red.shade900, size: 30),
                    const SizedBox(width: 8),
                    const Text(
                      'Oof! You can do better!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red.shade900,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {
                        Get.back(); // Close the dialog
                        widget.onSubmitAnswer();
                      },
                      child: const Text('GOT IT!'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: [
          // Fixed-size header container.
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CountdownTimer(
                  onComplete: _onCountdownComplete,
                ),
                // Question text.
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Astronaut Image.
                SizedBox(
                  child: Image.asset(
                    'assets/astronaut/writing.png',
                    width: 100,
                    height: 140,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TextField(
              readOnly: _isCountdownCompleted, // Lock input after countdown.
              textAlignVertical: TextAlignVertical.top,
              controller: _textController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              expands: true,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: "Start typing...",
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: greyBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: greyBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: greyBorder),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
            ),
          ),
          // The NextButton is removed; the only way to continue is via the dialog.
        ],
      ),
    );
  }
}
