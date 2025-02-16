import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'navbar.dart';

class HomePage extends StatefulWidget {
  final String? userId; // Make userId optional

  const HomePage({Key? key, this.userId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: CustomDrawer(userId: widget.userId ?? ''),  // Pass userId to drawer
      endDrawer: CustomEndDrawer(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No posts available."));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return PostCard(
                postId: doc.id,
                imageUrl: doc['imageUrl'],
                caption: doc['caption'],
                userId: widget.userId ?? '', // Pass userId here
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final String postId;
  final String imageUrl;
  final String caption;
  final String userId;

  const PostCard({
    required this.postId,
    required this.imageUrl,
    required this.caption,
    required this.userId,
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkIfLiked();
  }

  void checkIfLiked() async {
    FirebaseFirestore.instance
        .collection('liked_posts')
        .where('userId', isEqualTo: widget.userId)
        .where('postId', isEqualTo: widget.postId)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        isLiked = snapshot.docs.isNotEmpty;
      });
    });
  }

  void toggleLike() async {
  final likeRef = FirebaseFirestore.instance
      .collection('liked_posts')
      .doc(widget.userId + widget.postId);

  final likeSnapshot = await likeRef.get();

  if (likeSnapshot.exists) {
    await likeRef.delete();
    setState(() {
      isLiked = false;
    });
  } else {
    await likeRef.set({
      'userId': widget.userId,
      'postId': widget.postId,
      'imageUrl': widget.imageUrl,
      'caption': widget.caption,
      'timestamp': Timestamp.now(),
    });
    setState(() {
      isLiked = true;
    });
  }
}


  void addComment() {
    String comment = _commentController.text.trim();
    if (comment.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('comments')
          .doc(widget.postId)
          .collection('postComments')
          .add({
        'userId': widget.userId,
        'comment': comment,
        'timestamp': Timestamp.now(),
      });
      _commentController.clear();
    }
  }

  void showComments() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('comments')
              .doc(widget.postId)
              .collection('postComments')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
            return ListView(
              padding: EdgeInsets.all(10),
              children: snapshot.data!.docs.map((doc) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  color: Colors.white,
                  child: ListTile(
                    title: Text(doc['comment'],
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blueGrey)),
                    subtitle: Text("User: ${doc['userId']}",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          Image.network(widget.imageUrl, height: 250, fit: BoxFit.cover),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(widget.caption, style: TextStyle(fontSize: 16)),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey),
                onPressed: toggleLike,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade50, Colors.blue.shade100],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(hintText: "Add a comment...", border: InputBorder.none),
                        onSubmitted: (value) => addComment(),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.comment),
                onPressed: showComments,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
