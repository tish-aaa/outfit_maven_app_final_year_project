import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_card.dart';
import 'navbar.dart';

class HomePage extends StatefulWidget {
  final String userId;
  final String userName;
  final String profileImageUrl;

  const HomePage({
    super.key,
    required this.userId,
    required this.userName,
    required this.profileImageUrl,
  });

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
      drawer: CustomDrawer(
        userId: widget.userId, 
        userName: widget.userName, 
        profileImageUrl: widget.profileImageUrl,
      ),
      endDrawer: CustomEndDrawer(
        userName: widget.userName,
        profileImageUrl: widget.profileImageUrl,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
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
                  !data.containsKey('caption')) {
                return const SizedBox.shrink(); // Skip invalid posts
              }

              return PostCard(
                postId: data['postId'],
                imageUrl: data['imageUrl'],
                caption: data['caption'],
                userId: widget.userId,
                userName: widget.userName, // Pass userName if needed
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
