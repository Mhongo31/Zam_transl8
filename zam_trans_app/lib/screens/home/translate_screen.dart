import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/translation_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../models/language.dart';
import './subscription/subscription_screen.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _showLanguageSelector(bool isSource) {
    showModalBottomSheet(
      context: context,
      builder: (context) => LanguageSelector(
        isSource: isSource,
        onLanguageSelected: (language) {
          final translationProvider = Provider.of<TranslationProvider>(context, listen: false);
          final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);

          if (!language.isFree && !subscriptionProvider.currentSubscription.canAccessLanguage(language.code)) {
            _showSubscriptionRequired(language);
            return;
          }

          if (isSource) {
            translationProvider.setSourceLanguage(language);
          } else {
            translationProvider.setTargetLanguage(language);
          }
          Navigator.pop(context);
          // Force UI rebuild to show selected language
          if (mounted) {
            setState(() {});
          }
        },
      ),
    );
  }

  void _showSubscriptionRequired(Language language) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Language'),
        content: Text(
          '${language.name} is available with a Premium subscription. '
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

  Future<void> _translate() async {
    if (_inputController.text.trim().isEmpty) return;

    final translationProvider = Provider.of<TranslationProvider>(context, listen: false);
    final result = await translationProvider.translate(_inputController.text);

    if (mounted) {
      setState(() {
        _outputController.text = result.translatedText;
        if (translationProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(translationProvider.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transl8',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      resizeToAvoidBottomInset: true,
      body: Consumer<TranslationProvider>(
        builder: (context, translationProvider, child) {
          // Force rebuild when languages change
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showLanguageSelector(true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              translationProvider.sourceLanguage.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GestureDetector(
                          onTap: translationProvider.swapLanguages,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.swap_horiz,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showLanguageSelector(false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              translationProvider.targetLanguage.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          maxLines: null,
                          expands: true,
                          decoration: const InputDecoration(
                            hintText: 'Enter text to translate...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    // Voice input functionality
                                  },
                                  icon: const Icon(Icons.mic),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _inputController.clear();
                                    _outputController.clear();
                                  },
                                  icon: const Icon(Icons.clear),
                                ),
                              ],
                            ),
                            Text(
                              '${_inputController.text.length}/500',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: translationProvider.isTranslating ? null : _translate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: translationProvider.isTranslating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Translate',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _outputController,
                          maxLines: null,
                          expands: true,
                          readOnly: true,
                          decoration: const InputDecoration(
                            hintText: 'Translation will appear here...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      if (_outputController.text.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: _outputController.text));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Copied to clipboard')),
                                  );
                                },
                                icon: const Icon(Icons.copy),
                              ),
                              IconButton(
                                onPressed: () {
                                  // Text-to-speech functionality
                                },
                                icon: const Icon(Icons.volume_up),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LanguageSelector extends StatelessWidget {
  final bool isSource;
  final Function(Language) onLanguageSelected;

  const LanguageSelector({
    super.key,
    required this.isSource,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isSource ? 'Select Source Language' : 'Select Target Language',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: Language.supportedLanguages.map((language) {
                return Consumer<SubscriptionProvider>(
                  builder: (context, subscriptionProvider, child) {
                    final canAccess = language.isFree ||
                        subscriptionProvider.currentSubscription
                            .canAccessLanguage(language.code);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            canAccess ? Theme.of(context).primaryColor : Colors.grey,
                        child: Text(
                          language.code.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                      title: Text(language.name),
                      subtitle: Text(language.nativeName),
                      trailing: language.isFree
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : canAccess
                              ? const Icon(Icons.star, color: Colors.amber)
                              : const Icon(Icons.lock, color: Colors.grey),
                      onTap: () => onLanguageSelected(language),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
