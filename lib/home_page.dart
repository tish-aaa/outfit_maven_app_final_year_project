import 'package:flutter/material.dart';
import 'login_page.dart'; // Import the login screen
import 'contact_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Map<String, String>> posts = [
    {
      "imageUrl": "https://images.unsplash.com/photo-1519999482648-25049ddd37b1",
      "caption": "Casual Street Style",
    },
    {
      "imageUrl": "https://images.unsplash.com/photo-1542223616-787c38359942",
      "caption": "Classic Formal Outfit",
    },
    {
      "imageUrl": "https://images.unsplash.com/photo-1503342217505-b0a15ec3261c",
      "caption": "Elegant Evening Wear",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade100,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.blueGrey),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Center(
          child: Image.network(
            'https://via.placeholder.com/120x40.png?text=Outfit+Maven',
            height: 40,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.blueGrey),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade200),
              child: Center(
                child: Image.network(
                  'https://via.placeholder.com/150.png?text=Outfit+Maven',
                  height: 80,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blueGrey),
              title: const Text('Home'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag, color: Colors.blueGrey),
              title: const Text('Outfits'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.blueGrey),
              title: const Text('Liked Inspo'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail, color: Colors.blueGrey),
              title: const Text('Contact'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ContactPage()));
              },
            ),
          ],
        ),
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade200),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_circle, size: 80, color: Colors.white),
                    SizedBox(height: 10),
                    Text("User Profile", style: TextStyle(color: Colors.white, fontSize: 20)),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blueGrey),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.blueGrey),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostCard(
            imageUrl: posts[index]["imageUrl"]!,
            caption: posts[index]["caption"]!,
          );
        },
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final String imageUrl;
  final String caption;

  const PostCard({required this.imageUrl, required this.caption, Key? key})
      : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      color: Colors.blue.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              widget.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              widget.caption,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isLiked = !isLiked;
                        });
                      },
                    ),
                    const SizedBox(width: 4),
                    const Text("Like"),
                  ],
                ),
                TextButton.icon(
                  icon: const Icon(Icons.comment),
                  label: const Text("Comment"),
                  onPressed: () {
                    // Comment functionality
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
