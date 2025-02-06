enum LessonType {
  multipleChoice,
  speak,
  fillInTheBlank,
  typeInEverything,
  matchTheTerms,
  // add other lesson types here
}

class Question {
  final String questionText;
  final List<String> options; // relevant for multiple choice
  final LessonType lessonType;
  // Add anything else you need (e.g. correctAnswer, audioUrl, etc.)

  Question({
    required this.questionText,
    required this.options,
    required this.lessonType,
  });
}
