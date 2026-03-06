import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';

class QuestionDialog extends StatefulWidget {
  const QuestionDialog({super.key});

  @override
  State<QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {

  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {

    final quizProvider = Provider.of<QuizProvider>(context);

    return AlertDialog(
      content: SizedBox(
        width: double.maxFinite,
        height: 500,

        child: PageView.builder(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quizProvider.questions.length,

          itemBuilder: (context, index) {

            final question = quizProvider.questions[index];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "Question ${index + 1}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                ...question.allAnswers.map((answer) {

                  return RadioListTile<String>(
                    title: Text(answer),
                    value: answer,
                    groupValue: quizProvider.userAnswers[index],

                    onChanged: (value) {
                      if (value != null) {
                        quizProvider.selectAnswerForIndex(index, value);
                      }
                    },
                  );

                }).toList(),

                const Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    TextButton(
                      onPressed: index == 0
                          ? null
                          : () {

                              _controller.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );

                              quizProvider.previousQuestion();
                            },
                      child: const Text("Back"),
                    ),

                    ElevatedButton(
                      onPressed: quizProvider.userAnswers[index] == null
                          ? null
                          : () {

                              if (index == quizProvider.questions.length - 1) {
                                quizProvider.nextQuestion(); // marks quiz finished
                                Navigator.pop(context);

                              }
                               else {

                                _controller.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );

                                quizProvider.nextQuestion();
                              }
                            },
                      child: Text(
                        index == quizProvider.questions.length - 1
                            ? "Finish"
                            : "Next",
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}