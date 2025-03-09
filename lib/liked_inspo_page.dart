import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'navbar.dart';
import 'post_card.dart';
import 'providers/user_provider.dart';
import 'navigation/back_navigation_handler.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import for image caching

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

    return BackNavigationHandler(
      child: Scaffold(
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
                    return const Center(
                        child: Text("No liked posts available."));
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      if (data['isPrivate'] ?? false) return const SizedBox.shrink();

                      return GestureDetector(
                        onTap: () {
                          _showExpandedImage(context, data['imageUrl'] ?? '');
                        },
                        child: OutfitPost(
                          postId: data['postId'] ?? '',
                          imageUrl: data['imageUrl'] ?? '',
                          description: data['description'] ?? '',
                          userId: data['userId'] ?? '',
                          userName: data['userName'] ?? 'Unknown',
                          profileImageUrl: data['profileImageUrl'] ?? '',
                          isPrivate: data['isPrivate'] ?? false,
                          forSale: data['forSale'] ?? false,
                          price: (data['price'] ?? 0.0).toDouble(),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
      ),
    );
  }

  void _showExpandedImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
