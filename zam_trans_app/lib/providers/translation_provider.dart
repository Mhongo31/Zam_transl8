import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/language.dart';

class TranslationResult {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;
  final double confidence;

  TranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
    this.confidence = 0.95,
  });
}

class TranslationProvider with ChangeNotifier {
  Language _sourceLanguage = Language.supportedLanguages[0]; // English
  Language _targetLanguage = Language.supportedLanguages[1]; // Lunda
  List<TranslationResult> _history = [];
  bool _isTranslating = false;
  String? _errorMessage;

  Language get sourceLanguage => _sourceLanguage;
  Language get targetLanguage => _targetLanguage;
  List<TranslationResult> get history => _history;
  bool get isTranslating => _isTranslating;
  String? get errorMessage => _errorMessage;

  void setSourceLanguage(Language language) {
    _sourceLanguage = language;
    notifyListeners();
  }

  void setTargetLanguage(Language language) {
    _targetLanguage = language;
    notifyListeners();
  }

  void swapLanguages() {
    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;
    notifyListeners();
  }

  Future<TranslationResult> translate(String text) async {
    _isTranslating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Determine the translation direction
      String direction;
      if (_sourceLanguage.code == 'en' && _targetLanguage.code == 'lunda') {
        direction = 'en_to_lu';
      } else if (_sourceLanguage.code == 'lunda' && _targetLanguage.code == 'en') {
        direction = 'lu_to_en';
      } else {
        throw Exception('Unsupported translation direction: ${_sourceLanguage.code} to ${_targetLanguage.code}');
      }

      // Use the correct API endpoint
      const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8001');
      final String endpoint = '$baseUrl/translate';

      print('Sending request to BART API: text="$text", direction="$direction"');
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'direction': direction,
          'text': text,
          'max_length': 128,
          'num_beams': 4,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Parse the correct response format
        final translatedText = data['translation'] as String? ?? '';
        final confidence = 0.95; // BART model confidence
        
        print('BART translation successful: "$translatedText"');
        
        final result = TranslationResult(
          originalText: text,
          translatedText: translatedText,
          sourceLanguage: _sourceLanguage.code,
          targetLanguage: _targetLanguage.code,
          timestamp: DateTime.now(),
          confidence: confidence,
        );

        _history.insert(0, result);
        if (_history.length > 100) {
          _history = _history.take(100).toList();
        }

        _isTranslating = false;
        notifyListeners();
        return result;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('BART API error: ${errorData['detail'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _isTranslating = false;
      _errorMessage = 'Translation failed: $e';
      print('Error: $_errorMessage');
      notifyListeners();
      
      final result = TranslationResult(
        originalText: text,
        translatedText: '',
        sourceLanguage: _sourceLanguage.code,
        targetLanguage: _targetLanguage.code,
        timestamp: DateTime.now(),
        confidence: 0.0,
      );
      _history.insert(0, result);
      return result;
    }
  }
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}