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
  bool _isPrivate = false;
  bool _wasPrivate = false;
  bool _isLoading = false;
  String? _imageUrl;
  bool _showWarning = false;

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
        _isPrivate = data['isPrivate'] ?? false;
        _wasPrivate = _isPrivate;
        _imageUrl = data['imageUrl'] ?? '';
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
    };

    await FirebaseFirestore.instance
        .collection('outfits')
        .doc(postId)
        .set(postData);

    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Outfit"),
        content: Text("Are you sure you want to delete this outfit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('outfits')
                  .doc(widget.postId)
                  .delete();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handlePrivacyToggle(bool newValue) {
    if (!_wasPrivate) {
      setState(() {
        _isPrivate = newValue;
        _showWarning = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.postId == null ? "Add Outfit" : "Edit Outfit"),
      content: Column(
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
                onChanged: _wasPrivate ? null : _handlePrivacyToggle,
                activeColor: Colors.red,
              ),
            ],
          ),
          if (_showWarning)
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                "Once private, this outfit cannot be made public again.",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        if (widget.postId != null)
          TextButton(
            onPressed: _confirmDelete,
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: _saveOutfit,
          child: _isLoading ? CircularProgressIndicator() : Text("Save"),
        ),
      ],
    );
  }
}
