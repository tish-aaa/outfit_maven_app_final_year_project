import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'home_page.dart';

class OutfitQuizPage extends StatefulWidget {
  @override
  _OutfitQuizPageState createState() => _OutfitQuizPageState();
}

class _OutfitQuizPageState extends State<OutfitQuizPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help You Figure Quizzes'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade200,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              duration: Duration(milliseconds: 500),
              child: Text(
                'Pick a quiz to discover your fashion insights!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 20),
            _buildAnimatedQuizTile(
                context,
                'Personal Style Quiz',
                'Discover your fashion aesthetic',
                Icons.style,
                Colors.pink,
                PersonalStyleQuizPage()),
            _buildAnimatedQuizTile(
                context,
                'Body Shape Quiz',
                'Find the best cuts for you',
                Icons.account_circle,
                Colors.blue,
                BodyShapeQuizPage()),
            _buildAnimatedQuizTile(
                context,
                'Accessory Quiz',
                'Which accessories match your style?',
                Icons.watch,
                Colors.green,
                AccessoryQuizPage()),
            _buildAnimatedQuizTile(
                context,
                'Color Palette Quiz',
                'Find the perfect colors for your skin tone',
                Icons.color_lens,
                Colors.orange,
                ColorPaletteQuizPage()),
            _buildAnimatedQuizTile(
                context,
                'Occasion-Based Outfit Quiz',
                'What to wear for different occasions?',
                Icons.event,
                Colors.purple,
                OccasionQuizPage()),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedQuizTile(BuildContext context, String title,
      String subtitle, IconData icon, Color color, Widget page) {
    return GestureDetector(
      onTap: () {
        try {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error opening quiz: $e")),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Hero(
          tag: title,
          child: FadeInLeft(
            duration: Duration(milliseconds: 600),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        SizedBox(height: 4),
                        Text(subtitle,
                            style:
                                TextStyle(fontSize: 14, color: Colors.white70)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================== QUIZ PAGES ===================
class PersonalStyleQuizPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildQuizScreen(
      context,
      'Personal Style Quiz',
      Colors.pink.shade200,
      'Which fashion style do you like most?',
      [
        'Casual & Comfy',
        'Chic & Elegant',
        'Streetwear & Trendy',
        'Classic & Timeless'
      ],
    );
  }
}

class BodyShapeQuizPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildQuizScreen(
      context,
      'Body Shape Quiz',
      Colors.blue.shade200,
      'Which body shape resembles yours the most?',
      ['Hourglass', 'Pear', 'Rectangle', 'Inverted Triangle'],
    );
  }
}

class AccessoryQuizPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildQuizScreen(
      context,
      'Accessory Quiz',
      Colors.green.shade200,
      'Which accessory do you wear the most?',
      ['Watches', 'Necklaces', 'Rings', 'Bracelets'],
    );
  }
}

class ColorPaletteQuizPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildQuizScreen(
      context,
      'Color Palette Quiz',
      Colors.orange.shade200,
      'What color group do you love wearing the most?',
      ['Warm Tones', 'Cool Tones', 'Neutrals', 'Bright Colors'],
    );
  }
}

class OccasionQuizPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildQuizScreen(
      context,
      'Occasion-Based Outfit Quiz',
      Colors.purple.shade200,
      'What’s your go-to outfit for a night out?',
      [
        'Elegant Dress',
        'Casual Jeans & Tee',
        'Trendy Blazer Look',
        'Athleisure'
      ],
    );
  }
}

// Common Quiz UI
Widget _buildQuizScreen(BuildContext context, String title, Color color,
    String question, List<String> options) {
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      backgroundColor: color,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Cannot go back further!")),
            );
          }
        },
      ),
    ),
    body: _buildQuizBody(question, options),
  );
}

Widget _buildQuizBody(String question, List<String> options) {
  String selectedOption = '';

  return StatefulBuilder(
    builder: (context, setState) {
      return Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ...options.map((option) => RadioListTile(
                  title: Text(option),
                  value: option,
                  groupValue: selectedOption,
                  onChanged: (value) =>
                      setState(() => selectedOption = value.toString()),
                )),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedOption.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('You chose: $selectedOption')),
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      );
    },
  );
}
