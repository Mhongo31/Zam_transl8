import 'package:flutter/material.dart';
import '../models/exercise.dart';

class LearningProvider with ChangeNotifier {
  List<Exercise> _exercises = [];
  LearningSession? _currentSession;
  final Map<String, int> _progress = {};
  int _currentExerciseIndex = 0;

  List<Exercise> get exercises => _exercises;
  LearningSession? get currentSession => _currentSession;
  Map<String, int> get progress => _progress;
  int get currentExerciseIndex => _currentExerciseIndex;

  void initialize() {
    _generateMockExercises();
  }

  void _generateMockExercises() {
    _exercises = [
      Exercise(
        id: '1',
        type: ExerciseType.translation,
        question: 'Translate "hello" to Lunda',
        correctAnswer: 'Mwakwenu',
        sourceLanguage: 'en',
        targetLanguage: 'lun',
        difficulty: 1,
        category: 'Greetings',
      ),
      Exercise(
        id: '2',
        type: ExerciseType.multipleChoice,
        question: 'What does "meya" mean in English?',
        correctAnswer: 'water',
        options: ['water', 'food', 'house', 'family'],
        sourceLanguage: 'lun',
        targetLanguage: 'en',
        difficulty: 1,
        category: 'Basic Vocabulary',
      ),
      Exercise(
        id: '3',
        type: ExerciseType.fillInTheBlank,
        question: 'Complete: "Mwakwenu wa ____" (Good morning)',
        correctAnswer: 'chilo',
        sourceLanguage: 'lun',
        targetLanguage: 'lun',
        difficulty: 2,
        category: 'Greetings',
      ),
      Exercise(
        id: '4',
        type: ExerciseType.translation,
        question: 'Translate "Shani" to English',
        correctAnswer: 'hello',
        sourceLanguage: 'bem',
        targetLanguage: 'en',
        difficulty: 1,
        category: 'Greetings',
      ),
      Exercise(
        id: '5',
        type: ExerciseType.multipleChoice,
        question: 'How do you say "thank you" in Bemba?',
        correctAnswer: 'Natotela',
        options: ['Natotela', 'Shani', 'Twalumba', 'Mwabuka'],
        sourceLanguage: 'en',
        targetLanguage: 'bem',
        difficulty: 2,
        category: 'Politeness',
      ),
    ];
  }

  void startLearningSession(String languagePair) {
    final sessionExercises = _exercises
        .where((e) => '${e.sourceLanguage}_${e.targetLanguage}' == languagePair)
        .take(5)
        .toList();

    _currentSession = LearningSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      exercises: sessionExercises,
    );

    _currentExerciseIndex = 0;
    notifyListeners();
  }

  void submitAnswer(String exerciseId, String answer) {
    if (_currentSession == null) return;

    final exercise = _currentSession!.exercises[_currentExerciseIndex];
    final isCorrect = answer.toLowerCase().trim() == exercise.correctAnswer.toLowerCase().trim();

    // Update session answers
    _currentSession = LearningSession(
      id: _currentSession!.id,
      startTime: _currentSession!.startTime,
      exercises: _currentSession!.exercises,
      answers: {..._currentSession!.answers, exerciseId: isCorrect},
      score: _currentSession!.score + (isCorrect ? 1 : 0),
      isCompleted: _currentExerciseIndex >= _currentSession!.exercises.length - 1,
    );

    if (_currentExerciseIndex < _currentSession!.exercises.length - 1) {
      _currentExerciseIndex++;
    }

    notifyListeners();
  }

  void nextExercise() {
    if (_currentSession != null && _currentExerciseIndex < _currentSession!.exercises.length - 1) {
      _currentExerciseIndex++;
      notifyListeners();
    }
  }

  void completeSession() {
    if (_currentSession != null) {
      final languagePair = '${_currentSession!.exercises.first.sourceLanguage}_${_currentSession!.exercises.first.targetLanguage}';
      _progress[languagePair] = (_progress[languagePair] ?? 0) + _currentSession!.score;
      
      _currentSession = null;
      _currentExerciseIndex = 0;
      notifyListeners();
    }
  }

  List<Exercise> getExercisesByCategory(String category) {
    return _exercises.where((e) => e.category == category).toList();
  }

  List<String> get availableCategories {
    return _exercises.map((e) => e.category).toSet().toList();
  }
}
