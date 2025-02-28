import 'package:flutter/material.dart';
import 'post_card.dart';

class SelectablePost extends StatelessWidget {
  final String postId;
  final String imageUrl;
  final String description;
  final String userId;
  final String userName;
  final String profileImageUrl;
  final bool isPrivate;
  final bool isSelected;
  final Function(String) onSelect;

  const SelectablePost({
    required this.postId,
    required this.imageUrl,
    required this.description,
    required this.userId,
    required this.userName,
    required this.profileImageUrl,
    required this.isPrivate,
    required this.isSelected,
    required this.onSelect,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect(postId),
      onLongPress: () => onSelect(postId),
      child: Stack(
        children: [
          OutfitPost(
            postId: postId,
            imageUrl: imageUrl,
            description: description,
            userId: userId,
            userName: userName,
            profileImageUrl: profileImageUrl,
            isPrivate: isPrivate,
          ),
          if (isSelected)
            Positioned(
              top: 10,
              right: 10,
              child: Icon(Icons.check_circle, color: Colors.blue, size: 30),
            ),
        ],
      ),
    );
  }
}
