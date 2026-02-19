import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../services/api_service.dart';

class QuestionDialog extends StatefulWidget {
  final Question question;
  final VoidCallback onNext;

  const QuestionDialog({
    super.key,
    required this.question,
    required this.onNext,
  });

  @override
  State<QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {

  bool _nextTriggered = false; // ✅ prevents multiple navigation

  Color? _getTileColor(QuizProvider provider, String answer) {
    if (!provider.showResult) return null;

    if (answer == widget.question.correctAnswer) {
      return Colors.green.withOpacity(0.3);
    }

    if (answer == provider.selectedAnswer) {
      return Colors.red.withOpacity(0.3);
    }

    return null;
  }

  void _handleAutoNext(QuizProvider provider) {
    if (_nextTriggered) return; // ✅ run once only
    if (!provider.showResult) return;

    _nextTriggered = true;

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      Navigator.of(context).pop();
      widget.onNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);

    // ✅ safe trigger
    _handleAutoNext(quizProvider);

    return AlertDialog(
      title: Text(widget.question.question),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.question.allAnswers.map((answer) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: _getTileColor(quizProvider, answer),
                borderRadius: BorderRadius.circular(8),
              ),
              child: RadioListTile<String>(
                title: Text(answer),
                value: answer,
                groupValue: quizProvider.selectedAnswer,
                onChanged: quizProvider.showResult
                    ? null
                    : (value) {
                        if (value != null) {
                          quizProvider.selectAnswer(value);
                        }
                      },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
