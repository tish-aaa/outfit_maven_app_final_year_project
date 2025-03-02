import 'package:flutter/material.dart';
import 'quiz_model.dart';

class QuizDetailPage extends StatefulWidget {
  final Quiz quiz;

  QuizDetailPage({required this.quiz});

  @override
  _QuizDetailPageState createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  Map<int, String> selectedAnswers = {};

  void _showResult() {
    print("Get Recommendation button clicked!"); // Debugging
    if (selectedAnswers.length < widget.quiz.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please answer all questions!")),
      );
      return;
    }

    Map<String, int> answerCount = {"A": 0, "B": 0, "C": 0, "D": 0};

    for (var answer in selectedAnswers.values) {
      if (answer.startsWith("Happy") ||
          answer.startsWith("Sunny") ||
          answer.startsWith("Casual") ||
          answer.startsWith("Super social")) {
        answerCount["A"] = (answerCount["A"] ?? 0) + 1;
      } else if (answer.startsWith("Calm") ||
          answer.startsWith("Cool") ||
          answer.startsWith("Chic") ||
          answer.startsWith("A little social")) {
        answerCount["B"] = (answerCount["B"] ?? 0) + 1;
      } else if (answer.startsWith("Moody") ||
          answer.startsWith("Rainy") ||
          answer.startsWith("Edgy") ||
          answer.startsWith("Not much")) {
        answerCount["C"] = (answerCount["C"] ?? 0) + 1;
      } else {
        answerCount["D"] = (answerCount["D"] ?? 0) + 1;
      }
    }

    String highestCategory =
        answerCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    if (!widget.quiz.results.containsKey(highestCategory)) {
      print("Error: No matching result for category $highestCategory");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected error! No result found.")),
      );
      return;
    }

    QuizResult result = widget.quiz.results[highestCategory]!;

    print("Opening dialog for result: ${result.description}"); // Debugging

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(result.image,
                    width: 220, height: 220, fit: BoxFit.cover),
              ),
              SizedBox(height: 12),
              Text(
                "Your Perfect Outfit!",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1DCFCA)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                result.description,
                style: TextStyle(fontSize: 16, color: Color(0xFF298A90)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF70C2BD),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  setState(() {
                    selectedAnswers.clear();
                  });
                  Navigator.pop(context);
                },
                child: Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title, style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF70C2BD),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
              child: Image.asset(widget.quiz.image,
                  height: 220, width: double.infinity, fit: BoxFit.cover),
            ),
            SizedBox(height: 20),
            ...widget.quiz.questions.asMap().entries.map((entry) {
              int index = entry.key;
              Question question = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      question.questionText,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF298A90)),
                    ),
                  ),
                  ...question.options.map((option) {
                    return ListTile(
                      title: Text(option,
                          style: TextStyle(
                              fontSize: 16, color: Color(0xFF1D8A7A))),
                      leading: Radio<String>(
                        value: option,
                        groupValue: selectedAnswers[index],
                        activeColor: Color(0xFF1DCFCA),
                        onChanged: (value) {
                          setState(() {
                            selectedAnswers[index] = value!;
                          });
                        },
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 10),
                ],
              );
            }).toList(),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF70C2BD),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              onPressed: _showResult,
              child: Text(
                "Get Recommendation",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
