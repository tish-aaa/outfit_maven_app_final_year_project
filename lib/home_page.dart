import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'post_card.dart';
import 'navbar.dart';
import 'providers/user_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    String userId = userProvider.userId;
    String userName = userProvider.username;
    String profileImageUrl = userProvider.profileImageUrl;

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: CustomDrawer(),
      endDrawer: CustomEndDrawer(),
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
                  !data.containsKey('caption') ||
                  !data.containsKey('userId')) {
                return const SizedBox.shrink();
              }

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(data['userId'])
                    .get(),
                builder: (context, userSnapshot) {
                  String profileImage =
                      UserProvider.defaultProfileImage;
                  String fetchedUserName = "Unknown User";

                  if (userSnapshot.connectionState == ConnectionState.done &&
                      userSnapshot.data != null &&
                      userSnapshot.data!.data() != null) {
                    Map<String, dynamic> userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;

                    profileImage = userData['profileImageUrl'] ??
                        UserProvider.defaultProfileImage;
                    fetchedUserName = userData['userName'] ?? "Unknown User";
                  }

                  return PostCard(
                    postId: data['postId'],
                    imageUrl: data['imageUrl'],
                    caption: data['caption'],
                    userId: data['userId'],
                    userName: fetchedUserName,
                    profileImageUrl: profileImage,
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
