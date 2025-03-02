import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'post_card.dart';
import 'navbar.dart';
import 'providers/user_provider.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _quotesController;
  List<Map<String, String>> fashionQuotes = [
    {"quote": "A statement belt can transform any outfit.", "author": "Victoria Beckham"},
    {"quote": "Style is a way to say who you are without having to speak.", "author": "Rachel Zoe"},
    {"quote": "Fashion is what you buy. Style is what you do with it.", "author": "Nina Garcia"},
    {"quote": "Clothes mean nothing until someone lives in them.", "author": "Marc Jacobs"},
    {"quote": "In order to be irreplaceable one must always be different.", "author": "Coco Chanel"},
  ];

  @override
  void initState() {
    super.initState();
    _quotesController = PageController(initialPage: 0);
    _startQuoteScroll();
  }

  void _startQuoteScroll() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (_quotesController.hasClients) {
        _quotesController.nextPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _quotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: CustomDrawer(),
      endDrawer: CustomEndDrawer(),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Color(0xFFE0F2F1),
              border: Border.all(color: Color(0xFF298A90), width: 2.0),
              borderRadius: BorderRadius.circular(80.0),
            ),
            margin: EdgeInsets.symmetric(vertical: 10.0),
            height: 150.0,
            width: 400,
            child: PageView.builder(
              controller: _quotesController,
              itemCount: fashionQuotes.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('“', style: TextStyle(color: Color(0xFF298A90), fontSize: 40.0, fontWeight: FontWeight.bold)),
                        SizedBox(width: 5.0),
                        Expanded(
                          child: Text(
                            fashionQuotes[index]["quote"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF298A90), fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 5.0),
                        Text('”', style: TextStyle(color: Color(0xFF298A90), fontSize: 40.0, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      fashionQuotes[index]["author"]!,
                      style: TextStyle(color: Color(0xFF298A90), fontSize: 16.0, fontStyle: FontStyle.italic),
                    ),
                  ],
                );
              },
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('outfits')
                .where('isPrivate', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No posts available."));
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>?;

                  if (data == null ||
                      !data.containsKey('postId') ||
                      !data.containsKey('imageUrl') ||
                      !data.containsKey('description') ||
                      !data.containsKey('userId')) {
                    return const SizedBox.shrink();
                  }

                  return OutfitPost(
                    postId: data['postId'],
                    imageUrl: data['imageUrl'],
                    description: data['description'],
                    userId: data['userId'],
                    userName: userProvider.username,
                    profileImageUrl: userProvider.profileImageUrl,
                    isPrivate: data['isPrivate'] ?? false,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
