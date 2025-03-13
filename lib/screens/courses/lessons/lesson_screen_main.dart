import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/models/question.dart';
import 'package:lumi_learn_app/screens/courses/lessons/fill_in_blank_screen.dart';
import 'package:lumi_learn_app/screens/courses/lessons/flash_card_screen.dart';
import 'package:lumi_learn_app/screens/courses/lessons/match_terms_screen.dart';
import 'package:lumi_learn_app/screens/courses/lessons/multiple_choice_screen.dart';
import 'package:lumi_learn_app/screens/courses/lessons/speak_screen.dart';
import 'package:lumi_learn_app/screens/courses/lessons/type_in_screen.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/lesson_progress_bar.dart';
import 'lesson_result_screen.dart';
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
            backgroundImage: backgroundImage ?? '',
            onSubmitAnswer: () {
              courseController.nextQuestion();
            },
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
        case LessonType.flashcards:
          questionWidget = FlashcardScreen(
            question: currentQuestion,
            backgroundImage: backgroundImage ?? '',
          );
          break;
        default:
          questionWidget = const Center(child: Text('Unknown lesson type.'));
      }

      // Wrap the questionWidget in a Container with a key based on the currentIndex.
      // This ensures the AnimatedSwitcher detects a change when the question updates.
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 12, 12, 12),
        body: Stack(
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

            // Progress bar overlay at the top
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 16,
              right: 16,
              child: LessonProgressBar(
                progress: progress,
                onClose: () => Get.back(),
              ),
            ),
          ],
        ),
      );
    });
  }
}
