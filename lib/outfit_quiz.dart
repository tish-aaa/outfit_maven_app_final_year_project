import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class OutfitQuizPage extends StatefulWidget {
  @override
  _OutfitQuizPageState createState() => _OutfitQuizPageState();
}

class _OutfitQuizPageState extends State<OutfitQuizPage> {
  String mood = '';
  String occasion = '';
  String color = '';
  String weather = '';

  // Pie chart data
  List<PieChartSectionData> showingSections = [
    PieChartSectionData(value: 25, color: Colors.yellow, title: 'Happy'),
    PieChartSectionData(value: 25, color: Colors.blue, title: 'Casual'),
    PieChartSectionData(value: 25, color: Colors.red, title: 'Bright Color'),
    PieChartSectionData(value: 25, color: Colors.green, title: 'Sunny'),
  ];

  String recommendedOutfit = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('What to Wear Today?')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz Questions
            Text('How do you feel today?', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            _buildMoodQuestion(),
            SizedBox(height: 20),
            Text('What is the occasion?', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            _buildOccasionQuestion(),
            SizedBox(height: 20),
            Text('Any color preferences?', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            _buildColorQuestion(),
            SizedBox(height: 20),
            Text('What\'s the weather like?', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            _buildWeatherQuestion(),
            SizedBox(height: 20),

            // Button to calculate result
            ElevatedButton(
              onPressed: _calculateOutfit,
              child: Text('Get Outfit Recommendation'),
            ),
            SizedBox(height: 20),

            // Outfit Recommendation
            if (recommendedOutfit.isNotEmpty) ...[
              Text('Recommended Outfit: $recommendedOutfit', style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              Text('Mood and Occasion Pie Chart', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              _buildPieChart(),
            ],
          ],
        ),
      ),
    );
  }

  // Widgets for the questions
  Widget _buildMoodQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile(
          value: 'Happy',
          groupValue: mood,
          onChanged: (value) {
            setState(() {
              mood = value!;
            });
          },
          title: Text('Happy'),
        ),
        RadioListTile(
          value: 'Confident',
          groupValue: mood,
          onChanged: (value) {
            setState(() {
              mood = value!;
            });
          },
          title: Text('Confident'),
        ),
        RadioListTile(
          value: 'Relaxed',
          groupValue: mood,
          onChanged: (value) {
            setState(() {
              mood = value!;
            });
          },
          title: Text('Relaxed'),
        ),
      ],
    );
  }

  Widget _buildOccasionQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile(
          value: 'Casual',
          groupValue: occasion,
          onChanged: (value) {
            setState(() {
              occasion = value!;
            });
          },
          title: Text('Casual'),
        ),
        RadioListTile(
          value: 'Work',
          groupValue: occasion,
          onChanged: (value) {
            setState(() {
              occasion = value!;
            });
          },
          title: Text('Work'),
        ),
        RadioListTile(
          value: 'Party',
          groupValue: occasion,
          onChanged: (value) {
            setState(() {
              occasion = value!;
            });
          },
          title: Text('Party'),
        ),
      ],
    );
  }

  Widget _buildColorQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile(
          value: 'Black',
          groupValue: color,
          onChanged: (value) {
            setState(() {
              color = value!;
            });
          },
          title: Text('Black'),
        ),
        RadioListTile(
          value: 'White',
          groupValue: color,
          onChanged: (value) {
            setState(() {
              color = value!;
            });
          },
          title: Text('White'),
        ),
        RadioListTile(
          value: 'Bright Colors',
          groupValue: color,
          onChanged: (value) {
            setState(() {
              color = value!;
            });
          },
          title: Text('Bright Colors'),
        ),
      ],
    );
  }

  Widget _buildWeatherQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile(
          value: 'Sunny',
          groupValue: weather,
          onChanged: (value) {
            setState(() {
              weather = value!;
            });
          },
          title: Text('Sunny'),
        ),
        RadioListTile(
          value: 'Rainy',
          groupValue: weather,
          onChanged: (value) {
            setState(() {
              weather = value!;
            });
          },
          title: Text('Rainy'),
        ),
        RadioListTile(
          value: 'Chilly',
          groupValue: weather,
          onChanged: (value) {
            setState(() {
              weather = value!;
            });
          },
          title: Text('Chilly'),
        ),
      ],
    );
  }

  // Function to calculate the outfit
  void _calculateOutfit() {
    setState(() {
      if (mood == 'Happy' && occasion == 'Casual') {
        recommendedOutfit = 'Casual Outfit: T-shirt and jeans';
      } else if (mood == 'Confident' && occasion == 'Party') {
        recommendedOutfit = 'Party Outfit: Stylish dress or suit';
      } else {
        recommendedOutfit = 'Default Outfit: Comfortable and casual';
      }
    });
  }

  // Pie Chart visualization
  Widget _buildPieChart() {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: showingSections,
          borderData: FlBorderData(show: false),
          sectionsSpace: 0,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: OutfitQuizPage(),
  ));
}
