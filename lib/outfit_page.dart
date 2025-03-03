import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'providers/user_provider.dart';

class OutfitPage extends StatefulWidget {
  final String? postId;

  OutfitPage({this.postId});

  @override
  _OutfitPageState createState() => _OutfitPageState();
}

class _OutfitPageState extends State<OutfitPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isPrivate = true;
  bool _wasPrivate = true;
  bool _isLoading = false;
  String? _imageUrl;
  bool _forSale = false;
  bool _wasForSale = false;

  @override
  void initState() {
    super.initState();
    if (widget.postId != null) {
      _loadPostData();
    }
  }

  void _loadPostData() async {
    var postDoc = await FirebaseFirestore.instance
        .collection('outfits')
        .doc(widget.postId)
        .get();
    if (postDoc.exists) {
      var data = postDoc.data() as Map<String, dynamic>;
      setState(() {
        _descriptionController.text = data['description'] ?? '';
        _isPrivate = data['isPrivate'] ?? true;
        _wasPrivate = _isPrivate;
        _imageUrl = data['imageUrl'] ?? '';
        _forSale = data['forSale'] ?? false;
        _wasForSale = _forSale;
        if (_forSale) {
          _priceController.text = data['price']?.toString() ?? '';
        }
      });
    }
  }

  Future<void> _pickImage() async {
    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      String? uploadedUrl = await userProvider.uploadImageToCloudinary();
      setState(() {
        _imageUrl = uploadedUrl;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image upload failed. Please try again.")),
      );
    }
  }

  void _saveOutfit() async {
    if (_descriptionController.text.trim().isEmpty || _imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please provide an image and description")),
      );
      return;
    }
    if (_forSale && _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a price for the outfit")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;
    final username = userProvider.username;
    final profileImageUrl = userProvider.profileImageUrl;

    String postId = widget.postId ?? Uuid().v4();
    Map<String, dynamic> postData = {
      'postId': postId,
      'imageUrl': _imageUrl,
      'description': _descriptionController.text.trim(),
      'userId': userId,
      'userName': username,
      'profileImageUrl': profileImageUrl,
      'isPrivate': _isPrivate,
      'forSale': _forSale,
    };

    if (_forSale) {
      postData['price'] = double.parse(_priceController.text.trim());
    }

    await FirebaseFirestore.instance.collection('outfits').doc(postId).set(postData);
    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.postId == null ? "Add Outfit" : "Edit Outfit"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: _imageUrl == null
                  ? Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
                    )
                  : Image.network(_imageUrl!, height: 150),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: "Description"),
              maxLength: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Make Private"),
                Switch(
                  value: _isPrivate,
                  onChanged: (_forSale) ? null : (newValue) {
                    setState(() {
                      _isPrivate = newValue;
                    });
                  },
                  activeColor: Colors.red,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("For Sale"),
                Switch(
                  value: _forSale,
                  onChanged: (_wasForSale || _isPrivate)
                      ? null
                      : (newValue) {
                          if (newValue) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Confirm Sale"),
                                content: Text("Once an outfit is marked for sale, it cannot be made private again."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _forSale = true;
                                        _isPrivate = false;
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Text("Confirm"),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            setState(() {
                              _forSale = false;
                              _priceController.clear();
                            });
                          }
                        },
                  activeColor: Colors.green,
                ),
              ],
            ),
            if (_forSale)
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: _saveOutfit,
          child: _isLoading ? CircularProgressIndicator() : Text("Save"),
        ),
      ],
    );
  }
}
