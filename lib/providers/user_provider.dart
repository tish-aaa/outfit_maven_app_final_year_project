import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserProvider with ChangeNotifier {
  static const String defaultProfileImage = 'assets/defaultprofile.png';

  String _userId = '';
  String _username = 'Unknown User';
  String _profileImageUrl = defaultProfileImage;

  String get userId => _userId.isNotEmpty ? _userId : 'unknown_user';
  String get username => _username.isNotEmpty ? _username : 'Unknown User';
  String get profileImageUrl => _profileImageUrl.isNotEmpty ? _profileImageUrl : defaultProfileImage;

  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'dzj8zymjz',
    'outfit_pics',
    cache: true,
  );

  final ImagePicker _picker = ImagePicker();

  UserProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        fetchUserData();
      } else {
        _resetUserData();
      }
    });
  }

  void _resetUserData() {
    _userId = '';
    _username = 'Unknown User';
    _profileImageUrl = defaultProfileImage;
    notifyListeners();
  }

  void updateUser(
      {required String id, required String name, required String imageUrl}) {
    _userId = id.isNotEmpty ? id : 'unknown_user';
    _username = name.isNotEmpty ? name : 'Unknown User';
    _profileImageUrl = imageUrl.isNotEmpty ? imageUrl : defaultProfileImage;
    notifyListeners();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
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

  Future<Map<String, String>> getUserInfo(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final Map<String, dynamic> data =
            userDoc.data() as Map<String, dynamic>;

        return {
          'username': data['username']?.toString() ?? 'Unknown User',
          'profileImageUrl': data['profileImageUrl']?.toString() ?? defaultProfileImage,
        };
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
    return {
      'username': 'Unknown User',
      'profileImageUrl': defaultProfileImage,
    };
  }

  Future<String?> uploadImageToCloudinary() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        String uniqueFileName =
            "profile_${_userId}_${DateTime.now().millisecondsSinceEpoch}";

        CloudinaryResponse response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(image.path,
              resourceType: CloudinaryResourceType.Image,
              publicId: uniqueFileName),
        );

        return response.secureUrl;
      } catch (e) {
        print("Error uploading image to Cloudinary: $e");
        return null;
      }
    }
    return null;
  }

  Future<void> updateProfileImage(String newImageUrl) async {
    if (_userId.isNotEmpty) {
      _profileImageUrl =
          newImageUrl.isNotEmpty ? newImageUrl : defaultProfileImage;
      notifyListeners();

      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'profileImageUrl': _profileImageUrl,
      });
    }
  }
}
