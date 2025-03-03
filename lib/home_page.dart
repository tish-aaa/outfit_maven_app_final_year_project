import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'post_card.dart';
import 'navbar.dart';
import 'providers/user_provider.dart';
import 'cart_page.dart'; // Create this new page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _quotesController;
  late Timer _quoteTimer;
  int cartItemCount = 0;

  final List<Map<String, String>> fashionQuotes = [
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
    _fetchCartCount();
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

  void _fetchCartCount() {
    FirebaseFirestore.instance.collection('cart').snapshots().listen((snapshot) {
      setState(() {
        cartItemCount = snapshot.docs.length;
      });
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
      body: Stack(
        children: [
          ListView(
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
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
                          Text("\"${fashionQuotes[index]['quote']}\"", 
                              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10.0),
                          Text("- ${fashionQuotes[index]['author']}", 
                              style: const TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic)),
                        ],
                      );
                    },
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('outfits').where('isPrivate', isEqualTo: false).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No posts available."));
                  }
                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return OutfitPost(
                        postId: data['postId'],
                        imageUrl: data['imageUrl'],
                        description: data['description'],
                        userId: data['userId'],
                        userName: data['userName'],
                        profileImageUrl: data['profileImageUrl'],
                        isPrivate: data['isPrivate'],
                        isSelling: data['isSelling'] ?? false,
                        price: data['price'] ?? 0.0, 
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => CartPage(),
                    transitionsBuilder: (_, animation, __, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                  ),
                );
              },
              backgroundColor: const Color(0xFF70C2BD),
              child: Stack(
                children: [
                  const Icon(Icons.shopping_cart, size: 30, color: Colors.white),
                  if (cartItemCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$cartItemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
