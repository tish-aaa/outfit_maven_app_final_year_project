import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'navbar.dart';
import 'post_card.dart';

class LikedInspoPage extends StatefulWidget {
  final String userId;

  const LikedInspoPage({required this.userId});

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
      drawer: CustomDrawer(userId: widget.userId),
      endDrawer: CustomEndDrawer(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('liked_posts')
            .where('userId', isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No liked posts yet."));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return PostCard(
                postId: doc['postId'],
                imageUrl: doc['imageUrl'],
                caption: doc['caption'],
                userId: widget.userId,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
