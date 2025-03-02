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
  List<String> fashionQuotes = [
    "Fashion is the armor to survive the reality of everyday life.",
    "Style is a way to say who you are without having to speak.",
    "Fashion is what you buy. Style is what you do with it.",
    "Clothes mean nothing until someone lives in them.",
    "In order to be irreplaceable one must always be different."
  ];

  @override
  void initState() {
    super.initState();
    _quotesController = PageController(initialPage: 0);
    _startQuoteScroll();
  }

  // Function to auto-scroll the quotes
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
      body: Column(
        children: [
          // Fashion Quotes Carousel
          Container(
            height: 50.0,
            color: Color(0xFF70C2BD),
            child: PageView.builder(
              controller: _quotesController,
              itemCount: fashionQuotes.length,
              itemBuilder: (context, index) {
                return Center(
                  child: Text(
                    fashionQuotes[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              },
            ),
          ),
          // Main Post Feed
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('outfits')
                  .where('isPrivate', isEqualTo: false)  // Only public posts
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No posts available."));
                }

                return ListView(
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
          ),
        ],
      ),
    );
  }
}
