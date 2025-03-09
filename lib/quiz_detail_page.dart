import 'package:flutter/material.dart';
import 'quiz_model.dart';
import 'navigation/back_navigation_handler.dart';

class QuizDetailPage extends StatefulWidget {
  final Quiz quiz;

  QuizDetailPage({required this.quiz});

  @override
  _QuizDetailPageState createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  Map<int, String> selectedAnswers = {};

  void _showResult() {
    if (selectedAnswers.length < widget.quiz.questions.length) {
      print("Selected Answers: $selectedAnswers");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please answer all questions!")),
      );
      return;
    }

    Map<String, int> answerCount = {};

    // Count occurrences of each answer type (A, B, C, D)
    for (var answer in selectedAnswers.values) {
      String answerType = answer
          .substring(0, 1)
          .toUpperCase(); // Extract first letter (A, B, C, D)
      answerCount[answerType] = (answerCount[answerType] ?? 0) + 1;
    }

    // Debugging prints
    print("Selected Answers: $selectedAnswers");
    print("Answer Count: $answerCount");

    // Sort answer count to determine the most selected category
    List<MapEntry<String, int>> sortedEntries = answerCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Sort in descending order

    String highestCategory = sortedEntries.first.key; // Most chosen category

    print("Most Selected: $highestCategory");

    // Ensure a valid result exists
    if (!widget.quiz.results.containsKey(highestCategory)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected error! No result found.")),
      );
      return;
    }

    QuizResult result = widget.quiz.results[highestCategory]!;

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
    return BackNavigationHandler(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.quiz.title, style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF70C2BD),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
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
                          groupValue: selectedAnswers[index] ??
                              "", // Ensure it's initialized
                          activeColor: Color(0xFF1DCFCA),
                          onChanged: (value) {
                            setState(() {
                              selectedAnswers[index] = value ??
                                  ""; // Assign only to current question
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
      ),
    );
  }
}
