import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _userId = '';
  String _username = 'Unknown User';
  String _profileImageUrl = '';

  static const String defaultProfileImage = 'assets/defaultprofile.png'; 

  String get userId => _userId;
  String get username => _username;
  String get profileImageUrl => _profileImageUrl.isNotEmpty ? _profileImageUrl : defaultProfileImage;

  void setUser(String id, String name, String imageUrl) {
    _userId = id;
    _username = name;
    _profileImageUrl = imageUrl;
    notifyListeners();
  }
}
