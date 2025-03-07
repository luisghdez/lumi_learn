import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/data/assets_data.dart';
import 'package:lumi_learn_app/models/question.dart';
import 'package:lumi_learn_app/screens/main/main_screen.dart';
import 'package:lumi_learn_app/services/api_service.dart'; // Import the data file

class CourseController extends GetxController {
  final AuthController authController = Get.find();
  // Reactive variable to store the active planet
  var activePlanet = Rxn<Planet>();
  final activeLessonIndex = 0.obs; // example lesson index
  final activeQuestionIndex = 0.obs;
  var isLoading = false.obs;
  var courses = [].obs;
  var selectedCourseId = ''.obs;
  var selectedCourseTitle = ''.obs;

  var lessons = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch courses when the controller is initialized
    fetchCourses();
  }

  // Method to set the active planet
  void setActivePlanet(Planet planet) {
    activePlanet.value = planet;
  }

  // void setActiveLesson(int lessonIndex) {
  //   // activeLessonIndex = lessonIndex;
  // }
  void setActiveLessonIndex(int lessonIndex) {
    activeLessonIndex.value = lessonIndex;
    activeQuestionIndex.value = 0;
  }

  void nextQuestion() {
    print('Next question');
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

  // List<Question> getQuestions() {
  //   // return questions based on activeCourseId and activeLessonIndex
  //   // TODO replace with real service call to these questions
  //   return [
  //     Question(
  //       questionText:
  //           'What is the answer to this question if this was a long question of the question and a question?',
  //       options: ['Paris', 'London', 'Berlin', 'Madrid'],
  //       lessonType: LessonType.multipleChoice,
  //     ),
  //     Question(
  //       questionText: 'Explain what you just learned in your own words.',
  //       options: [],
  //       lessonType: LessonType.speak,
  //     ),
  //     Question(
  //       questionText:
  //           'The capital of _____ is Rome and tmore questions an ksdfkasdfkad dfhasd fhsa d dfh  .',
  //       options: [
  //         'Rome',
  //         'Paris',
  //         'Berlin',
  //         'Madrid',
  //         'London',
  //         'Tokyo',
  //         'New York City'
  //       ],
  //       lessonType: LessonType.fillInTheBlank,
  //     ),
  //     // Type in everything you learned
  //     Question(
  //       questionText:
  //           'Type in everything you learned up to this point in one minute!',
  //       options: [],
  //       lessonType: LessonType.typeInEverything,
  //     ),
  //     Question(
  //       questionText: 'Match the Terms',
  //       options: [],
  //       flashcards: [
  //         Flashcard(
  //             term: 'Term 1',
  //             definition: 'Definition of term 1 which shuld be long like this'),
  //         Flashcard(
  //             term: 'Term 2',
  //             definition: 'Definition of term 2 which shuld be long like this'),
  //         Flashcard(
  //             term: 'Term 3',
  //             definition: 'Definition of term 3 which shuld be long like this'),
  //         Flashcard(
  //             term: 'Term 4',
  //             definition: 'Definition of term 4 which shuld be long like this'),
  //       ],
  //       lessonType: LessonType.matchTheTerms,
  //     ),
  //     Question(
  //       questionText: 'Flashcards',
  //       options: [],
  //       flashcards: [
  //         Flashcard(term: 'Term 1', definition: 'Definition of term 1'),
  //         Flashcard(term: 'Term 2', definition: 'Definition of term 2'),
  //         Flashcard(term: 'Term 3', definition: 'Definition of term 3'),
  //         Flashcard(term: 'Term 4', definition: 'Definition of term 4'),
  //       ],
  //       lessonType: LessonType.flashcards,
  //     ),
  //   ];
  // }

  // Modify getQuestions() to return questions only from the active lesson

  List<Question> getQuestions() {
    // Check if lessons have been loaded
    if (lessons.isEmpty) return [];

    // Get the currently active lesson using activeLessonIndex
    final lesson = lessons[activeLessonIndex.value];
    final List<Question> questions = [];

    // 1) Parse flashcards (if available) as one question type.
    final flashcardsJson = lesson['flashcards'];
    if (flashcardsJson != null && flashcardsJson is List) {
      final flashcards = flashcardsJson.map<Flashcard>((f) {
        return Flashcard(
          term: f['term'] ?? '',
          definition: f['definition'] ?? '',
        );
      }).toList();

      // Using lesson title as a label (or change as needed)
      questions.add(Question(
        questionText: lesson['title'] ?? 'Flashcards',
        options: [],
        lessonType: LessonType.flashcards,
        flashcards: flashcards,
      ));
    }

    // 2) Parse multiple choice questions.
    final multipleChoiceJson = lesson['multipleChoice'];
    if (multipleChoiceJson != null && multipleChoiceJson is List) {
      for (final mcItem in multipleChoiceJson) {
        final options = (mcItem['options'] as List<dynamic>?)
                ?.map((opt) => opt.toString())
                .toList() ??
            [];
        questions.add(Question(
          questionText: mcItem['questionText'] ?? '',
          options: options,
          correctAnswer: mcItem['correctAnswer'],
          lessonType: LessonType.multipleChoice,
        ));
      }
    }

    // 3) Parse fill in the blank questions.
    final fillInTheBlankJson = lesson['fillInTheBlank'];
    if (fillInTheBlankJson != null && fillInTheBlankJson is List) {
      for (final fibItem in fillInTheBlankJson) {
        final options = (fibItem['options'] as List<dynamic>?)
                ?.map((opt) => opt.toString())
                .toList() ??
            [];
        questions.add(Question(
          questionText: fibItem['questionText'] ?? '',
          options: options,
          correctAnswer: fibItem['correctAnswer'],
          lessonType: LessonType.fillInTheBlank,
        ));
      }
    }
    // Additional logic: if the lesson only has one question and it is type flashcards,
    // add matchTheTerms questions using those same flashcards 4 at a time.
    if (questions.length == 1 &&
        questions[0].lessonType == LessonType.flashcards) {
      final flashcards = questions[0].flashcards;
      if (flashcards != null && flashcards.isNotEmpty) {
        const int chunkSize = 4;
        final List<Question> matchQuestions = [];
        for (int i = 0; i < flashcards.length; i += chunkSize) {
          // Create a chunk of flashcards (4 at a time)
          final chunk = flashcards.sublist(
            i,
            min(i + chunkSize, flashcards.length),
          );
          matchQuestions.add(Question(
            questionText: "Match the Terms", // Customize as needed
            options: [],
            lessonType: LessonType.matchTheTerms,
            flashcards: chunk,
          ));
        }
        // Append the new matchTheTerms questions to the list.
        questions.addAll(matchQuestions);
      }
    }

    print("question count: ${questions.length}");

    return questions;
  }

  LessonType parseLessonType(String? lessonTypeString) {
    switch (lessonTypeString) {
      case 'multipleChoice':
        return LessonType.multipleChoice;
      case 'fillInTheBlank':
        return LessonType.fillInTheBlank;
      case 'speak':
        return LessonType.speak;
      case 'typeInEverything':
        return LessonType.typeInEverything;
      case 'matchTheTerms':
        return LessonType.matchTheTerms;
      case 'flashcards':
        return LessonType.flashcards;
      default:
        print('Unknown lesson type: $lessonTypeString');
        // Handle unknown or unimplemented lesson types safely
        return LessonType.multipleChoice;
    }
  }

  Future<void> createCourse({
    required String title,
    required String description,
    required List<File> files,
    String content = '',
  }) async {
    isLoading.value = true; // Start loading

    // Show loading overlay
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      barrierDismissible: false,
    );

    try {
      final token = await authController.getIdToken();
      if (token == null) {
        print('No user token found.');
        isLoading.value = false;
        Get.back(); // Close loading overlay
        return;
      }

      final apiService = ApiService();
      final response = await apiService.createCourse(
        token: token,
        title: title,
        description: description,
        files: files,
        content: content,
      );

      if (response.statusCode == 201) {
        print('Course created successfully: ${response.body}');

        // Parse the response JSON and extract the courseId
        final responseData = jsonDecode(response.body);
        final courseId = responseData['courseId'];

        // Recreate the course object with the title, description, id, and createdBy
        final newCourse = {
          'id': courseId,
          'title': title,
          'description': description,
          'createdBy': authController.firebaseUser.value?.uid ?? 'unknown',
        };

        // Insert the new course at the top of the courses list
        courses.insert(0, newCourse);

        Get.snackbar("Success", "Course created successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        print(
            'Failed to create course [${response.statusCode}]: ${response.body}');
        Get.snackbar("Error", "Failed to create course.",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('Error creating course: $e');
      Get.snackbar("Error", "Something went wrong. Please try again.",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false; // Stop loading
      // Navigate to MainScreen after course creation
      Get.offAll(() => const MainScreen());
    }
  }

  // New method to fetch courses from the backend
  Future<void> fetchCourses() async {
    print('Fetching courses...');
    isLoading.value = true; // Start loading
    try {
      final token = await authController.getIdToken();
      if (token == null) {
        print('No user token found.');
        isLoading.value = false;
        return;
      }

      final apiService = ApiService();
      final response = await apiService.getCourses(token: token);

      if (response.statusCode == 200) {
        // Parse the JSON response and store the courses in our RxList
        final data = jsonDecode(response.body);
        courses.value = data['courses'];
        print('Courses fetched successfully: ${courses.value}');
      } else {
        print('Failed to fetch courses: ${response.statusCode}');
        Get.snackbar("Error", "Failed to fetch courses.",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('Error fetching courses: $e');
      Get.snackbar("Error", "Something went wrong. Please try again.",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false; // Stop loading
    }
  }

  Future<void> setSelectedCourseId(String courseId, String courseTitle) async {
    lessons.value = []; // Clear the lessons list
    selectedCourseId.value = courseId;
    selectedCourseTitle.value = courseTitle;
    isLoading.value = true; // Start loading

    // // Show full-screen loading overlay
    // Get.dialog(
    //   const Center(
    //     child: CircularProgressIndicator(color: Colors.white),
    //   ),
    //   barrierDismissible: false, // Prevent dismissing while loading
    // );

    try {
      final token = await authController.getIdToken();
      if (token == null) {
        print('No user token found.');
        isLoading.value = false;
        Get.back(); // Remove loading screen
        return;
      }

      final apiService = ApiService();
      final response =
          await apiService.getLessons(token: token, courseId: courseId);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print('Lessons fetched successfully: ${data['lessons']}');
        lessons.value = List<Map<String, dynamic>>.from(data['lessons']);
      } else {
        print(
            'Error fetching lessons: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception while fetching lessons: $e');
    } finally {
      isLoading.value = false; // Stop loading
      // Get.back(); // Close loading screen
    }
  }
}
