import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/question_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _lastQuestionIndex = -1;
  bool _dialogOpen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = Provider.of<QuizProvider>(context);

    if (provider.currentQuestion != null &&
        !_dialogOpen &&
        provider.currentIndex != _lastQuestionIndex) {

      _lastQuestionIndex = provider.currentIndex;
      _dialogOpen = true;

      Future.microtask(() {
        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => QuestionDialog(
            question: provider.currentQuestion!,
            onNext: () {
              provider.nextQuestion();
              _dialogOpen = false;
            },
          ),
        ).then((_) {
          _dialogOpen = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final quizProvider = Provider.of<QuizProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trivia Quiz'),
        actions: [
          if (quizProvider.questions.isNotEmpty &&
              !quizProvider.isQuizFinished)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Score: ${quizProvider.score}'),
            ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              if (quizProvider.isLoading)
                const CircularProgressIndicator()

              else if (quizProvider.error != null)
                Column(
                  children: [
                    Text('Error: ${quizProvider.error}'),
                    ElevatedButton(
                      onPressed: quizProvider.loadQuestions,
                      child: const Text('Retry'),
                    ),
                  ],
                )

              else if (quizProvider.questions.isEmpty)
                ElevatedButton(
                  onPressed: quizProvider.loadQuestions,
                  child: const Text('Start Quiz'),
                )

              else if (quizProvider.isQuizFinished)
                Column(
                  children: [

                    Text(
                      'Final Score: ${quizProvider.score}/${quizProvider.questions.length}',
                      style: const TextStyle(fontSize: 22),
                    ),

                    const SizedBox(height: 20),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: quizProvider.questions.length,
                      itemBuilder: (context, index) {

                        final question = quizProvider.questions[index];
                        final correct = question.correctAnswer;
                        final user = quizProvider.userAnswers[index];
                        final isCorrect = correct == user;

                        return ListTile(
                          title: Text(question.question),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Your Answer: $user"),
                              Text("Correct Answer: $correct"),
                            ],
                          ),
                          leading: Icon(
                            isCorrect ? Icons.check : Icons.close,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: quizProvider.reset,
                      child: const Text('Play Again'),
                    ),

                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}