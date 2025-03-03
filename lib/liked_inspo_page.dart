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
    final likedPosts = userProvider.likedPosts;

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: CustomDrawer(),
      endDrawer: CustomEndDrawer(),
      body: likedPosts.isEmpty
          ? const Center(child: Text("No liked posts yet."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('outfits')
                  .where(FieldPath.documentId,
                      whereIn: likedPosts.isNotEmpty ? likedPosts : ['dummy'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No liked posts available."));
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    if (data['isPrivate'] ?? false)
                      return const SizedBox.shrink();

                    return OutfitPost(
                      postId: data['postId'] ?? '', // Default to empty string
                      imageUrl: data['imageUrl'] ?? '', // Prevent null errors
                      description:
                          data['description'] ?? '', // Default to empty string
                      userId: data['userId'] ?? '', // Default to empty string
                      userName: data['userName'] ?? 'Unknown', // Fallback name
                      profileImageUrl:
                          data['profileImageUrl'] ?? '', // Prevent null errors
                      isPrivate: data['isPrivate'] ?? false, // Default to false
                      forSale: data['forSale'] ?? false, // Default to false
                      price: (data['price'] ?? 0.0)
                          .toDouble(), // Ensure numeric type
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
