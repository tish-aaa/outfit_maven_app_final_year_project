class Quiz {
  final String title;
  final String image; // ✅ Renamed from 'image' to 'image'
  final List<Question> questions;
  final Map<String, QuizResult> results;

  Quiz({
    required this.title,
    required this.image, // ✅ Uses jpeg file instead of an image
    required this.questions,
    required this.results,
  });
}

class QuizResult {
  final String image; // ✅ Keep this as 'image' for JPEG results
  final String description;

  QuizResult({required this.image, required this.description});
}

class Question {
  final String questionText;
  final List<String> options;

  Question({required this.questionText, required this.options});
}

// 🔥 Mood-Based Quiz - Updated with full questions & results
List<Quiz> quizzes = [
  Quiz(
    title: "Mood-Based Quiz",
    image: "assets/quiz/mood_quiz.jpeg",
    questions: [
      Question(
        questionText: "How are you feeling today?",
        options: [
          "Happy & Energetic",
          "Calm & Relaxed",
          "Moody & Introspective",
          "Confident & Bold"
        ],
      ),
      Question(
        questionText: "What’s the weather like outside?",
        options: [
          "Sunny & Warm",
          "Cool & Breezy",
          "Rainy & Cloudy",
          "Chilly & Cold"
        ],
      ),
      Question(
        questionText: "What’s your current vibe?",
        options: [
          "Casual & Laid-back",
          "Chic & Classy",
          "Edgy & Unique",
          "Cozy & Comfortable"
        ],
      ),
      Question(
        questionText: "How social do you feel today?",
        options: ["Super social", "A little social", "Not much", "Staying in"],
      ),
      Question(
        questionText: "What colors are you drawn to today?",
        options: [
          "Bright & Playful",
          "Soft & Neutral",
          "Dark & Mysterious",
          "Earthy & Muted"
        ],
      ),
      Question(
        questionText: "What’s your ideal activity for today?",
        options: [
          "Fun day out",
          "Cozy café or art museum",
          "Listening to music or journaling",
          "Watching movies or gaming"
        ],
      ),
      Question(
        questionText: "What type of shoes would you prefer today?",
        options: [
          "Sneakers",
          "Boots",
          "Heels or Dressy Shoes",
          "Slippers or Comfy Flats"
        ],
      ),
      Question(
        questionText: "What’s your preferred fabric right now?",
        options: [
          "Light & Breathable",
          "Soft & Flowy",
          "Structured & Strong",
          "Warm & Cozy"
        ],
      ),
      Question(
        questionText:
            "How much effort do you want to put into your look today?",
        options: ["Quick & Easy", "Well-Styled", "Statement-Making", "Minimal"],
      ),
      Question(
        questionText: "What’s your go-to accessory today?",
        options: [
          "Sunglasses & Fun Jewelry",
          "A Classy Handbag",
          "A Bold Necklace",
          "A Cozy Scarf"
        ],
      ),
      Question(
        questionText:
            "If you had to pick a fashion aesthetic for today, what would it be?",
        options: ["Sporty Chic", "Soft & Elegant", "Dark & Edgy", "Cozy Core"],
      ),
    ],
    results: {
      "A": QuizResult(
          image: "assets/quiz_results/energetic_playful.jpeg",
          description:
              "🌟 Energetic & Playful\nA bright-colored crop top with high-waisted jeans or a tennis skirt.\nSneakers or stylish platform sandals.\nFun sunglasses & bold statement earrings.\nA sporty, laid-back aesthetic."),
      "B": QuizResult(
          image: "assets/quiz_results/calm_elegant.jpeg",
          description:
              "🌿 Calm & Elegant\nFlowy dresses or chic blouses with neutral tones.\nSoft fabric like satin or chiffon.\nDelicate jewelry and a classy handbag.\nBallet flats or elegant boots for a polished look."),
      "C": QuizResult(
          image: "assets/quiz_results/edgy_moody.jpeg",
          description:
              "🌧️ Edgy & Moody\nBlack or dark-colored outfits with layering.\nLeather jackets, ripped jeans, or oversized sweaters.\nChunky boots or platform shoes.\nBold accessories like silver rings or statement necklaces."),
      "D": QuizResult(
          image: "assets/quiz_results/cozy_minimal.jpeg",
          description:
              "🔥 Cozy & Minimalist\nOversized hoodies or warm knits with leggings or wide-leg pants.\nComfy sneakers, fluffy slippers, or simple flats.\nBeanies, scarves, or cozy accessories.\nA relaxed and effortless vibe."),
    },
  ),
  Quiz(
    title: "Occasion-Based Quiz",
    image: "assets/quiz/occasion_quiz.jpeg",
    questions: [
      Question(
        questionText: "Where are you going?",
        options: ["Casual Outing", "Work", "Party", "Gym"],
      ),
    ],
    results: {
      "A": QuizResult(
          image: "assets/quiz_results/energetic_playful.jpeg",
          description:
              "🌟 Energetic & Playful\nA bright-colored crop top with high-waisted jeans or a tennis skirt.\nSneakers or stylish platform sandals.\nFun sunglasses & bold statement earrings.\nA sporty, laid-back aesthetic."),
      "B": QuizResult(
          image: "assets/quiz_results/calm_elegant.jpeg",
          description:
              "🌿 Calm & Elegant\nFlowy dresses or chic blouses with neutral tones.\nSoft fabric like satin or chiffon.\nDelicate jewelry and a classy handbag.\nBallet flats or elegant boots for a polished look."),
      "C": QuizResult(
          image: "assets/quiz_results/edgy_moody.jpeg",
          description:
              "🌧️ Edgy & Moody\nBlack or dark-colored outfits with layering.\nLeather jackets, ripped jeans, or oversized sweaters.\nChunky boots or platform shoes.\nBold accessories like silver rings or statement necklaces."),
      "D": QuizResult(
          image: "assets/quiz_results/cozy_minimal.jpeg",
          description:
              "🔥 Cozy & Minimalist\nOversized hoodies or warm knits with leggings or wide-leg pants.\nComfy sneakers, fluffy slippers, or simple flats.\nBeanies, scarves, or cozy accessories.\nA relaxed and effortless vibe."),
    },
  ),
  Quiz(
    title: "Weather-Based Quiz",
    image: "assets/quiz/weather_quiz.jpeg",
    questions: [
      Question(
        questionText: "What's the weather like today?",
        options: ["Sunny", "Rainy", "Cold", "Windy"],
      ),
    ],
    results: {
      "A": QuizResult(
          image: "assets/quiz_results/energetic_playful.jpeg",
          description:
              "🌟 Energetic & Playful\nA bright-colored crop top with high-waisted jeans or a tennis skirt.\nSneakers or stylish platform sandals.\nFun sunglasses & bold statement earrings.\nA sporty, laid-back aesthetic."),
      "B": QuizResult(
          image: "assets/quiz_results/calm_elegant.jpeg",
          description:
              "🌿 Calm & Elegant\nFlowy dresses or chic blouses with neutral tones.\nSoft fabric like satin or chiffon.\nDelicate jewelry and a classy handbag.\nBallet flats or elegant boots for a polished look."),
      "C": QuizResult(
          image: "assets/quiz_results/edgy_moody.jpeg",
          description:
              "🌧️ Edgy & Moody\nBlack or dark-colored outfits with layering.\nLeather jackets, ripped jeans, or oversized sweaters.\nChunky boots or platform shoes.\nBold accessories like silver rings or statement necklaces."),
      "D": QuizResult(
          image: "assets/quiz_results/cozy_minimal.jpeg",
          description:
              "🔥 Cozy & Minimalist\nOversized hoodies or warm knits with leggings or wide-leg pants.\nComfy sneakers, fluffy slippers, or simple flats.\nBeanies, scarves, or cozy accessories.\nA relaxed and effortless vibe."),
    },
  ),
];
