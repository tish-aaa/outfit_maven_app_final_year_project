import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'navbar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, String>> posts = [
    {
      "id": "1",
      "imageUrl": "https://images.unsplash.com/photo-1519999482648-25049ddd37b1",
      "caption": "Casual Street Style",
    },
    {
      "id": "2",
      "imageUrl": "https://images.unsplash.com/photo-1542223616-787c38359942",
      "caption": "Classic Formal Outfit",
    },
    {
      "id": "3",
      "imageUrl": "https://images.unsplash.com/photo-1503342217505-b0a15ec3261c",
      "caption": "Elegant Evening Wear",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: CustomDrawer(),
      endDrawer: CustomEndDrawer(),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostCard(
            postId: posts[index]["id"]!,
            imageUrl: posts[index]["imageUrl"]!,
            caption: posts[index]["caption"]!,
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

  const PostCard({
    required this.postId,
    required this.imageUrl,
    required this.caption,
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
        .doc(widget.postId)
        .snapshots()
        .listen((doc) {
      setState(() {
        isLiked = doc.exists;
      });
    });
  }

  void toggleLike() async {
    setState(() {
      isLiked = !isLiked;
    });

    if (isLiked) {
      await FirebaseFirestore.instance.collection('liked_posts').doc(widget.postId).set({
        'imageUrl': widget.imageUrl,
        'caption': widget.caption,
      });
    } else {
      await FirebaseFirestore.instance.collection('liked_posts').doc(widget.postId).delete();
    }
  }

  void addComment() {
    String comment = _commentController.text.trim();
    if (comment.isNotEmpty) {
      FirebaseFirestore.instance.collection('comments').doc(widget.postId).collection('postComments').add({
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
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightBlue.shade50, Colors.lightBlue.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('comments').doc(widget.postId).collection('postComments').orderBy('timestamp', descending: true).snapshots(),
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
                      title: Text(doc['comment'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blueGrey)),
                    ),
                  );
                }).toList(),
              );
            },
          ),
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
                icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.grey),
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
