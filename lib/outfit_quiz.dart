import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'home_page.dart';
import 'quiz_model.dart';
import 'quiz_detail_page.dart';
import 'navigation/back_navigation_handler.dart'; 

IconData _getIconFromName(String iconName) {
  switch (iconName) {
    case 'mood':
      return Icons.mood;
    case 'event':
      return Icons.event;
    case 'wb_sunny':
      return Icons.wb_sunny;
    case 'checkroom':
      return Icons.checkroom; // If applicable
    case 'diamond':
      return Icons.diamond; // If applicable
    default:
      return Icons.style; // Default icon if not found
  }
}

class OutfitQuizPage extends StatelessWidget {
  final Color primaryColor = Color(0xFF70C2BD); // Main theme color
  final Color accentColor = Color(0xFF1DCFCA); // Navbar color
  final Color bgColor = Color(0xFFECF8F8); // Light background

  @override
  Widget build(BuildContext context) {
    return BackNavigationHandler(
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text('Fashion Quizzes',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          centerTitle: true,
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: ListView(
            children: [
              FadeInDown(
                duration: Duration(milliseconds: 500),
                child: Text(
                  '✨ Pick a quiz and unlock your fashion potential!',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
              ),
              SizedBox(height: 15),
              ...quizzes.map((quiz) => _buildQuizCard(context, quiz)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, Quiz quiz) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuizDetailPage(quiz: quiz)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Hero(
          tag: quiz.title,
          child: BounceInLeft(
            duration: Duration(milliseconds: 600),
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(_getIconFromName(quiz.iconName),
                      color: Colors.white, size: 34),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(quiz.title,
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        SizedBox(height: 4),
                        Text(quiz.titleDescription,
                            style:
                                TextStyle(fontSize: 17, color: Colors.white)),
                      ],
                    ),
                  ),
                  SizedBox(width: 12), // Add more space before the arrow
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
