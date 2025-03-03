import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'post_card.dart';
import 'navbar.dart';
import 'providers/user_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _quotesController;
  late Timer _quoteTimer;

  final List<Map<String, String>> fashionQuotes = [
    {
      "quote": "A statement belt can transform any outfit.",
      "author": "Victoria Beckham"
    },
    {
      "quote": "Style is a way to say who you are without having to speak.",
      "author": "Rachel Zoe"
    },
    {
      "quote": "Fashion is what you buy. Style is what you do with it.",
      "author": "Nina Garcia"
    },
    {
      "quote": "Clothes mean nothing until someone lives in them.",
      "author": "Marc Jacobs"
    },
    {
      "quote": "In order to be irreplaceable one must always be different.",
      "author": "Coco Chanel"
    },
  ];

  @override
  void initState() {
    super.initState();
    _quotesController = PageController(initialPage: 0);
    _startQuoteScroll();
  }

  void _startQuoteScroll() {
    _quoteTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_quotesController.hasClients) {
        int nextPage = _quotesController.page!.toInt() + 1;
        if (nextPage >= fashionQuotes.length) {
          _quotesController.jumpToPage(0);
        } else {
          _quotesController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _quoteTimer.cancel();
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
          // Fashion Quotes Section
          Center(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade100, // Matches your theme
                border: Border.all(color: const Color(0xFF298A90), width: 2.0),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 5.0,
                      spreadRadius: 2.0),
                ],
              ),
              width: 320,
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              height: 150.0,
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
                          const Text(
                            '“',
                            style: TextStyle(
                              color: Color(0xFF298A90),
                              fontSize: 40.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          SizedBox(
                            width: 200,
                            child: Text(
                              fashionQuotes[index]["quote"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF298A90),
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          const Text(
                            '”',
                            style: TextStyle(
                              color: Color(0xFF298A90),
                              fontSize: 40.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        "- ${fashionQuotes[index]["author"]!}",
                        style: const TextStyle(
                          color: Color(0xFF298A90),
                          fontSize: 16.0,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Outfit Posts Section
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

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(data['userId'])
                        .get(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                        return const SizedBox
                            .shrink(); // Skip post if user data is missing
                      }

                      final userData =
                          userSnapshot.data!.data() as Map<String, dynamic>?;

                      return OutfitPost(
                        postId: data['postId'],
                        imageUrl: data['imageUrl'],
                        description: data['description'],
                        userId: data['userId'],
                        userName: userData?['username'] ?? "Unknown User",
                        profileImageUrl: userData?['profileImageUrl'] ??
                            "assets/defaultprofile.jpg",
                        isPrivate: data['isPrivate'] ?? false,
                      );
                    },
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}
