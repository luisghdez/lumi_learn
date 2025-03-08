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

      // If all questions have been answered, show the result screen.
      if (currentIndex >= questions.length) {
        return LessonResultScreen();
      }
      final currentQuestion = questions[currentIndex];

      // Generate a random image from activePlanet.backgroundPaths.
      final random = Random();
      final backgroundImage = activePlanet?.backgroundPaths[
          random.nextInt(activePlanet.backgroundPaths.length)];

      // TODO: add header for progress bar in each step
      switch (currentQuestion.lessonType) {
        case LessonType.multipleChoice:
          return MultipleChoiceScreen(
            question: currentQuestion,
            backgroundImage: backgroundImage ?? '', // Ensure non-null value
            onSubmitAnswer: () {
              courseController.nextQuestion();
            },
          );
        case LessonType.speak:
          return SpeakScreen(
            question: currentQuestion,
            backgroundImage: backgroundImage ?? '', // Pass the random image
            onSubmitAnswer: () {
              courseController.nextQuestion();
            },
          );
        case LessonType.fillInTheBlank:
          return FillInBlankScreen(
            question: currentQuestion,
            onSubmitAnswer: () {
              courseController.nextQuestion();
            },
          );
        case LessonType.typeInEverything:
          return TypeInScreen(
            question: currentQuestion,
            onSubmitAnswer: () {
              courseController.nextQuestion();
            },
          );
        case LessonType.matchTheTerms:
          return MatchTerms(
            question: currentQuestion,
            // onSubmitAnswer: () {
            //   courseController.nextQuestion();
            // },
          );
        case LessonType.flashcards:
          return FlashcardScreen(
            question: currentQuestion,
            backgroundImage: backgroundImage ?? '', // Pass the random image
          );
        // Add more cases for other lesson types if needed
        default:
          // A fallback widget or container for unhandled lesson types
          return const Center(child: Text('Unknown lesson type.'));
      }
    });
  }
}
