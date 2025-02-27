class Quiz {
  final String title;
  final List<Question> questions;

  Quiz({required this.title, required this.questions});
}

class Question {
  final String questionText;
  final List<String> options;

  Question({required this.questionText, required this.options});
}

// 🔥 List of all quizzes
List<Quiz> quizzes = [
  Quiz(
    title: "Mood-Based Quiz",
    questions: [
      Question(
        questionText: "How do you feel today?",
        options: ["Happy", "Confident", "Relaxed", "Energetic"],
      ),
      Question(
        questionText: "What’s your go-to comfort wear?",
        options: ["Jeans & T-shirt", "Dresses", "Sweatpants", "Blazer & Pants"],
      ),
    ],
  ),
  Quiz(
    title: "Occasion-Based Quiz",
    questions: [
      Question(
        questionText: "Where are you going?",
        options: ["Casual Outing", "Work", "Party", "Gym"],
      ),
    ],
  ),
  Quiz(
    title: "Weather-Based Quiz",
    questions: [
      Question(
        questionText: "What's the weather like today?",
        options: ["Sunny", "Rainy", "Cold", "Windy"],
      ),
    ],
  ),
];
