import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';

class ApiService {
  static const String baseUrl = 'https://opentdb.com/api.php';

  Future<List<Question>> fetchQuestions({
    int amount = 10,
    int? category,
    String? difficulty,
    String type = 'multiple',
  }) async {

    /// ✅ IMPORTANT: query params must be String
    final Map<String, String> queryParams = {
      'amount': amount.toString(),
      'type': type,
    };

    if (category != null) {
      queryParams['category'] = category.toString();
    }

    if (difficulty != null) {
      queryParams['difficulty'] = difficulty;
    }

    final uri =
        Uri.parse(baseUrl).replace(queryParameters: queryParams);

    final response = await http.get(uri);

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);

      if (data is! Map || data['response_code'] != 0) {
        throw Exception(
            'API returned error: ${data['response_code'] ?? 'unknown'}');
      }

      final results = data['results'];

      if (results is! List) {
        throw Exception('Invalid response format');
      }

      final List<Question> questions = [];

      for (var item in results) {
        try {
          questions.add(Question.fromJson(item));
        } catch (e) {
          print('Skipping bad question: $e');
        }
      }

      if (questions.isEmpty) {
        throw Exception('No valid questions received');
      }

      return questions;
    } else {
      throw Exception(
          'Failed to load questions: HTTP ${response.statusCode}');
    }
  }
}

/// =======================================================
/// QUESTION MODEL
/// =======================================================

class Question {
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final List<String> allAnswers;

  Question({
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
    required this.allAnswers,
  });

  /// ✅ HTML decoding FIX is here
  factory Question.fromJson(Map<String, dynamic> json) {
    final unescape = HtmlUnescape();

    // Decode incorrect answers
    final incorrectRaw = json['incorrect_answers'];
    List<String> incorrect = [];

    if (incorrectRaw is List) {
      incorrect = incorrectRaw
          .map((e) => unescape.convert(e.toString()))
          .toList();
    }

    // Decode correct answer
    final correct =
        unescape.convert(json['correct_answer']?.toString() ?? '');

    // Decode question text
    final questionText =
        unescape.convert(json['question']?.toString() ?? 'No question');

    // Combine + shuffle
    final all = List<String>.from(incorrect)..add(correct);
    all.shuffle();

    return Question(
      question: questionText,
      correctAnswer: correct,
      incorrectAnswers: incorrect,
      allAnswers: all,
    );
  }
}
