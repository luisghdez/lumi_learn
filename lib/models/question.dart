enum LessonType {
  multipleChoice,
  speak,
  fillInTheBlank,
  typeInEverything,
  matchTheTerms,
  flashcards,
  // add other lesson types here
}

class Flashcard {
  final String term;
  final String definition;

  Flashcard({required this.term, required this.definition});
}

class Question {
  final String questionText;
  final List<String> options; // relevant for multiple choice
  final LessonType lessonType;
  final List<Flashcard> flashcards;
  final String? correctAnswer; // relevant for multiple choice
  // Add anything else you need (e.g. correctAnswer, audioUrl, etc.)

  Question({
    required this.questionText,
    required this.options,
    required this.lessonType,
    this.flashcards = const [],
    this.correctAnswer,
  });
}
