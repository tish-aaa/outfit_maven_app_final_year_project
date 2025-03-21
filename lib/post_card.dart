import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/user_provider.dart';
import 'package:shimmer/shimmer.dart';

class OutfitPost extends StatefulWidget {
  final String postId;
  final String userId;
  final String imageUrl;
  final String description;
  final String userName;
  final String profileImageUrl;
  final bool isPrivate;
  final bool forSale;
  final double? price;

  const OutfitPost({
    required this.postId,
    required this.userId,
    required this.imageUrl,
    required this.description,
    required this.userName,
    required this.profileImageUrl,
    required this.isPrivate,
    required this.forSale,
    this.price,
  });

  @override
  _OutfitPostState createState() => _OutfitPostState();
}

class _OutfitPostState extends State<OutfitPost> {
  bool _isPrivate = false;
  bool _isLiked = false;
  int _likeCount = 0;
  int _cartCount = 0;
  double? _price;
  TextEditingController _commentController = TextEditingController();

  // Track live username and profile updates
  String _username = "";
  String _profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    _isPrivate = widget.isPrivate;
    _price = widget.price;
    _username = widget.userName;
    _profileImageUrl = widget.profileImageUrl;

    _fetchLikeCount();
    _fetchLikeStatus();
    _listenForPriceUpdates();
    _listenForProfileUpdates();
  }

  void _listenForProfileUpdates() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.userId == widget.userId) {
      setState(() {
        _username = userProvider.username;
        _profileImageUrl = userProvider.profileImageUrl;
      });
    }
  }

  void _fetchLikeStatus() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _isLiked = userProvider.likedPosts.contains(widget.postId);
    });
  }

  void _fetchLikeCount() {
    FirebaseFirestore.instance
        .collection('outfits')
        .doc(widget.postId)
        .collection('likes')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() => _likeCount = snapshot.docs.length);
      }
    });
  }

  void _listenForPriceUpdates() {
    if (widget.forSale) {
      FirebaseFirestore.instance
          .collection('outfits')
          .doc(widget.postId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && mounted) {
          setState(() {
            _price = snapshot.data()?['price'];
          });
        }
      });
    }
  }

  void _toggleLike() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.toggleLike(widget.postId);
    _fetchLikeStatus();
  }

  void _openComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFFB3E5E1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        maxLines: 1, // Limit to 1 line of text
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Write a comment...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF298A90)),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Color(0xFF298A90)),
                      onPressed: _addComment,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('outfits')
                      .doc(widget.postId)
                      .collection('comments')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return ListView(
                      children: snapshot.data!.docs.map((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                                data['profileImageUrl'] ??
                                    'assets/defaultprofile.png'),
                          ),
                          title: Text(
                            data['username'] ?? 'Unknown User',
                            style: TextStyle(
                              color: Color(0xFF298A90),
                              fontWeight:
                                  FontWeight.bold, // Make username bolder
                            ),
                          ),
                          subtitle: Text(
                            data['comment'] ?? '',
                            style: TextStyle(color: Color(0xFF298A90)),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addComment() async {
    if (_commentController.text.isEmpty) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await FirebaseFirestore.instance
        .collection('outfits')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'userId': userProvider.userId,
      'username': userProvider.username,
      'profileImageUrl': userProvider.profileImageUrl,
      'comment': _commentController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _commentController.clear();
  }

  void _addToCart() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.addToCart(
        widget.postId, // Post ID
        widget.price, // Price (ensure it's a double)
        widget.imageUrl, // Image URL
        widget.description // description
        );

    setState(() {
      _cartCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFFE0F2F1),
      child: Column(
        children: [
          Container(
            color: Color(0xFFB3E5E1),
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    _profileImageUrl.isNotEmpty
                        ? _profileImageUrl
                        : 'assets/defaultprofile.png',
                  ),
                ),
                SizedBox(width: 10),
                Text(_username, style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                if (widget.isPrivate)
                  Icon(Icons.lock, color: Colors.red, size: 20),
              ],
            ),
          ),
          CachedNetworkImage(
            imageUrl: widget.imageUrl,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                  color: Colors.grey, height: 300, width: double.infinity),
            ),
            fit: BoxFit.cover,
            width: double.infinity,
            height: 300,
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(widget.description,
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 11.0),
                    child: Text(
                      _likeCount.toString(),
                      style: TextStyle(
                        color: Color(0xFF298A90),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: Color(0xFF298A90),
                    ),
                    onPressed: _toggleLike,
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.comment, color: Color(0xFF298A90)),
                onPressed: _openComments,
              ),
            ],
          ),

// ✅ Cart section is now exactly below the comment box
          if (widget.forSale)
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 0.0, top: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹${_price?.toStringAsFixed(2) ?? "-"}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF298A90), // Same color as likes count
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.shopping_cart, color: Color(0xFF19A99F)),
                    onPressed: _addToCart,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
