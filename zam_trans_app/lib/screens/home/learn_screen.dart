import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/learning_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../models/language.dart';
import '../../models/exercise.dart';
import './learning/exercise_screen.dart';
import './subscription/subscription_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
        elevation: 0,
      ),
      body: Consumer2<LearningProvider, SubscriptionProvider>(
        builder: (context, learningProvider, subscriptionProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Overview
                _buildProgressOverview(learningProvider),
                const SizedBox(height: 24),

                // Language Pairs
                const Text(
                  'Choose Language Pair',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLanguagePairs(learningProvider, subscriptionProvider),
                
                const SizedBox(height: 24),

                // Categories
                const Text(
                  'Learning Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCategories(learningProvider),

                const SizedBox(height: 24),

                // Daily Challenge
                _buildDailyChallenge(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressOverview(LearningProvider learningProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (learningProvider.progress.isEmpty)
              const Text(
                'Start learning to see your progress!',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...learningProvider.progress.entries.map((entry) {
                final languagePair = entry.key.split('_');
                final sourceLang = Language.getLanguageByCode(languagePair[0]);
                final targetLang = Language.getLanguageByCode(languagePair[1]);
                final progress = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${sourceLang.name} → ${targetLang.name}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$progress points',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagePairs(LearningProvider learningProvider, SubscriptionProvider subscriptionProvider) {
    final languagePairs = [
      {'from': 'en', 'to': 'lun', 'name': 'English → Lunda', 'free': true},
      {'from': 'lun', 'to': 'en', 'name': 'Lunda → English', 'free': true},
      {'from': 'en', 'to': 'bem', 'name': 'English → Bemba', 'free': true},
      {'from': 'bem', 'to': 'en', 'name': 'Bemba → English', 'free': true},
      {'from': 'en', 'to': 'nya', 'name': 'English → Nyanja', 'free': false},
      {'from': 'nya', 'to': 'en', 'name': 'Nyanja → English', 'free': false},
      {'from': 'en', 'to': 'ton', 'name': 'English → Tonga', 'free': false},
      {'from': 'ton', 'to': 'en', 'name': 'Tonga → English', 'free': false},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: languagePairs.length,
      itemBuilder: (context, index) {
        final pair = languagePairs[index];
        final isFree = pair['free'] as bool;
        final canAccess = isFree || subscriptionProvider.canAccessLanguage(pair['from'] as String);
        final pairKey = '${pair['from']}_${pair['to']}';

        return GestureDetector(
          onTap: () {
            if (!canAccess) {
              _showSubscriptionRequired();
              return;
            }
            _startLearningSession(pairKey);
          },
          child: Card(
            elevation: canAccess ? 2 : 1,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: canAccess ? null : Colors.grey[100],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    canAccess ? Icons.play_circle_filled : Icons.lock,
                    size: 32,
                    color: canAccess ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pair['name'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: canAccess ? null : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!isFree)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: canAccess ? Colors.amber : Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        canAccess ? 'PRO' : 'LOCKED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategories(LearningProvider learningProvider) {
    final categories = learningProvider.availableCategories;
    
    return Column(
      children: categories.map((category) {
        final exercises = learningProvider.getExercisesByCategory(category);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                category[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text('${exercises.length} exercises'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to category exercises
              _showCategoryExercises(category, exercises);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDailyChallenge() {
    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Daily Challenge',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete today\'s challenge to maintain your streak!',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _startDailyChallenge();
                },
                child: const Text('Start Challenge'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startLearningSession(String languagePair) {
    final learningProvider = Provider.of<LearningProvider>(context, listen: false);
    learningProvider.startLearningSession(languagePair);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExerciseScreen(),
      ),
    );
  }

  void _showCategoryExercises(String category, List<Exercise> exercises) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getExerciseTypeColor(exercise.type),
                          child: Icon(
                            _getExerciseTypeIcon(exercise.type),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(exercise.question),
                        subtitle: Text(
                          '${Language.getLanguageByCode(exercise.sourceLanguage).name} → '
                          '${Language.getLanguageByCode(exercise.targetLanguage).name}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...List.generate(
                              exercise.difficulty,
                              (index) => Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                        onTap: () {
                          // Start individual exercise
                          Navigator.pop(context);
                          // TODO: Navigate to individual exercise
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startDailyChallenge() {
    // Start a mixed challenge with random exercises
    final learningProvider = Provider.of<LearningProvider>(context, listen: false);
    learningProvider.startLearningSession('en_lun'); // Default to English-Lunda
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExerciseScreen(),
      ),
    );
  }

  void _showSubscriptionRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Required'),
        content: const Text(
          'This language pair is available with a Premium subscription. '
          'Upgrade now to access all Zambian languages!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
              );
            },
            child: const Text('Upgrade'),
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

  IconData _getExerciseTypeIcon(ExerciseType type) {
    switch (type) {
      case ExerciseType.translation:
        return Icons.translate;
      case ExerciseType.multipleChoice:
        return Icons.quiz;
      case ExerciseType.fillInTheBlank:
        return Icons.edit;
      case ExerciseType.listening:
        return Icons.headphones;
      case ExerciseType.speaking:
        return Icons.mic;
    }
  }
}
