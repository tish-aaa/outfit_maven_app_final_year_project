import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserProvider with ChangeNotifier {
  static const String defaultProfileImage = 'assets/defaultprofile.png';

  Set<String> userCart = {}; // Store item IDs in the cart
  String _userId = '';
  String _username = 'Unknown User';
  String _profileImageUrl = defaultProfileImage;
  Set<String> _likedPosts = {}; // Track liked posts in real-time
  List<Map<String, dynamic>> _cartItems = []; // Track cart items in real-time
  Set<String> _purchasedItems = {}; // Track purchased items in real-time
  Map<String, Map<String, dynamic>> _cartDetails = {};
  Map<String, Map<String, dynamic>> get cartDetails => _cartDetails;

  String get userId => _userId.isNotEmpty ? _userId : 'unknown_user';
  String get username => _username.isNotEmpty ? _username : 'Unknown User';
  String get profileImageUrl =>
      _profileImageUrl.isNotEmpty ? _profileImageUrl : defaultProfileImage;
  Set<String> get likedPosts => _likedPosts;
  List<Map<String, dynamic>> get cartItems => _cartItems;

  Set<String> get purchasedItems => _purchasedItems;

  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'dzj8zymjz',
    'outfit_pics',
    cache: true,
  );

  Map<String, Map<String, dynamic>> _postDetails = {};
  Map<String, Map<String, dynamic>> get postDetails => _postDetails;

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
        _listenToPostChanges();
        _listenToCartChanges();
        _listenToPurchasedItems();
      } else {
        _resetUserData();
      }
    });
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

  void _resetUserData() {
    _userId = '';
    _username = 'Unknown User';
    _profileImageUrl = defaultProfileImage;
    _likedPosts.clear();
    _cartItems.clear();
    _purchasedItems.clear();
    notifyListeners();
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

        if (_username != newUsername ||
            _profileImageUrl != newProfileImageUrl) {
          _username = newUsername;
          _profileImageUrl = newProfileImageUrl;
          notifyListeners();
        }
      }
    });
  }

  Future<void> toggleSellStatus(String postId, double price) async {
    final postRef =
        FirebaseFirestore.instance.collection('outfits').doc(postId);

    try {
      DocumentSnapshot postSnapshot = await postRef.get();

      if (postSnapshot.exists) {
        final data = postSnapshot.data() as Map<String, dynamic>;
        bool isCurrentlySelling = data['isSelling'] ?? false;

        if (isCurrentlySelling) {
          // Prevent removing from selling as per your requirement
          print("This outfit is already marked for sale and cannot be undone.");
        } else {
          await postRef.update({
            'isSelling': true,
            'price': price,
          });

          _postDetails[postId]?['isSelling'] = true;
          _postDetails[postId]?['price'] = price;
          notifyListeners();
        }
      }
    } catch (e) {
      print("Error toggling sell status: $e");
    }
  }

  void _listenToPostChanges() {
    FirebaseFirestore.instance
        .collection('outfits')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final postId = doc.id;
        final bool newIsSelling = data['isSelling'] ?? false;
        if (newIsSelling) {
          data['isPrivate'] = false; // Ensure selling posts aren't private
        }

        final double newPrice = (data['price'] ?? 0).toDouble();
        final bool newIsPrivate = data['isPrivate'] ?? false;

        _postDetails[postId] = {
          'isSelling': newIsSelling,
          'price': newPrice,
          'isPrivate': newIsPrivate,
        };
      }
      notifyListeners();
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
      if (_likedPosts != newLikedPosts) {
        _likedPosts = newLikedPosts;
        notifyListeners();
      }
    });
  }

  Future<void> storeOrder() async {
    if (userId == null) return; // Ensure user is logged in

    if (cartItems.isEmpty) return; // No need to proceed if cart is empty

    try {
      // Create an order document
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': userId,
        'items': cartItems,
        'totalAmount': cartItems.fold(
            0.0, (sum, item) => sum + ((item['price'] as num?) ?? 0.0)),
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear cart after placing the order
      cartItems.clear();
      notifyListeners();
    } catch (e) {
      debugPrint("Error storing order: $e");
    }
  }

  void _listenToCartChanges() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('cart')
        .snapshots()
        .listen((snapshot) async {
      List<Map<String, dynamic>> newCartItems = [];

      Map<String, Map<String, dynamic>> newCartDetails = {};

      for (var doc in snapshot.docs) {
        final postId = doc.id;
        final data = doc.data()
            as Map<String, dynamic>; // Ensure data is retrieved properly

        newCartItems.add({
          'postId': postId,
          'price': data['price'] ?? 0.0,
          'imageUrl': data['imageUrl'] ?? '',
          'title': data['title'] ?? 'Unknown Item',
        });

        // Fetch outfit details
        DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
            .collection('outfits')
            .doc(postId)
            .get();

        if (postSnapshot.exists) {
          newCartDetails[postId] = postSnapshot.data() as Map<String, dynamic>;
        }
      }

      if (_cartItems != newCartItems) {
        _cartItems = newCartItems;
        _cartDetails = newCartDetails;
        notifyListeners();
      }
    });
  }

  void removeFromCart(String postId) {
    _cartItems.removeWhere((item) => item['postId'] == postId);
    notifyListeners();
  }

  List<Map<String, dynamic>> get orderDetails => _cartItems.map((item) {
        return {
          'postId': item['postId'],
          'price': item['price'],
          'imageUrl': item['imageUrl'],
          'title': item['title'],
          'timestamp': FieldValue.serverTimestamp(),
        };
      }).toList();

  Future<void> togglePrivacyStatus(String postId) async {
    final postRef =
        FirebaseFirestore.instance.collection('outfits').doc(postId);

    try {
      DocumentSnapshot postSnapshot = await postRef.get();

      if (postSnapshot.exists) {
        final data = postSnapshot.data() as Map<String, dynamic>;
        bool isCurrentlyPrivate = data['isPrivate'] ?? false;

        if (isCurrentlyPrivate) {
          // Prevent reverting to public
          print(
              "This outfit is already private and cannot be made public again.");
        } else {
          await postRef.update({
            'isPrivate': true,
          });

          _postDetails[postId]?['isPrivate'] = true;
          notifyListeners();
        }
      }
    } catch (e) {
      print("Error toggling privacy status: $e");
    }
  }

  Future<void> clearCart() async {
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('cart');

    // Delete all cart items from Firestore
    var batch = FirebaseFirestore.instance.batch();
    for (var item in _cartItems) {
      batch.delete(cartRef.doc(item['postId']));
    }
    await batch.commit();

    _cartItems.clear();
    notifyListeners();
  }

  void _listenToPurchasedItems() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('purchases')
        .snapshots()
        .listen((snapshot) {
      final newPurchasedItems = snapshot.docs.map((doc) => doc.id).toSet();
      if (_purchasedItems != newPurchasedItems) {
        _purchasedItems = newPurchasedItems;
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
      _likedPosts.remove(postId);
    } else {
      await likeRef.set({'likedAt': FieldValue.serverTimestamp()});
      _likedPosts.add(postId);
    }
    notifyListeners();
  }

  Future<void> toggleCartItem(Map<String, dynamic> item) async {
    final postId = item['postId'];
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('cart')
        .doc(postId);

    final existingIndex =
        _cartItems.indexWhere((cartItem) => cartItem['postId'] == postId);

    if (existingIndex != -1) {
      // Remove item from cart
      await cartRef.delete();
      _cartItems.removeAt(existingIndex);
    } else {
      // Add item with full details
      await cartRef.set({
        'addedAt': FieldValue.serverTimestamp(),
        'price': item['price'],
        'imageUrl': item['imageUrl'],
        'title': item['title'],
      });

      _cartItems.add(item);
    }
    notifyListeners();
  }

  Future<void> updateProfileImage(String newImageUrl) async {
    if (_userId.isNotEmpty && _profileImageUrl != newImageUrl) {
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'profileImageUrl': newImageUrl,
      });
      _profileImageUrl = newImageUrl;
      notifyListeners();
    }
  }
}
