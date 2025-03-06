import 'dart:convert';
import 'dart:io';

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
  // final activeCourseId = 0.obs; // example course id
  // final activeLessonIndex = 0.obs; // example lesson index
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
        print('Lessons fetched successfully: ${data['lessons']}');
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
