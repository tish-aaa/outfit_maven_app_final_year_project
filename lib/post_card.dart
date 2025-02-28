import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class OutfitPost extends StatefulWidget {
  final String postId;
  final String userId;
  final String imageUrl;
  final String description;
  final String userName;
  final String profileImageUrl;
  final bool isPrivate;

  const OutfitPost({
    required this.postId,
    required this.userId,
    required this.imageUrl,
    required this.description,
    required this.userName,
    required this.profileImageUrl,
    required this.isPrivate,
  });

  @override
  _OutfitPostState createState() => _OutfitPostState();
}

class _OutfitPostState extends State<OutfitPost> {
  bool _isPrivate = false;
  bool _isLiked = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isPrivate = widget.isPrivate;
    _fetchLikeStatus();
  }

  void _fetchLikeStatus() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userProvider.userId)
        .collection('liked_posts')
        .doc(widget.postId)
        .get();
    setState(() => _isLiked = doc.exists);
  }

  void _toggleLike() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userRef = FirebaseFirestore.instance.collection('users').doc(userProvider.userId);
    final likedPostRef = userRef.collection('liked_posts').doc(widget.postId);
    
    setState(() => _isLiked = !_isLiked);
    if (_isLiked) {
      await likedPostRef.set({'postId': widget.postId});
    } else {
      await likedPostRef.delete();
    }
  }

  void _openComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.blue.shade200,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('outfits')
                      .doc(widget.postId)
                      .collection('comments')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    return ListView(
                      children: snapshot.data!.docs.map((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(data['profileImageUrl'] ?? ''),
                          ),
                          title: Text(data['username'] ?? 'Unknown User'),
                          subtitle: Text(data['comment'] ?? ''),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: "Write a comment...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.blue),
                      onPressed: () => _addComment(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addComment() async {
    if (_commentController.text.isEmpty) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await FirebaseFirestore.instance
        .collection('outfits')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'userId': userProvider.userId,
      'username': userProvider.username,
      'profileImageUrl': userProvider.profileImageUrl,
      'comment': _commentController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          FadeInImage.assetNetwork(
            placeholder: 'assets/loading_placeholder.jpg',
            image: widget.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 300, // 3/4 orientation
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              widget.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.grey),
                onPressed: _toggleLike,
              ),
              IconButton(
                icon: Icon(Icons.comment, color: Colors.blue),
                onPressed: _openComments,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
