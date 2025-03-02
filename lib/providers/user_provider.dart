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
  Set<String> _likedPosts = {}; // Track liked posts in real-time

  String get userId => _userId.isNotEmpty ? _userId : 'unknown_user';
  String get username => _username.isNotEmpty ? _username : 'Unknown User';
  String get profileImageUrl =>
      _profileImageUrl.isNotEmpty ? _profileImageUrl : defaultProfileImage;
  Set<String> get likedPosts => _likedPosts;

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
        _userId = user.uid;
        _listenToUserData();
        _listenToLikedPosts();
      } else {
        _resetUserData();
      }
    });
  }

  void _resetUserData() {
    _userId = '';
    _username = 'Unknown User';
    _profileImageUrl = defaultProfileImage;
    _likedPosts.clear();
    notifyListeners(); // Notify when the user logs out and data resets
  }

  void _listenToUserData() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final newUsername = data['username'] ?? 'Unknown User';
        final newProfileImageUrl =
            data['profileImageUrl'] ?? defaultProfileImage;

        // Debugging line: Print the profile image URL
        print("Profile image URL: $newProfileImageUrl");

        if (_username != newUsername ||
            _profileImageUrl != newProfileImageUrl) {
          _username = newUsername;
          _profileImageUrl = newProfileImageUrl;
          notifyListeners(); // Only notify when actual changes occur
        }
      }
    });
  }

  void _listenToLikedPosts() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('likedPosts')
        .snapshots()
        .listen((snapshot) {
      final newLikedPosts = snapshot.docs.map((doc) => doc.id).toSet();
      print("Liked posts: $newLikedPosts"); // Debugging line
      if (_likedPosts != newLikedPosts) {
        _likedPosts = newLikedPosts;
        notifyListeners();
      }
    });
  }

  Future<void> toggleLike(String postId) async {
    final likeRef = FirebaseFirestore.instance
        .collection('outfits')
        .doc(postId)
        .collection('likes')
        .doc(_userId);

    if (_likedPosts.contains(postId)) {
      await likeRef.delete();
      _likedPosts.remove(postId); // Remove from local set
    } else {
      await likeRef.set({'likedAt': FieldValue.serverTimestamp()});
      _likedPosts.add(postId); // Add to local set
    }
    notifyListeners();
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
    if (_userId.isNotEmpty && _profileImageUrl != newImageUrl) {
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'profileImageUrl': newImageUrl,
      });
      _profileImageUrl = newImageUrl; // Update locally and notify listeners
      notifyListeners();
    }
  }
}
