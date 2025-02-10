import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, String>> posts = [
    {
      "imageUrl":
          "https://images.unsplash.com/photo-1519999482648-25049ddd37b1", // Sample image URLs
      "caption": "Casual Street Style",
    },
    {
      "imageUrl": "https://images.unsplash.com/photo-1542223616-787c38359942",
      "caption": "Classic Formal Outfit",
    },
    {
      "imageUrl":
          "https://images.unsplash.com/photo-1503342217505-b0a15ec3261c",
      "caption": "Elegant Evening Wear",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Outfit Maven",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostCard(
            imageUrl: posts[index]["imageUrl"]!,
            caption: posts[index]["caption"]!,
          );
        },
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final String imageUrl;
  final String caption;

  const PostCard({required this.imageUrl, required this.caption, Key? key})
      : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              widget.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              widget.caption,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isLiked = !isLiked;
                        });
                      },
                    ),
                    const SizedBox(width: 4),
                    const Text("Like"),
                  ],
                ),
                TextButton.icon(
                  icon: const Icon(Icons.comment),
                  label: const Text("Comment"),
                  onPressed: () {
                    _showCommentDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentDialog(BuildContext context) {
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Comment"),
          content: TextField(
            controller: commentController,
            decoration: const InputDecoration(hintText: "Write a comment..."),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Comment added: ${commentController.text}"),
                  ),
                );
              },
              child: const Text("Post"),
            ),
          ],
        );
      },
    );
  }
}
