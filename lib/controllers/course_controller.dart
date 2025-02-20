import 'package:get/get.dart';
import 'package:lumi_learn_app/data/assets_data.dart';
import 'package:lumi_learn_app/models/question.dart'; // Import the data file

class CourseController extends GetxController {
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
        questionText: 'Type in everything you learned in one min!',
        options: [],
        lessonType: LessonType.typeInEverything,
      ),
      // match the terms
      Question(
        questionText: 'Match the terms',
        options: [],
        lessonType: LessonType.matchTheTerms,
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
}
