import 'dart:io';

import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/data/assets_data.dart';
import 'package:lumi_learn_app/models/question.dart';
import 'package:lumi_learn_app/services/api_service.dart'; // Import the data file

class CourseController extends GetxController {
  final AuthController authController = Get.find();
  // Reactive variable to store the active planet
  var activePlanet = Rxn<Planet>();
  // final activeCourseId = 0.obs; // example course id
  // final activeLessonIndex = 0.obs; // example lesson index
  final activeQuestionIndex = 0.obs;

  // Method to set the active planet
  void setActivePlanet(int index) {
    activePlanet.value = planets[index];
  }

  void setActiveCourse(int courseId) {
    // activeCourseId.value = courseId;
  }

  void setActiveLesson(int lessonIndex) {
    // activeLessonIndex = lessonIndex;
  }

  List<Question> getQuestions() {
    // return questions based on activeCourseId and activeLessonIndex
    // TODO replace with real service call to these questions
    return [
      Question(
        questionText:
            'What is the answer to this question if this was a long question of the question and a question?',
        options: ['Paris', 'London', 'Berlin', 'Madrid'],
        lessonType: LessonType.multipleChoice,
      ),
      Question(
        questionText: 'Explain what you just learned in your own words.',
        options: [],
        lessonType: LessonType.speak,
      ),
      Question(
        questionText:
            'The capital of _____ is Rome and tmore questions an ksdfkasdfkad dfhasd fhsa d dfh  .',
        options: [
          'Rome',
          'Paris',
          'Berlin',
          'Madrid',
          'London',
          'Tokyo',
          'New York City'
        ],
        lessonType: LessonType.fillInTheBlank,
      ),
      // Type in everything you learned
      Question(
        questionText:
            'Type in everything you learned up to this point in one minute!',
        options: [],
        lessonType: LessonType.typeInEverything,
      ),
      Question(
        questionText: 'Match the Terms',
        options: [],
        flashcards: [
          Flashcard(
              term: 'Term 1',
              definition: 'Definition of term 1 which shuld be long like this'),
          Flashcard(
              term: 'Term 2',
              definition: 'Definition of term 2 which shuld be long like this'),
          Flashcard(
              term: 'Term 3',
              definition: 'Definition of term 3 which shuld be long like this'),
          Flashcard(
              term: 'Term 4',
              definition: 'Definition of term 4 which shuld be long like this'),
        ],
        lessonType: LessonType.matchTheTerms,
      ),
      Question(
        questionText: 'Flashcards',
        options: [],
        flashcards: [
          Flashcard(term: 'Term 1', definition: 'Definition of term 1'),
          Flashcard(term: 'Term 2', definition: 'Definition of term 2'),
          Flashcard(term: 'Term 3', definition: 'Definition of term 3'),
          Flashcard(term: 'Term 4', definition: 'Definition of term 4'),
        ],
        lessonType: LessonType.flashcards,
      ),
    ];
  }

  // Possibly move to seperate controller, to seperate concerns

  void nextQuestion() {
    if (activeQuestionIndex.value < getQuestions().length) {
      activeQuestionIndex.value++;
    }
  }

  // (Optional) Moves to the previous question if there is one
  // void previousQuestion() {
  //   if (activeQuestionIndex.value > 0) {
  //     activeQuestionIndex.value--;
  //   }
  // }

  Future<void> createCourse({
    required String title,
    required String description,
    required List<File> files,
    String content = '',
  }) async {
    print('Creating course...');
    print('Title: $title');
    print('Description: $description');
    print('Content: $content');
    print('Files: $files');

    try {
      final token = await authController.getIdToken();
      if (token == null) {
        print('No user token found.');
        return;
      }
      final response = await ApiService.createCourse(
        token: token,
        title: title,
        description: description,
        files: files,
        content: content,
      );

      if (response.statusCode == 201) {
        // Successfully created the course
        final responseData = response.body;
        // Optionally parse the JSON or do further handling
        print('Course created successfully: $responseData');
      } else {
        // Handle error response
        print(
          'Failed to create course [${response.statusCode}]: ${response.body}',
        );
      }
    } catch (e) {
      // Catch any exceptions (network issues, etc.)
      print('Error creating course: $e');
    }
  }
}
