import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zam_trans_app/models/subscription.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/learning_provider.dart';
import '../../models/language.dart';
import './subscription/subscription_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showSettingsDialog(context),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Consumer3<AuthProvider, SubscriptionProvider, LearningProvider>(
        builder: (context, authProvider, subscriptionProvider, learningProvider, child) {
          final user = authProvider.user;
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(user),
                const SizedBox(height: 24),

                // Stats Cards
                _buildStatsSection(user, learningProvider),
                const SizedBox(height: 24),

                // Subscription Status
                _buildSubscriptionSection(context, subscriptionProvider),
                const SizedBox(height: 24),

                // Learning Progress
                _buildLearningProgress(user, learningProvider),
                const SizedBox(height: 24),

                // Achievements
                _buildAchievements(user),
                const SizedBox(height: 24),

                // Settings Options
                _buildSettingsOptions(context, authProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              child: user.profileImage.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        user.profileImage,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Member since ${_formatDate(user.joinDate)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(user, LearningProvider learningProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Streak',
            '${user.streakDays}',
            'days',
            Icons.local_fire_department,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Translations',
            '${user.totalTranslations}',
            'total',
            Icons.translate,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Languages',
            '${user.favoriteLanguages.length}',
            'learning',
            Icons.language,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionSection(BuildContext context, SubscriptionProvider subscriptionProvider) {
    final subscription = subscriptionProvider.currentSubscription;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subscription',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subscription.tier == SubscriptionTier.free)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
                      );
                    },
                    child: const Text('Upgrade'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: subscription.tier == SubscriptionTier.free
                        ? Colors.grey[200]
                        : Colors.amber[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    subscription.tierName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: subscription.tier == SubscriptionTier.free
                          ? Colors.grey[700]
                          : Colors.amber[800],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  subscription.isActive ? Icons.check_circle : Icons.cancel,
                  color: subscription.isActive ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  subscription.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: subscription.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (subscription.expiryDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Expires: ${_formatDate(subscription.expiryDate!)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Available Languages: ${subscription.availableLanguages.length}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningProgress(user, LearningProvider learningProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Learning Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (user.languageProgress.isEmpty)
              const Text(
                'Start learning to see your progress!',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...user.languageProgress.entries.map((entry) {
                final languageCode = entry.key;
                final progress = entry.value;
                final language = Language.getLanguageByCode(languageCode);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            language.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '$progress%',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(progress),
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

  Widget _buildAchievements(user) {
    final achievements = [
      {
        'title': 'First Translation',
        'description': 'Complete your first translation',
        'icon': Icons.translate,
        'earned': user.totalTranslations > 0,
        'color': Colors.blue,
      },
      {
        'title': 'Streak Master',
        'description': 'Maintain a 7-day streak',
        'icon': Icons.local_fire_department,
        'earned': user.streakDays >= 7,
        'color': Colors.orange,
      },
      {
        'title': 'Polyglot',
        'description': 'Learn 3 different languages',
        'icon': Icons.language,
        'earned': user.favoriteLanguages.length >= 3,
        'color': Colors.green,
      },
      {
        'title': 'Dedicated Learner',
        'description': 'Complete 100 translations',
        'icon': Icons.school,
        'earned': user.totalTranslations >= 100,
        'color': Colors.purple,
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Achievements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                final isEarned = achievement['earned'] as bool;
                
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isEarned 
                        ? (achievement['color'] as Color).withOpacity(0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isEarned 
                          ? (achievement['color'] as Color)
                          : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        achievement['icon'] as IconData,
                        size: 32,
                        color: isEarned 
                            ? (achievement['color'] as Color)
                            : Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        achievement['title'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isEarned ? null : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement['description'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: isEarned ? Colors.grey[600] : Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOptions(BuildContext context, AuthProvider authProvider) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: Switch(
              value: true, // This would be from user preferences
              onChanged: (value) {
                // Handle notification toggle
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: false, // This would be from theme provider
              onChanged: (value) {
                // Handle theme toggle
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('App Language'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showLanguageSelector(context);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showHelpDialog(context);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _showSignOutDialog(context, authProvider),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(int progress) {
    if (progress >= 80) return Colors.green;
    if (progress >= 60) return Colors.orange;
    if (progress >= 40) return Colors.yellow[700]!;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text('Settings functionality would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              leading: Radio(
                value: 'en',
                groupValue: 'en',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('Lunda'),
              leading: Radio(
                value: 'lun',
                groupValue: 'en',
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'For help and support, please contact us at:\n\n'
          'Email: support@zambiantranslator.com\n'
          'Phone: +260 XXX XXX XXX\n\n'
          'We\'re here to help you learn Zambian languages!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Zambian Translator',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.translate,
        size: 48,
        color: Color(0xFF2E7D32),
      ),
      children: [
        const Text(
          'A comprehensive language learning and translation app for Zambian languages. '
          'Learn Lunda, Bemba, Nyanja, Tonga, and more with interactive exercises and real-time translation.',
        ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
