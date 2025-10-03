import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/learning_provider.dart';
import '../../../models/exercise.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final _answerController = TextEditingController();
  String? _selectedAnswer;
  bool _showResult = false;
  bool _isCorrect = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise'),
        elevation: 0,
      ),
      body: Consumer<LearningProvider>(
        builder: (context, learningProvider, child) {
          final session = learningProvider.currentSession;
          if (session == null) {
            return const Center(child: Text('No active session'));
          }

          final currentExercise = session.exercises[learningProvider.currentExerciseIndex];
          final progress = (learningProvider.currentExerciseIndex + 1) / session.exercises.length;

          return Column(
            children: [
              // Progress bar
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${learningProvider.currentExerciseIndex + 1} of ${session.exercises.length}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Score: ${session.score}/${session.exercises.length}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Exercise content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildExerciseContent(currentExercise),
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: _showResult
                    ? _buildResultButtons(learningProvider, session)
                    : _buildAnswerButton(currentExercise),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExerciseContent(Exercise exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exercise type badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getExerciseTypeColor(exercise.type),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _getExerciseTypeName(exercise.type),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Question
        Text(
          exercise.question,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 24),

        // Answer input based on exercise type
        Expanded(
          child: _buildAnswerInput(exercise),
        ),

        // Result feedback
        if (_showResult) _buildResultFeedback(exercise),
      ],
    );
  }

  Widget _buildAnswerInput(Exercise exercise) {
    switch (exercise.type) {
      case ExerciseType.translation:
      case ExerciseType.fillInTheBlank:
        return TextField(
          controller: _answerController,
          enabled: !_showResult,
          decoration: const InputDecoration(
            hintText: 'Type your answer...',
            border: OutlineInputBorder(),
          ),
          style: const TextStyle(fontSize: 16),
          maxLines: 3,
        );

      case ExerciseType.multipleChoice:
        return Column(
          children: exercise.options.map((option) {
            final isSelected = _selectedAnswer == option;
            final isCorrect = option == exercise.correctAnswer;
            
            Color? backgroundColor;
            Color? textColor;
            
            if (_showResult) {
              if (isCorrect) {
                backgroundColor = Colors.green.withOpacity(0.2);
                textColor = Colors.green[700];
              } else if (isSelected && !isCorrect) {
                backgroundColor = Colors.red.withOpacity(0.2);
                textColor = Colors.red[700];
              }
            } else if (isSelected) {
              backgroundColor = Theme.of(context).primaryColor.withOpacity(0.1);
              textColor = Theme.of(context).primaryColor;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: _showResult ? null : () {
                  setState(() {
                    _selectedAnswer = option;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor,
                            fontWeight: isSelected ? FontWeight.w500 : null,
                          ),
                        ),
                      ),
                      if (_showResult && isCorrect)
                        const Icon(Icons.check_circle, color: Colors.green),
                      if (_showResult && isSelected && !isCorrect)
                        const Icon(Icons.cancel, color: Colors.red),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );

      case ExerciseType.listening:
        return Column(
          children: [
            const Icon(
              Icons.headphones,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Play audio functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Audio playback not implemented in demo')),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play Audio'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _answerController,
              enabled: !_showResult,
              decoration: const InputDecoration(
                hintText: 'Type what you heard...',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        );

      case ExerciseType.speaking:
        return Column(
          children: [
            const Icon(
              Icons.mic,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Speech recognition functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Speech recognition not implemented in demo')),
                );
              },
              icon: const Icon(Icons.mic),
              label: const Text('Start Recording'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _answerController,
              enabled: !_showResult,
              decoration: const InputDecoration(
                hintText: 'Or type your answer...',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        );
    }
  }

  Widget _buildResultFeedback(Exercise exercise) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isCorrect ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isCorrect ? Icons.check_circle : Icons.cancel,
                color: _isCorrect ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                _isCorrect ? 'Correct!' : 'Incorrect',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isCorrect ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          if (!_isCorrect) ...[
            const SizedBox(height: 8),
            Text(
              'Correct answer: ${exercise.correctAnswer}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerButton(Exercise exercise) {
    final canSubmit = exercise.type == ExerciseType.multipleChoice
        ? _selectedAnswer != null
        : _answerController.text.trim().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSubmit ? () => _submitAnswer(exercise) : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Submit Answer',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildResultButtons(LearningProvider learningProvider, LearningSession session) {
    final isLastExercise = learningProvider.currentExerciseIndex >= session.exercises.length - 1;

    return Row(
      children: [
        if (!isLastExercise) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () => _nextExercise(learningProvider),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Next Exercise'),
            ),
          ),
        ] else ...[
          Expanded(
            child: ElevatedButton(
              onPressed: () => _completeSession(learningProvider),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Complete Session'),
            ),
          ),
        ],
      ],
    );
  }

  void _submitAnswer(Exercise exercise) {
    final answer = exercise.type == ExerciseType.multipleChoice
        ? _selectedAnswer ?? ''
        : _answerController.text.trim();

    final learningProvider = Provider.of<LearningProvider>(context, listen: false);
    learningProvider.submitAnswer(exercise.id, answer);

    setState(() {
      _isCorrect = answer.toLowerCase() == exercise.correctAnswer.toLowerCase();
      _showResult = true;
    });
  }

  void _nextExercise(LearningProvider learningProvider) {
    learningProvider.nextExercise();
    setState(() {
      _answerController.clear();
      _selectedAnswer = null;
      _showResult = false;
      _isCorrect = false;
    });
  }

  void _completeSession(LearningProvider learningProvider) {
    final session = learningProvider.currentSession!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Score: ${session.score}/${session.exercises.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Accuracy: ${((session.score / session.exercises.length) * 100).toInt()}%',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              learningProvider.completeSession();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to learn screen
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Color _getExerciseTypeColor(ExerciseType type) {
    switch (type) {
      case ExerciseType.translation:
        return Colors.blue;
      case ExerciseType.multipleChoice:
        return Colors.green;
      case ExerciseType.fillInTheBlank:
        return Colors.orange;
      case ExerciseType.listening:
        return Colors.purple;
      case ExerciseType.speaking:
        return Colors.red;
    }
  }

  String _getExerciseTypeName(ExerciseType type) {
    switch (type) {
      case ExerciseType.translation:
        return 'Translation';
      case ExerciseType.multipleChoice:
        return 'Multiple Choice';
      case ExerciseType.fillInTheBlank:
        return 'Fill in the Blank';
      case ExerciseType.listening:
        return 'Listening';
      case ExerciseType.speaking:
        return 'Speaking';
    }
  }
}
