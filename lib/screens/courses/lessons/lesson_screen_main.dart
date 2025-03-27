import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/models/question.dart';
import 'package:lumi_learn_app/screens/courses/lessons/fill_in_blank_screen.dart';
import 'package:lumi_learn_app/screens/courses/lessons/match_terms_screen.dart';
import 'package:lumi_learn_app/screens/courses/lessons/multiple_choice_screen.dart';
import 'package:lumi_learn_app/screens/courses/lessons/speak_screen.dart';
import 'package:lumi_learn_app/screens/courses/lessons/type_in_screen.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/lesson_progress_bar.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';

class LessonScreenMain extends StatelessWidget {
  LessonScreenMain({Key? key}) : super(key: key);

  final CourseController courseController = Get.find<CourseController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentIndex = courseController.activeQuestionIndex.value;
      final questions = courseController.computedQuestions;
      final activePlanet = courseController.activePlanet.value;

      if (questions.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final currentQuestion = questions[currentIndex];
      final progress = (currentIndex) / questions.length;

      // Generate a random image from activePlanet.backgroundPaths.
      final random = Random();
      final backgroundImage = activePlanet?.backgroundPaths[
          random.nextInt(activePlanet.backgroundPaths.length)];

      // Determine which widget to show based on the lesson type.
      Widget questionWidget;
      switch (currentQuestion.lessonType) {
        case LessonType.multipleChoice:
          questionWidget = MultipleChoiceScreen(
            question: currentQuestion,
            backgroundImage: backgroundImage ?? '', // Ensure non-null value
          );
          break;
        case LessonType.fillInTheBlank:
          questionWidget = FillInBlankScreen(
            question: currentQuestion,
          );
          break;
        case LessonType.speakAll:
          questionWidget = SpeakScreen(
            question: currentQuestion,
          );
          break;
        case LessonType.writeAll:
          questionWidget = TypeInScreen(
            question: currentQuestion,
            onSubmitAnswer: () {
              courseController.nextQuestion();
            },
          );
          break;
        case LessonType.matchTheTerms:
          questionWidget = MatchTerms(
            question: currentQuestion,
            // You can add onSubmitAnswer if needed.
          );
          break;
        default:
          questionWidget = const Center(child: Text('Unknown lesson type.'));
      }

      // Wrap the questionWidget in a Container with a key based on the currentIndex.
      // This ensures the AnimatedSwitcher detects a change when the question updates.
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 12, 12, 12),
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Container(
                  key: ValueKey<int>(currentIndex),
                  child: questionWidget,
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Stack(
                    children: [
                      // Outer border

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.99, end: 1.0)
                                  .animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: courseController.showGreenGlow.value
                            ? Stack(
                                key: const ValueKey('greenGlow'),
                                children: [
                                  // Border
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.greenAccent,
                                        width: 4,
                                      ),
                                      borderRadius: BorderRadius.circular(60),
                                    ),
                                  ),

                                  // Glow
                                  Container(
                                    margin: const EdgeInsets.all(
                                        6), // Same as border width
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(60),
                                      color: Colors.transparent,
                                      boxShadow: [
                                        BoxShadow(
                                          blurStyle: BlurStyle.outer,
                                          color: Colors.greenAccent
                                              .withOpacity(0.25),
                                          blurRadius: 100,
                                          spreadRadius: -5,
                                          offset: Offset(0, 0),
                                        ),
                                        BoxShadow(
                                          blurStyle: BlurStyle.outer,
                                          color: Colors.greenAccent
                                              .withOpacity(0.12),
                                          blurRadius: 200,
                                          spreadRadius: -10,
                                          offset: Offset(0, 0),
                                        ),
                                        BoxShadow(
                                          blurStyle: BlurStyle.outer,
                                          color: Colors.greenAccent
                                              .withOpacity(0.05),
                                          blurRadius: 400,
                                          spreadRadius: -20,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(
                                key: ValueKey(
                                    'noGlow')), // Empty widget placeholder
                      ),
                    ],
                  ),
                ),
              ),

              // Progress bar overlay at the top.
              Positioned(
                top: MediaQuery.of(context).padding.top,
                left: 16,
                right: 16,
                child: LessonProgressBar(
                  progress: progress,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
