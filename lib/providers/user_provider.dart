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
  List<Map<String, dynamic>> _ordersHistory = [];
  List<Map<String, dynamic>> get ordersHistory => _ordersHistory;
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
        _listenToOrdersHistory();
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
        bool isCurrentlySelling = data['forSale'] ?? false;

        if (isCurrentlySelling) {
          // Prevent removing from selling as per your requirement
          print("This outfit is already marked for sale and cannot be undone.");
        } else {
          await postRef.update({
            'forSale': true,
            'price': price,
          });

          _postDetails[postId]?['forSale'] = true;
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
        final String imageUrl = data['imageUrl'] ?? '';
        final String description =
            data['description'] ?? 'No description available';
        final bool newForSale = data['forSale'] ?? false; // Corrected field
        final double newPrice = (data['price'] ?? 0).toDouble();
        final bool newIsPrivate = data['isPrivate'] ?? false;

        _postDetails[postId] = {
          'imageUrl': imageUrl ?? '', // Prevent null errors
          'description': description ?? 'Outfit', // Default to empty string
          'forSale': newForSale ?? false, // Default to false if null
          'price': newPrice ?? 0, // Default to 0 if price is missing
          'isPrivate': newIsPrivate ?? false, // Default to false
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
      // Create an order document with an auto-generated ID
      final orderRef =
          await FirebaseFirestore.instance.collection('orders').add({
        'userId': userId,
        'items': cartItems,
        'totalAmount': cartItems.fold(
            0.0, (sum, item) => sum + ((item['price'] as num?) ?? 0.0)),
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Processing', // Default status
      });

      // Fetch the generated order ID
      final orderId = orderRef.id;

      // Update locally in ordersHistory
      final newOrder = {
        'id': orderId,
        'items': List<Map<String, dynamic>>.from(cartItems),
        'totalAmount': cartItems.fold(
            0.0, (sum, item) => sum + ((item['price'] as num?) ?? 0.0)),
        'timestamp': DateTime.now().toString(),
        'status': 'Processing',
      };

      _ordersHistory.insert(0, newOrder); // Add the new order at the top
      cartItems.clear(); // Clear cart after placing order
      notifyListeners();
    } catch (e) {
      debugPrint("Error storing order: $e");
    }
  }

  void _listenToOrdersHistory() {
    FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .listen((snapshot) {
      _ordersHistory = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'items': List<Map<String, dynamic>>.from(data['items'] ?? []),
          'totalAmount': (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
          'timestamp': data['timestamp'] ?? '',
          'status': data['status'] ?? 'Processing',
        };
      }).toList();

      notifyListeners();
    });
  }

  Future<void> addToCart(
      String postId, double? price, String imageUrl, String description) async {
    if (_userId.isEmpty) return; // Ensure user is logged in

    if (price == null) {
      print("Error: Cannot add item with null price");
      return;
    }

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('cart')
        .doc(postId); // Keep the same postId to track quantity

    try {
      final docSnapshot = await cartRef.get();

      if (docSnapshot.exists) {
        // If item already exists, increase quantity
        await cartRef.update({
          'quantity': FieldValue.increment(1),
        });

        // Update local state
        final index = _cartItems.indexWhere((item) => item['postId'] == postId);
        if (index != -1) {
          _cartItems[index]['quantity'] =
              (_cartItems[index]['quantity'] as int) + 1;
        }
      } else {
        // If item does not exist, add with quantity = 1
        await cartRef.set({
          'postId': postId,
          'price': price ?? 0.0, // ✅ Convert price to double
          'imageUrl': imageUrl,
          'description': description,
          'quantity': 1, // ✅ Ensure quantity is int
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Update local state
        _cartItems.add({
          'postId': postId,
          'price': price,
          'imageUrl': imageUrl,
          'description': description,
          'quantity': 1,
        });
      }

      notifyListeners();
    } catch (e) {
      print("Error adding to cart: $e");
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
        final data = doc.data();

        newCartItems.add({
          'postId': postId,
          'price': (data['price'] is num)
              ? (data['price'] as num).toDouble()
              : 0.0, // ✅ Ensures double
          'imageUrl': data['imageUrl'] ?? '',
          'description': data['description'] ?? 'Unknown Item',
          'quantity': (data['quantity'] as num?)?.toInt() ??
              1, // ✅ Ensure quantity is int
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

      _cartItems = newCartItems;
      _cartDetails = newCartDetails;
      notifyListeners();
    });
  }

  Future<void> updateCartItem(String postId, bool addToCart,
      {double? price, String? imageUrl, String? description}) async {
    if (_userId.isEmpty) return; // Ensure user is logged in

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('cart')
        .doc(postId);

    try {
      if (addToCart) {
        // Add item to cart
        await cartRef.set({
          'postId': postId,
          'price': price ?? 0.0,
          'imageUrl': imageUrl ?? '',
          'description': description ?? 'No description available',
          'timestamp': FieldValue.serverTimestamp(),
        });

        _cartItems.add({
          'postId': postId,
          'price': price,
          'imageUrl': imageUrl,
          'description': description,
        });
      } else {
        // Remove item from cart
        await cartRef.delete();
        _cartItems.removeWhere((item) => item['postId'] == postId);
      }

      notifyListeners();
    } catch (e) {
      print("Error updating cart: $e");
    }
  }

  Future<void> removeFromCart(String postId) async {
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('cart')
        .doc(postId);

    try {
      // Get current item data
      final docSnapshot = await cartRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        int currentQuantity = data['quantity'] ?? 1;

        if (currentQuantity > 1) {
          // Decrease quantity if more than 1
          await cartRef.update({'quantity': FieldValue.increment(-1)});

          // Update local state
          final index =
              _cartItems.indexWhere((item) => item['postId'] == postId);
          if (index != -1) {
            _cartItems[index]['quantity'] = currentQuantity - 1;
          }
        } else {
          // Remove item completely if quantity is 1
          await cartRef.delete();
          _cartItems.removeWhere((item) => item['postId'] == postId);
        }

        notifyListeners();
      }
    } catch (e) {
      print("Error removing from cart: $e");
    }
  }

  List<Map<String, dynamic>> get orderDetails => _cartItems.map((item) {
        return {
          'postId': item['postId'],
          'price': item['price'],
          'imageUrl': item['imageUrl'],
          'description': item['description'],
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
        'description': item['description'],
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
