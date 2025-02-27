import 'package:flutter/material.dart';
import 'quiz_model.dart';

class QuizDetailPage extends StatefulWidget {
  final Quiz quiz;

  QuizDetailPage({required this.quiz});

  @override
  _QuizDetailPageState createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  int currentQuestionIndex = 0;
  Map<int, String> selectedAnswers = {};  // Stores user answers

  void nextQuestion() {
    if (currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    String outfitRecommendation = "Your outfit is based on your choices!";
    
    // Custom recommendations based on quiz type
    if (widget.quiz.title == "Mood-Based Quiz") {
      outfitRecommendation = "You should wear something cozy and bright!";
    } else if (widget.quiz.title == "Occasion-Based Quiz") {
      outfitRecommendation = "A formal or casual outfit would be perfect!";
    } else if (widget.quiz.title == "Weather-Based Quiz") {
      outfitRecommendation = "Dress according to the weather today!";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Quiz Result"),
        content: Text(outfitRecommendation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz.title)),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(question.questionText, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          ...question.options.map((option) {
            return ListTile(
              title: Text(option),
              leading: Radio<String>(
                value: option,
                groupValue: selectedAnswers[currentQuestionIndex],
                onChanged: (value) {
                  setState(() {
                    selectedAnswers[currentQuestionIndex] = value!;
                  });
                },
              ),
            );
          }).toList(),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: nextQuestion,
            child: Text(currentQuestionIndex < widget.quiz.questions.length - 1
                ? "Next"
                : "Get Recommendation"),
          ),
        ],
      ),
    );
  }
}
