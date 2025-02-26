import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'navbar.dart';
import 'post_card.dart';

class LikedInspoPage extends StatefulWidget {
  final String userId;
  final String userName;
  final String profileImageUrl;

  const LikedInspoPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.profileImageUrl,
  });

  @override
  _LikedInspoPageState createState() => _LikedInspoPageState();
}

class _LikedInspoPageState extends State<LikedInspoPage> {
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
        stream: FirebaseFirestore.instance
            .collection('liked_posts')
            .where('userId', isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No liked posts yet."));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>?;

              if (data == null ||
                  !data.containsKey('postId') ||
                  !data.containsKey('imageUrl') ||
                  !data.containsKey('caption') ||
                  !data.containsKey('userId')) {
                return const SizedBox.shrink(); // Skip invalid data
              }

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(data['userId'])
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink(); // Show nothing while loading
                  }

                  final userData =
                      userSnapshot.data?.data() as Map<String, dynamic>?;

                  return PostCard(
                    postId: data['postId'],
                    imageUrl: data['imageUrl'],
                    caption: data['caption'],
                    userId: data['userId'],
                    userName: userData?['userName'] ?? 'Unknown User',
                    profileImageUrl: userData?['profileImageUrl'] ?? 'https://example.com/default_profile_image.png', // Ensure profile image is passed
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
