import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/data/assets_data.dart';
import 'package:lumi_learn_app/models/question.dart';
import 'package:lumi_learn_app/screens/courses/lessons/lesson_result_screen.dart';
import 'package:lumi_learn_app/services/api_service.dart';

class CourseController extends GetxController {
  final AuthController authController = Get.find();
  RxBool isInitialized = false.obs;

  // Reactive variable to store the active planet
  var activePlanet = Rxn<Planet>();
  final activeLessonIndex = 0.obs; // example lesson index
  final activeQuestionIndex = 0.obs;
  var isLoading = false.obs;
  var courses = [].obs;
  var featuredCourses = [].obs;
  var selectedCourseId = ''.obs;
  var selectedCourseTitle = ''.obs;
  final questionsCount = 0.obs;
  var lessons = <Map<String, dynamic>>[].obs;
  var flashcards = <Map<String, dynamic>>[].obs;
  final RxList<Question> computedQuestions = <Question>[].obs;
  RxBool showGreenGlow = false.obs;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int totalXP = 15; // 50 default

  // Add a reactive search string.
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch courses when the controller is initialized
    fetchCourses();
    fetchFeaturedCourses();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Method to set the active planet
  void setActivePlanet(Planet planet) {
    activePlanet.value = planet;
  }

  void setActiveLessonIndex(int lessonIndex) {
    activeLessonIndex.value = lessonIndex;
    activeQuestionIndex.value = 0;
  }

  void loadQuestions() {
    computedQuestions.value = getQuestions();
    questionsCount.value = computedQuestions.length;
  }

  void addPlaceholderCourse(Map<String, dynamic> course) {
    courses.add(course);
  }

  // Update a placeholder course once the backend call finishes
  void updatePlaceholderCourse(
      String tempId, Map<String, dynamic> updatedData) {
    int index = courses.indexWhere((course) => course['id'] == tempId);
    if (index != -1) {
      courses[index] = {...courses[index], ...updatedData};
    }
  }

  void removePlaceholderCourse(String tempId) {
    courses.removeWhere((course) => course['id'] == tempId);
  }

  void nextQuestion() {
    if (activeQuestionIndex.value < computedQuestions.length - 1) {
      activeQuestionIndex.value++;
    } else {
      // Last question reached
      completeCurrentLesson();

      // Navigate to LessonResultScreen from controller
      Future.delayed(const Duration(milliseconds: 300), () {
        playLessonCompleteSound();
        Get.offAll(() => LessonResultScreen(
              backgroundImage: activePlanet.value!.backgroundPaths.first,
              xp: totalXP, // Pass the accumulated XP here
            ));
      });
    }
  }

  // test questions
  // List<Question> getQuestions() {
  //   // return questions based on activeCourseId and activeLessonIndex
  //   return [
  //     Question(
  //       questionText: 'Explain what you just learned in your own words.',
  //       options: ["Black Holes", "Event Horizon", "Gravitational Waves"],
  //       lessonType: LessonType.speakAll,
  //     ),
  //     // Question(
  //     //   questionText:
  //     //       'Q1 What is the answer to this question if this was a long question of the question and a question?',
  //     //   options: ['Paris', 'London', 'Berlin', 'Madrid'],
  //     //   correctAnswer: 'Paris',
  //     //   lessonType: LessonType.multipleChoice,
  //     // ),
  //     // Question(
  //     //   questionText:
  //     //       'Q2 What is the 3333 to this question if this was a long question of the question and a question?',
  //     //   options: ['Paris', 'London', 'Berlin', 'Madrid'],
  //     //   correctAnswer: 'Paris',
  //     //   lessonType: LessonType.multipleChoice,
  //     // ),
  //     // Question(
  //     //   questionText:
  //     //       'The capital of _____ is Rome and tmore questions an ksdfkasdfkad dfhasd fhsa d dfh  .',
  //     //   options: [
  //     //     'Italy',
  //     //     'Paris',
  //     //     'Berlin',
  //     //     'Madrid',
  //     //     'London',
  //     //     'Tokyo',
  //     //     'New York City'
  //     //   ],
  //     //   correctAnswer: 'Italy',
  //     //   lessonType: LessonType.fillInTheBlank,
  //     // ),
  //     // // Type in everything you learned
  //     // Question(
  //     //   questionText:
  //     //       'Type in everything you learned up to this point in one minute!',
  //     //   options: [],
  //     //   lessonType: LessonType.writeAll,
  //     // ),
  //     // Question(
  //     //   questionText: 'Match the Terms',
  //     //   options: [],
  //     //   flashcards: [
  //     //     Flashcard(
  //     //         term: 'Term 1',
  //     //         definition: 'Definition of term 1 which shuld be long like this'),
  //     //     Flashcard(
  //     //         term: 'Term 2',
  //     //         definition: 'Definition of term 2 which shuld be long like this'),
  //     //     Flashcard(
  //     //         term: 'Term 3',
  //     //         definition: 'Definition of term 3 which shuld be long like this'),
  //     //     Flashcard(
  //     //         term: 'Term 4',
  //     //         definition: 'Definition of term 4 which shuld be long like this'),
  //     //   ],
  //     //   lessonType: LessonType.matchTheTerms,
  //     // ),
  //     // Question(
  //     //   questionText: 'Flashcards',
  //     //   options: [],
  //     //   flashcards: [
  //     //     Flashcard(term: 'Term 1', definition: 'Definition of term 1'),
  //     //     Flashcard(term: 'Term 2', definition: 'Definition of term 2'),
  //     //     Flashcard(term: 'Term 3', definition: 'Definition of term 3'),
  //     //     Flashcard(term: 'Term 4', definition: 'Definition of term 4'),
  //     //   ],
  //     //   lessonType: LessonType.flashcards,
  //     // ),
  //   ];
  // }

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

    // ----------------------------------------
    // Additional logic for flashcards / matchTheTerms
    // ----------------------------------------

    // Case 1: Exactly one question that is flashcards.
    if (questions.length == 1 &&
        questions[0].lessonType == LessonType.flashcards) {
      final flashcards = questions[0].flashcards;
      if (flashcards != null && flashcards.isNotEmpty) {
        const int chunkSize = 4;
        final List<Question> matchQuestions = [];
        for (int i = 0; i < flashcards.length; i += chunkSize) {
          final chunk =
              flashcards.sublist(i, min(i + chunkSize, flashcards.length));
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
    // Case 2: More than one question.
    else if (questions.length > 1) {
      // Look for a flashcards question in the list.
      final int flashcardsIndex =
          questions.indexWhere((q) => q.lessonType == LessonType.flashcards);
      if (flashcardsIndex != -1) {
        final flashcards = questions[flashcardsIndex].flashcards;
        if (flashcards != null && flashcards.isNotEmpty) {
          const int chunkSize = 4;
          final List<Question> matchQuestions = [];
          for (int i = 0; i < flashcards.length; i += chunkSize) {
            final chunk =
                flashcards.sublist(i, min(i + chunkSize, flashcards.length));
            matchQuestions.add(Question(
              questionText: "Match the Terms", // Customize as needed
              options: [],
              lessonType: LessonType.matchTheTerms,
              flashcards: chunk,
            ));
          }
          // Replace the original flashcards question with the new matchTheTerms ones.
          questions.removeAt(flashcardsIndex);
          questions.addAll(matchQuestions);
        }
      }
      questions.shuffle();
    }

    // After processing and shuffling the standard questions,
    // check if there is a speak or write question in the lesson.
    // If so, create a corresponding Question and add it at the end.
    final speakQuestionJson = lesson['speakQuestion'];
    final writeQuestionJson = lesson['writeQuestion'];
    if (speakQuestionJson != null && speakQuestionJson is Map) {
      questions.add(Question(
        questionText: speakQuestionJson['prompt'] ??
            "Explain everything you remember about this lesson.",
        options: (speakQuestionJson['options'] as List<dynamic>?)
                ?.map((opt) => opt.toString())
                .take(3)
                .toList() ??
            [],
        lessonType: LessonType.speakAll,
      ));
    } else if (writeQuestionJson != null && writeQuestionJson is Map) {
      questions.add(Question(
        questionText: writeQuestionJson['prompt'] ??
            "Write everything you remember about this lesson.",
        options: (writeQuestionJson['options'] as List<dynamic>?)
                ?.map((opt) => opt.toString())
                .toList() ??
            [],
        lessonType: LessonType.writeAll,
      ));
    }

    questionsCount.value = questions.length;
    return questions;
  }

  LessonType parseLessonType(String? lessonTypeString) {
    switch (lessonTypeString) {
      case 'multipleChoice':
        return LessonType.multipleChoice;
      case 'fillInTheBlank':
        return LessonType.fillInTheBlank;
      case 'speakAll':
        return LessonType.speakAll;
      case 'writeAll':
        return LessonType.writeAll;
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

  Future<String> createCourse({
    required String title,
    required String description,
    required List<File> files,
    String content = '',
  }) async {
    isLoading.value = true; // Start loading

    try {
      final token = await authController.getIdToken();
      if (token == null) {
        isLoading.value = false;
        Get.back(); // Close loading overlay
        throw Exception("No user token found.");
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
        // Parse the response JSON and extract the courseId
        final responseData = jsonDecode(response.body);
        final courseId = responseData['courseId'] as String;

        // Create the new course object and update the courses list.
        final newCourse = {
          'id': courseId,
          'title': title,
          'description': description,
          'createdBy': authController.firebaseUser.value?.uid ?? 'unknown',
          'loading': false,
        };

        // Insert the new course at the top of the courses list.
        courses.insert(0, newCourse);
        // await fetchCourses();

        Get.snackbar(
          "Success",
          "Course created successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return courseId;
      } else {
        Get.snackbar(
          "Error",
          "Failed to create course.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        throw Exception('Failed to create course: ${response.body}');
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      throw Exception(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveCourse(String courseId, String courseTitle) async {
    try {
      // Get the user's authentication token.
      final String? token = await authController.getIdToken();
      if (token == null) {
        print("No user token found. Cannot save course.");
        return;
      }

      // Call the API service to create a saved course.
      final apiService = ApiService();
      final response = await apiService.createSavedCourse(
        token: token,
        courseId: courseId,
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final savedCourseId = responseData['savedCourseId'];
        print("Course saved successfully with id: $savedCourseId");
        // Optionally, update your state or notify the user.

        final newCourse = {
          'id': courseId,
          'title': courseTitle,
        };
        courses.insert(0, newCourse);
      } else {
        print("Failed to save course: ${response.statusCode} ${response.body}");
        // Optionally, handle the error (e.g., show a snackbar).
      }
    } catch (e) {
      print("Error saving course: $e");
      // Optionally, handle the error further (e.g., show a snackbar).
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
      isInitialized.value = true;
    }
  }

  Future<void> fetchFeaturedCourses() async {
    print('Fetching featured courses...');
    isLoading.value = true; // Start loading
    try {
      final token = await authController.getIdToken();
      if (token == null) {
        print('No user token found.');
        isLoading.value = false;
        return;
      }

      final apiService = ApiService();
      final response = await apiService.getFeaturedCourses(token: token);

      if (response.statusCode == 200) {
        // Parse the JSON response and store the courses in our RxList
        final data = jsonDecode(response.body);
        featuredCourses.value = data['courses'];
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
      isInitialized.value = true;
    }
  }

  Future<void> setSelectedCourseId(String courseId, String courseTitle) async {
    lessons.value = []; // Clear the lessons list
    selectedCourseId.value = courseId;
    selectedCourseTitle.value = courseTitle;
    isLoading.value = true; // Start loading

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

      final index = courses.indexWhere((course) => course['id'] == courseId);
      if (index != -1) {
        final clickedCourse = courses[index];
        courses.removeAt(index);
        courses.insert(0, clickedCourse);
      }

      lessons.value = []; // Clear the lessons list
      selectedCourseId.value = courseId;
      selectedCourseTitle.value = courseTitle;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        lessons.value = List<Map<String, dynamic>>.from(data['lessons']);
        flashcards.value =
            List<Map<String, dynamic>>.from(data['mergedFlashcards']);
      } else {
        print(
            'Error fetching lessons: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception while fetching lessons: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeCurrentLesson() async {
    try {
      final lessonId = lessons[activeLessonIndex.value]['id'];
      isLoading.value = true; // Start loading
      final token = await authController.getIdToken();
      if (token == null) {
        print('No user token found.');
        isLoading.value = false;
        return;
      }

      final apiService = ApiService();
      final response = await apiService.completeLesson(
        token: token,
        courseId: selectedCourseId.value,
        lessonId: lessonId,
        xp: totalXP,
      );

      if (response.statusCode == 200) {
        // Parse JSON
        final responseData = jsonDecode(response.body);
        print('Lesson completed successfully: $responseData');

        authController.xpCount.value += totalXP;

        // Mark this lesson as completed in local state
        lessons[activeLessonIndex.value]['completed'] = true;

        // Extract streak info (if present)
        final streakInfo = responseData['streakInfo'];
        if (streakInfo != null) {
          final newStreak = streakInfo['newStreak'];
          final previousStreak = streakInfo['previousStreak'];
          final streakExtended = streakInfo['streakExtended'];

          authController.streakCount.value = newStreak;

          // If the streak was incremented
          if (streakExtended == true) {
            // You can show a toast/snackbar, or store it in a variable to display on the next screen
            print(
                'Your streak has increased from $previousStreak to $newStreak!');

            // For instance, show a snackbar
            Get.snackbar(
              "🔥 Streak Extended!",
              "Your streak is now $newStreak days long!",
              backgroundColor: const Color.fromARGB(255, 72, 44, 0),
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
          }
        }
      } else {
        print('Failed to complete lesson: ${response.statusCode}');
        Get.snackbar(
          "Error",
          "Failed to complete lesson.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error completing lesson: $e');
      Get.snackbar(
        "Error",
        "Something went wrong. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false; // Stop loading
    }
  }

  void submitAnswerForQuestion({
    required Question question,
    required String selectedAnswer,
    required BuildContext context,
  }) {
    if (selectedAnswer == question.correctAnswer) {
      // Trigger the green glow:
      showGreenGlow.value = true;
      playCorrectAnswerSound();
      totalXP += 6;

      // Wait 300 milliseconds before moving on (adjust duration as needed)
      Future.delayed(const Duration(milliseconds: 500), () {
        showGreenGlow.value = false;
        nextQuestion();
      });
    } else {
      // Incorrect answer: show dialog and move the question to the end.
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
                      'Incorrect',
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
                const Text(
                  "Correct Answer:",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  question.correctAnswer ?? 'No correct answer provided',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  // widthFactor: double.infinity,
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

                        int index = computedQuestions.indexOf(question);
                        if (index != -1) {
                          final endSectionIndex =
                              computedQuestions.lastIndexWhere(
                            (q) =>
                                q.lessonType == LessonType.speakAll ||
                                q.lessonType == LessonType.writeAll,
                          );

                          if (endSectionIndex != -1) {
                            computedQuestions.insert(endSectionIndex, question);
                          } else {
                            computedQuestions.add(question);
                          }
                        }

                        nextQuestion();
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

  Future<void> playCorrectAnswerSound() async {
    await _audioPlayer.play(AssetSource('sounds/correct.wav'));
  }

  void playSmallCorrectSound() async {
    await _audioPlayer.play(AssetSource('sounds/small_correct.wav'));
  }

  void playLessonCompleteSound() async {
    await _audioPlayer.play(AssetSource('sounds/lesson_complete.wav'));
  }

  Future<void> fadeInWriteLessonSound(
      {Duration fadeDuration = const Duration(seconds: 2)}) async {
    // Start the sound with volume 0
    await _audioPlayer.setVolume(0.0);
    // Play the writing lesson music (ensure looping if desired)
    await _audioPlayer.play(AssetSource('sounds/writing_lesson_music.mp3'));

    // Gradually increase the volume to 1.0
    const int steps = 20;
    double stepVolume = 1.0 / steps;
    Duration stepDuration =
        Duration(milliseconds: fadeDuration.inMilliseconds ~/ steps);

    for (int i = 0; i < steps; i++) {
      await Future.delayed(stepDuration);
      double newVolume = stepVolume * (i + 1);
      await _audioPlayer.setVolume(newVolume);
    }
    await _audioPlayer.setVolume(1.0);
  }

  Future<void> fadeOutWriteLessonSound(
      {Duration fadeDuration = const Duration(seconds: 2)}) async {
    // Gradually decrease the volume from the current value (assumed 1.0) to 0
    const int steps = 20;
    double stepVolume = 1.0 / steps;
    Duration stepDuration =
        Duration(milliseconds: fadeDuration.inMilliseconds ~/ steps);

    for (int i = 0; i < steps; i++) {
      await Future.delayed(stepDuration);
      double newVolume = 1.0 - stepVolume * (i + 1);
      if (newVolume < 0) newVolume = 0;
      await _audioPlayer.setVolume(newVolume);
    }
    // Stop the writing lesson sound
    await _audioPlayer.stop();
    // Reset the volume back to full for subsequent sounds
    await _audioPlayer.setVolume(1.0);
  }
}
