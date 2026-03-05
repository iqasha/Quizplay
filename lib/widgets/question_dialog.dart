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

class _QuestionDialogState extends State<QuestionDialog>{
  @override
  Widget build(BuildContext context){
    final quizProvider = Provider.of<QuizProvider>(context);

    return AlertDialog(
      title: Text(widget.question.question),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: widget.question.allAnswers.map((answer){
            return RadioListTile<String>(
              title: Text(answer),
              value: answer,
              groupValue: quizProvider.selectedAnswer,
              onChanged: (value){
                if(value != null){
                  quizProvider.selectAnswer(value);
                }
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(onPressed: quizProvider.currentIndex == 0? null:(){
          Navigator.of(context).pop();
          quizProvider.previousQuestion();
        }, 
        child: const Text("Back"),
        ),
        ElevatedButton(
          onPressed: quizProvider.selectedAnswer == null? null:(){
            Navigator.of(context).pop();
            widget.onNext();
          }, 
          child: const Text("Next")
        ),
      ],
    );
  }
}