import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'post_card.dart';
import 'outfit_page.dart';

class MyOutfitsPage extends StatefulWidget {
  @override
  _MyOutfitsPageState createState() => _MyOutfitsPageState();
}

class _MyOutfitsPageState extends State<MyOutfitsPage> {
  int _currentLayout = 2;

  final List<IconData> _layoutIcons = [
    Icons.grid_on,
    Icons.grid_view,
    Icons.view_comfy,
    Icons.list,
  ];

  Future<void> _refreshPosts() async {
    setState(() {});
  }

  void _openAddOutfitDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OutfitPage(postId: null)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Outfits'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_layoutIcons[_currentLayout]),
            onPressed: () {
              setState(() {
                _currentLayout = (_currentLayout + 1) % _layoutIcons.length;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('outfits')
            .where('userId', isEqualTo: userProvider.userId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Colors.blue.shade100));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No outfits added yet."));
          }

          var posts = snapshot.data!.docs;

          return RefreshIndicator(
            onRefresh: _refreshPosts,
            color: Colors.blue.shade100,
            child: Column(
              children: [
                Expanded(
                  child: _currentLayout == 3
                      ? ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            var post =
                                posts[index].data() as Map<String, dynamic>;

                            return FutureBuilder<Map<String, String>>(
                              future: userProvider.getUserInfo(post['userId']),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox.shrink();
                                }

                                final userInfo = userSnapshot.data ??
                                    {
                                      "username": "Unknown User",
                                      "profileImageUrl":
                                          UserProvider.defaultProfileImage,
                                    };

                                return OutfitPost(
                                  postId: post['postId'],
                                  imageUrl: post['imageUrl'],
                                  description: post['description'],
                                  userId: post['userId'],
                                  userName: userInfo["username"]!,
                                  profileImageUrl: userInfo["profileImageUrl"]!,
                                  isPrivate: post['isPrivate'] ?? false,
                                );
                              },
                            );
                          },
                        )
                      : GridView.builder(
                          padding: EdgeInsets.all(8.0),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _currentLayout == 0
                                ? 3
                                : _currentLayout == 1
                                    ? 2
                                    : 1,
                            childAspectRatio: _currentLayout == 1 ? 1 : 0.8,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            var post =
                                posts[index].data() as Map<String, dynamic>;

                            return FutureBuilder<Map<String, String>>(
                              future: userProvider.getUserInfo(post['userId']),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox.shrink();
                                }

                                final userInfo = userSnapshot.data ??
                                    {
                                      "username": "Unknown User",
                                      "profileImageUrl":
                                          UserProvider.defaultProfileImage,
                                    };

                                return OutfitPost(
                                  postId: post['postId'],
                                  imageUrl: post['imageUrl'],
                                  description: post['description'],
                                  userId: post['userId'],
                                  userName: userInfo["username"]!,
                                  profileImageUrl: userInfo["profileImageUrl"]!,
                                  isPrivate: post['isPrivate'] ?? false,
                                );
                              },
                            );
                          },
                        ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.add, size: 30),
                        onPressed: _openAddOutfitDialog,
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, size: 30),
                        onPressed: () {
                          // Edit functionality
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, size: 30),
                        onPressed: () {
                          // Delete functionality with confirmation
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
