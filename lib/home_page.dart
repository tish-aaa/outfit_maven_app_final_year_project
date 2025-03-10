import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'post_card.dart';
import 'navbar.dart';
import 'providers/user_provider.dart';
import 'cart_page.dart'; // Create this new page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class QuoteClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(
        size.width * 0.5, -20, size.width, size.height * 0.2);
    path.lineTo(size.width, size.height - 20);
    path.quadraticBezierTo(
        size.width * 0.5, size.height + 20, 0, size.height - 20);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class _HomePageState extends State<HomePage> {
  String? _expandedImageUrl;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _quotesController;
  late Timer _quoteTimer;
  int cartItemCount = 0;

  final List<Map<String, String>> fashionQuotes = [
    {
      "quote": "Fashion fades, only style remains the same.",
      "author": "Coco Chanel"
    },
    {
      "quote": "Fashions fade, style is eternal.",
      "author": "Yves Saint Laurent"
    },
    {
      "quote": "Trendy is the last stage before tacky.",
      "author": "Karl Lagerfeld"
    },
    {
      "quote":
          "Don’t be into trends. Don’t make fashion own you, but you decide what you are.",
      "author": "Gianni Versace"
    },
    {
      "quote":
          "I think there is beauty in everything. What ‘normal’ people perceive as ugly, I can usually see something of beauty in it.",
      "author": "Alexander McQueen"
    },
    {
      "quote": "Creativity comes from a conflict of ideas.",
      "author": "Donatella Versace"
    },
    {
      "quote":
          "Style is very personal. It has nothing to do with fashion. Fashion is over quickly. Style is forever.",
      "author": "Ralph Lauren"
    },
    {
      "quote": "Buy less, choose well, make it last.",
      "author": "Vivienne Westwood"
    },
    {"quote": "Dressing well is a form of good manners.", "author": "Tom Ford"},
    {
      "quote": "Elegance is the only beauty that never fades.",
      "author": "Audrey Hepburn"
    },
    {
      "quote": "Give a girl the right shoes, and she can conquer the world.",
      "author": "Marilyn Monroe"
    },
    {
      "quote": "She can beat me, but she cannot beat my outfit.",
      "author": "Rihanna"
    },
    {
      "quote": "The most beautiful thing you can wear is confidence.",
      "author": "Blake Lively"
    },
    {
      "quote": "Fashion is a great thing, it’s a way to express who you are.",
      "author": "Zendaya"
    },
    {
      "quote":
          "I like my money right where I can see it… hanging in my closet.",
      "author": "Sarah Jessica Parker"
    },
    {
      "quote":
          "Individuality means freedom. Fashion is what you adopt when you don’t know who you are.",
      "author": "Lady Gaga"
    },
    {"quote": "Honey, I always look good.", "author": "Kim Kardashian"},
    {
      "quote": "The most alluring thing a woman can have is confidence.",
      "author": "Beyoncé"
    },
    {"quote": "I can’t concentrate in flats.", "author": "Victoria Beckham"},
    {
      "quote": "I think that personality does affect your style.",
      "author": "Gigi Hadid"
    },
    {
      "quote": "Fashion is about fun and expression.",
      "author": "Kendall Jenner"
    },
    {
      "quote":
          "You can be a woman who wants to look good and still stand up for the equality of women.",
      "author": "Naomi Campbell"
    },
    {"quote": "Never complain, never explain.", "author": "Kate Moss"},
    {
      "quote":
          "Fashion and style are completely different things. Fashion is temporary, but style is forever.",
      "author": "Cindy Crawford"
    },
    {
      "quote":
          "The way you dress tells people who you are before you even say a word.",
      "author": "Hailey Bieber"
    },
    {
      "quote": "Dress for yourself. That’s all that matters.",
      "author": "Bella Hadid"
    },
    {
      "quote": "Style is a way to say who you are without having to speak.",
      "author": "Emily Ratajkowski"
    },
    {"quote": "Confidence makes everything look good.", "author": "Dua Lipa"},
    {
      "quote": "Wear your confidence like a crown and rock it!",
      "author": "Tyra Banks"
    },
    {
      "quote":
          "Fashion is a reflection of who you are. Dare to be different, and you’ll always be stylish.",
      "author": "Christian Dior"
    }
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
    FirebaseFirestore.instance
        .collection('cart')
        .snapshots()
        .listen((snapshot) {
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

  void _expandImage(String imageUrl) {
    if (imageUrl.isEmpty) return; // Prevent opening if URL is empty

    showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(), // Close on tap
          child: Container(
            color: Colors.black.withOpacity(0.8),
            alignment: Alignment.center,
            child: CachedNetworkImage(
              imageUrl: imageUrl, // Use parameter instead of _expandedImageUrl
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        );
      },
    );
  }

  void _closeExpandedImage() {
    setState(() {
      _expandedImageUrl = null;
    });
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
                  margin: const EdgeInsets.symmetric(vertical: 15.0),
                  child: ClipPath(
                    clipper: QuoteClipper(),
                    child: Container(
                      width: 320,
                      height: 220,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF70C2BD).withOpacity(0.8),
                            Color(0xFF1DCFCA).withOpacity(0.8)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8.0,
                            spreadRadius: 2.0,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: PageView.builder(
                        controller: _quotesController,
                        itemCount: fashionQuotes.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "“${fashionQuotes[index]['quote']}”",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        blurRadius: 3.0,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "- ${fashionQuotes[index]['author']}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('outfits')
                    .where('isPrivate',
                        isEqualTo: false) // Exclude private posts
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    print("No posts found!"); // Debugging
                    return const Center(child: Text("No posts available."));
                  }

                  print(
                      "Fetched ${snapshot.data!.docs.length} posts."); // Debugging

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>?;

                      if (data == null || !data.containsKey('imageUrl')) {
                        print("Invalid post data: ${doc.id}");
                        return SizedBox.shrink();
                      }

                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: CachedNetworkImage(
                                      imageUrl: data['imageUrl'] ??
                                          '', // ✅ Use imageUrl directly
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: OutfitPost(
                          postId: data['postId'] ?? '',
                          imageUrl: data['imageUrl'] ?? '',
                          description: data['description'] ?? '',
                          userId: data['userId'] ?? '',
                          userName: data['userName'] ?? 'Unknown',
                          profileImageUrl: data['profileImageUrl'] ?? '',
                          isPrivate: data['isPrivate'] ?? false,
                          forSale: data['forSale'] ??
                              data['forSale'] ??
                              false, // ✅ Ensure correct field
                          price: (data['price'] ?? 0.0).toDouble(),
                        ),
                      );
                    }).toList(),
                  );
                },
              )
            ],
          ),
          if (_expandedImageUrl != null)
            GestureDetector(
              onTap: _closeExpandedImage,
              child: Container(
                color: Colors.black.withOpacity(0.8),
                alignment: Alignment.center,
                child: Image.network(
                  _expandedImageUrl!,
                  fit: BoxFit.contain,
                ),
              ),
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
                  const Icon(Icons.shopping_cart,
                      size: 30, color: Colors.white),
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
