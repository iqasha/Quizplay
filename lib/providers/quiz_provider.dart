import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QuizProvider extends ChangeNotifier{
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _isLoading = false;
  String? _error;
  bool _showResult = false;
  bool get showResult => _showResult;

  List<Question> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get score => _score;
  String? get selectedAnswer => _selectedAnswer;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isQuizFinished => _currentIndex >=  _questions.length;

  Question? get currentQuestion => 
  _questions.isNotEmpty && !isQuizFinished ? _questions[_currentIndex] : null;

  Future<void> loadQuestions({
    int amount = 10,
    int? category,
    String? difficulty,
  })async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try{
      _questions = await ApiService().fetchQuestions(
        amount: amount,
        category: category,
        difficulty: difficulty,
      );
      _currentIndex =0;
      _score = 0;
      _selectedAnswer = null;
      _error = null;
    }catch(e){
      _error = e.toString();
      _questions = [];
    }finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectAnswer(String answer) {
    if (_showResult) return; // prevent reselection

    _selectedAnswer = answer;
    _showResult = true;
    notifyListeners();
  }

    void nextQuestion() {
      if (_selectedAnswer != null) {
        if (_selectedAnswer ==
            _questions[_currentIndex].correctAnswer) {
          _score++;
        }
      }

      _currentIndex++;
      _selectedAnswer = null;
      _showResult = false; // reset
      notifyListeners();
    }

  void reset(){
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}