import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  static const String defaultProfileImage = 'assets/defaultprofile.png'; 

  String _userId = '';
  String _username = 'Unknown User';
  String _profileImageUrl = defaultProfileImage;

  String get userId => _userId;
  String get username => _username;
  String get profileImageUrl => _profileImageUrl;

  UserProvider() {
    fetchUserData(); // Automatically fetch user data when provider is initialized
  }

  void updateUser({required String id, required String name, required String imageUrl}) {
    _userId = id;
    _username = name;
    _profileImageUrl = imageUrl.isNotEmpty ? imageUrl : defaultProfileImage;
    notifyListeners();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        updateUser(
          id: user.uid,
          name: userData['username'] ?? 'Unknown User',
          imageUrl: userData['profileImageUrl'] ?? '',
        );
      }
    }
  }

  void updateProfileImage(String newImageUrl) {
    _profileImageUrl = newImageUrl.isNotEmpty ? newImageUrl : defaultProfileImage;
    notifyListeners();
  }
}
