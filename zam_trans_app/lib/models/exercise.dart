enum ExerciseType {
  translation,
  multipleChoice,
  fillInTheBlank,
  listening,
  speaking,
}

class Exercise {
  final String id;
  final ExerciseType type;
  final String question;
  final String correctAnswer;
  final List<String> options;
  final String sourceLanguage;
  final String targetLanguage;
  final int difficulty; // 1-5
  final String category;

  Exercise({
    required this.id,
    required this.type,
    required this.question,
    required this.correctAnswer,
    this.options = const [],
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.difficulty,
    required this.category,
  });
}

class LearningSession {
  final String id;
  final DateTime startTime;
  final List<Exercise> exercises;
  final Map<String, bool> answers;
  final int score;
  final bool isCompleted;

  LearningSession({
    required this.id,
    required this.startTime,
    required this.exercises,
    this.answers = const {},
    this.score = 0,
    this.isCompleted = false,
  });
}
