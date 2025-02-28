import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String commentId;
  final String postId;
  final String userId;
  final String username;
  final String profileImageUrl;
  final String text;
  final Timestamp timestamp;

  Comment({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.username,
    required this.profileImageUrl,
    required this.text,
    required this.timestamp,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      commentId: doc.id,
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Unknown User',
      profileImageUrl: data['profileImageUrl'] ?? 'assets/defaultprofile.png',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'text': text,
      'timestamp': timestamp,
    };
  }
}
