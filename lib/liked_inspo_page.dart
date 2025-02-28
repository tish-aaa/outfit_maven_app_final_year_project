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

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: CustomDrawer(),
      endDrawer: CustomEndDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('liked_posts')
            .where('userId', isEqualTo: userId)
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
              if (data == null || !data.containsKey('postId')) {
                return const SizedBox.shrink();
              }

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('outfits')
                    .doc(data['postId'])
                    .snapshots(),
                builder: (context, postSnapshot) {
                  if (!postSnapshot.hasData || !postSnapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }

                  final postData = postSnapshot.data!.data() as Map<String, dynamic>;

                  return OutfitPost(
                    postId: postData['postId'],
                    imageUrl: postData['imageUrl'],
                    description: postData['description'],
                    userId: postData['userId'],
                    userName: postData['userName'] ?? "Unknown",
                    profileImageUrl: postData['profileImageUrl'] ?? UserProvider.defaultProfileImage,
                    isPrivate: postData['isPrivate'] ?? false,
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