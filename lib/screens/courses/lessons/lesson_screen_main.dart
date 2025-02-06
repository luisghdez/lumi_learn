import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/models/question.dart';
import 'package:lumi_learn_app/screens/courses/lessons/multiple_choice_screen.dart';
import 'lesson_result_screen.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';

class LessonScreenMain extends StatelessWidget {
  LessonScreenMain({Key? key}) : super(key: key);

  final CourseController courseController = Get.find<CourseController>();
  // final LessonController lessonController = Get.put(LessonController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentIndex = courseController.activeQuestionIndex.value;
      final questions = courseController.getQuestions();

      final currentQuestion = questions[currentIndex];
      switch (currentQuestion.lessonType) {
        case LessonType.multipleChoice:
          return MultipleChoiceScreen(
            question: currentQuestion,
            onSubmitAnswer: () {
              courseController.nextQuestion;
            },
          );

        // case LessonType.speak:
        //   return SpeakScreen(
        //     question: currentQuestion,
        //     onRecordingDone: () {
        //       // Move to the next question by incrementing the controller’s observable
        //       courseController.nextQuestion;
        //     },
        //   );

        // Add more cases for other lesson types if needed
        default:
          // A fallback widget or container for unhandled lesson types
          return const Center(child: Text('Unknown lesson type.'));
      }
    });
  }
}
