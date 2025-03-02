import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'navbar.dart';
import 'post_card.dart';
import 'providers/user_provider.dart';

class LikedInspoPage extends StatefulWidget {
  const LikedInspoPage({super.key});

  @override
  _LikedInspoPageState createState() => _LikedInspoPageState();
}

class _LikedInspoPageState extends State<LikedInspoPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    String userId = userProvider.userId;

    // Fetch liked posts from the user provider
    final likedPosts = userProvider.likedPosts;

    if (likedPosts.isEmpty) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
        drawer: CustomDrawer(),
        endDrawer: CustomEndDrawer(),
        body: const Center(child: Text("No liked posts yet.")),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: CustomDrawer(),
      endDrawer: CustomEndDrawer(),
      body: ListView.builder(
        itemCount: likedPosts.length,
        itemBuilder: (context, index) {
          final postId = likedPosts.elementAt(index);

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('outfits') // Fetching the actual outfit data
                .doc(postId) // Get outfit by postId
                .snapshots(),
            builder: (context, postSnapshot) {
              if (!postSnapshot.hasData || !postSnapshot.data!.exists) {
                return const SizedBox.shrink(); // If post does not exist, show empty
              }

              final postData = postSnapshot.data!.data() as Map<String, dynamic>;

              return OutfitPost(
                postId: postData['postId'],
                imageUrl: postData['imageUrl'],
                description: postData['description'],
                userId: postData['userId'],
                userName: postData['userName'] ?? "Unknown", // Use a default name if not present
                profileImageUrl: postData['profileImageUrl'] ?? UserProvider.defaultProfileImage, // Use default profile image if not present
                isPrivate: postData['isPrivate'] ?? false, // Check if post is private
              );
            },
          );
        },
      ),
    );
  }
}
