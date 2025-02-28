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
  bool _expanded = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isPrivate = widget.isPrivate;
  }

  void _togglePrivacy(BuildContext context) async {
    if (!_isPrivate) {
      bool? confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Make Post Private"),
          content: Text("Once private, this post cannot be made public again. Continue?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Yes")),
          ],
        ),
      );
      if (confirm == true) {
        setState(() => _isPrivate = true);
        await FirebaseFirestore.instance.collection('outfits').doc(widget.postId).update({
          'isPrivate': true,
        });
      }
    }
  }

  void _addComment(BuildContext context, String comment) async {
    if (comment.isEmpty) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await FirebaseFirestore.instance
        .collection('outfits')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'userId': userProvider.userId,
      'username': userProvider.username,
      'profileImageUrl': userProvider.profileImageUrl,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isOwner = userProvider.userId == widget.userId;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.profileImageUrl),
            ),
            title: Text(widget.userName, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_isPrivate ? "Private Post" : "Public Post"),
            trailing: isOwner
                ? IconButton(
                    icon: Icon(Icons.lock, color: _isPrivate ? Colors.red : Colors.grey),
                    onPressed: () => _togglePrivacy(context),
                  )
                : null,
          ),
          FadeInImage.assetNetwork(
            placeholder: 'assets/loading_placeholder.jpg',
            image: widget.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.description,
                    maxLines: _expanded ? null : 1,
                    overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  ),
                  if (!_expanded)
                    Text("View More", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Divider(),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('outfits')
                .doc(widget.postId)
                .collection('comments')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              return Column(
                children: snapshot.data!.docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(data['profileImageUrl'] ?? ''),
                    ),
                    title: Text(data['username'] ?? 'Unknown User', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(data['comment'] ?? ''),
                  );
                }).toList(),
              );
            },
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
                  onPressed: () => _addComment(context, _commentController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
