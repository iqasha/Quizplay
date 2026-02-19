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

    /// open dialog only when question changes
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
      body: Center(
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
                      'Quiz Finished! Score: ${quizProvider.score}'),
                  ElevatedButton(
                    onPressed: quizProvider.reset,
                    child: const Text('Play Again'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
