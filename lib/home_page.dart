import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'post_card.dart';
import 'navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String userId = '';
  String userName = 'Unknown User';
  String profileImageUrl = '';

  // Default profile image
  final String defaultProfileImage = 'https://example.com/default_profile_image.png';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
        setState(() {
          userName = userData?['userName'] ?? 'Unknown User';
          profileImageUrl = userData?['profileImageUrl'] ?? defaultProfileImage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: CustomDrawer(
        userId: userId,
        userName: userName,
        profileImageUrl: profileImageUrl.isNotEmpty ? profileImageUrl : defaultProfileImage,
      ),
      endDrawer: CustomEndDrawer(
        userName: userName,
        profileImageUrl: profileImageUrl.isNotEmpty ? profileImageUrl : defaultProfileImage,
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
                  String profileImage = defaultProfileImage;
                  String fetchedUserName = "Unknown User";

                  if (userSnapshot.connectionState == ConnectionState.done && 
                      userSnapshot.data != null &&
                      userSnapshot.data!.data() != null) {
                    Map<String, dynamic> userData = 
                        userSnapshot.data!.data() as Map<String, dynamic>;

                    profileImage = userData['profileImageUrl'] ?? defaultProfileImage;
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
