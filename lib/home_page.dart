import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_card.dart';
import 'navbar.dart';

class HomePage extends StatefulWidget {
  final String? userId;

  const HomePage({Key? key, this.userId}) : super(key: key);

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
      drawer: CustomDrawer(userId: widget.userId ?? ''),
      endDrawer: CustomEndDrawer(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return Center(child: Text("No posts available."));

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return PostCard(
                postId: doc.id,
                imageUrl: doc['imageUrl'],
                caption: doc['caption'],
                userId: widget.userId ?? '',
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
