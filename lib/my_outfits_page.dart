import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'providers/user_provider.dart';
import 'selectable_post.dart';
import 'outfit_page.dart';
import 'home_page.dart';
import 'navigation/back_navigation_handler.dart'; 

class MyOutfitsPage extends StatefulWidget {
  @override
  _MyOutfitsPageState createState() => _MyOutfitsPageState();
}

class _MyOutfitsPageState extends State<MyOutfitsPage> {
  int _currentLayout = 3;
  final List<IconData> _layoutIcons = [
    Icons.list, 
    Icons.grid_on, // 1x1
    Icons.grid_view, // 2x2
    Icons.view_comfy, // 3x3
  ];
  Set<String> _selectedPosts = {};
  bool _isSelecting = false;

  Future<void> _refreshPosts() async {
    setState(() {});
  }

  void _toggleSelect(String postId) {
    setState(() {
      if (_selectedPosts.contains(postId)) {
        _selectedPosts.remove(postId);
      } else {
        _selectedPosts.add(postId);
      }
      _isSelecting = _selectedPosts.isNotEmpty;
    });
  }

  void _editSelectedOutfit() {
    if (_selectedPosts.length == 1) {
      String postId = _selectedPosts.first;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OutfitPage(postId: postId)),
      ).then((_) => setState(() => _selectedPosts.clear()));
    }
  }

  void _confirmDelete() {
    if (_selectedPosts.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Outfits"),
        content: Text(
            "Are you sure you want to delete ${_selectedPosts.length} selected outfits? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              for (String postId in _selectedPosts) {
                await FirebaseFirestore.instance
                    .collection('outfits')
                    .doc(postId)
                    .delete();
              }
              setState(() {
                _selectedPosts.clear();
                _isSelecting = false;
              });
              Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
    return BackNavigationHandler(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF70C2BD),
          title: Text('My Outfits',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
          actions: [
            IconButton(
              icon: Icon(
                _layoutIcons[_currentLayout],
                color: Colors.white,
              ),
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
                  child:
                      CircularProgressIndicator(color: Colors.blue.shade100));
            }
            if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
              return Center(child: Text("No outfits available."));
            }

            var posts = snapshot.data!.docs;

            return RefreshIndicator(
              onRefresh: _refreshPosts,
              color: Colors.blue.shade100,
              child: _currentLayout == 3
                  ? ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        var post =
                            posts[index].data() as Map<String, dynamic>? ?? {};
                        return Card(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: SelectablePost(
                              postId: post['postId'] ?? '',
                              imageUrl: post['imageUrl'] ?? '',
                              description:
                                  post['description'] ?? 'No description',
                              userId: post['userId'] ?? '',
                              userName: userProvider.username,
                              title: post['title'] ?? 'Untitled',
                              profileImageUrl: userProvider.profileImageUrl,
                              isPrivate: post['isPrivate'] ?? false,
                              isSelected:
                                  _selectedPosts.contains(post['postId']),
                              onSelect: _toggleSelect,
                              forSale: post['forSale'] ?? false, // Added
                              price: (post['price'] ?? 0).toDouble(), // Added
                            ),
                          ),
                        );
                      },
                    )
                  : MasonryGridView.count(
                      padding: EdgeInsets.all(8),
                      crossAxisCount: _currentLayout == 0
                          ? 3
                          : _currentLayout == 1
                              ? 2
                              : 1,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        var post =
                            posts[index].data() as Map<String, dynamic>? ?? {};
                        return SelectablePost(
                          postId: post['postId'] ?? '',
                          imageUrl: post['imageUrl'] ?? '',
                          description: post['description'] ?? 'No description',
                          userId: post['userId'] ?? '',
                          userName: userProvider.username,
                          title: post['title'] ?? 'Untitled',
                          profileImageUrl: userProvider.profileImageUrl,
                          isPrivate: post['isPrivate'] ?? false,
                          isSelected: _selectedPosts.contains(post['postId']),
                          onSelect: _toggleSelect,
                          forSale: post['forSale'] ?? false, // Added
                          price: (post['price'] ?? 0).toDouble(), // Added
                        );
                      },
                    ),
            );
          },
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          shape: CircularNotchedRectangle(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.add, size: 30),
                  onPressed: _openAddOutfitDialog,
                ),
                IconButton(
                  icon: Icon(Icons.edit, size: 30),
                  onPressed:
                      _selectedPosts.length == 1 ? _editSelectedOutfit : null,
                ),
                IconButton(
                  icon: Icon(Icons.delete,
                      size: 30,
                      color: _selectedPosts.isNotEmpty ? Colors.red : null),
                  onPressed: _selectedPosts.isNotEmpty ? _confirmDelete : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
