import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'dzj8zymjz', // Replace with your actual Cloud Name
    'profile_pics', // Replace with your actual Upload Preset
    cache: true,
  );
// Replace with your Cloudinary credentials

  User? user;
  String firstName = "";
  String lastName = "";
  String email = "";
  String phone = "";
  String age = "";
  String username = "";
  String profileImageUrl = "assets/defaultprofile.png"; // Default profile image

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  Future<void> getUserDetails() async {
    user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection("users").doc(user!.uid).get();

        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

          setState(() {
            firstName = data["firstName"] ?? "";
            lastName = data["lastName"] ?? "";
            email = data["email"] ?? "";
            phone = data["phone"] ?? "";
            age = data["age"]?.toString() ?? "";
            username = data["username"] ?? "";
            profileImageUrl = data["profileImageUrl"] ??
                "assets/defaultprofile.png"; // Check this line

            phoneController.text = phone;
            ageController.text = age;
            usernameController.text = username;
          });
        }
      } catch (e) {
        print("Error fetching user details: $e");
      }
    }
  }

  // Method to upload image to Cloudinary in a user-specific folder
  Future<void> _uploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        // Uploading image to a user-specific folder (using user UID as the folder name)
        CloudinaryResponse response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(image.path,
              folder: 'profile_pics/${user!.uid}'),
        );

        setState(() {
          profileImageUrl =
              response.secureUrl; // Save the URL of the uploaded image
        });

        _updateProfileImageUrlInFirestore(
            response.secureUrl); // Update Firestore with the new URL
      } catch (e) {
        print("Error uploading image to Cloudinary: $e");
      }
    }
  }

  // Method to update profile image URL in Firestore
  Future<void> _updateProfileImageUrlInFirestore(String imageUrl) async {
    if (user != null) {
      try {
        await _firestore.collection("users").doc(user!.uid).update({
          "profileImageUrl": imageUrl,
        });
        print("Updated profile image URL in Firestore: $imageUrl");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile image updated successfully!")),
        );
      } catch (e) {
        print("Error updating profile image in Firestore: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile image")),
        );
      }
    }
  }

  Future<void> updateProfile() async {
    if (user != null) {
      try {
        await _firestore.collection("users").doc(user!.uid).update({
          "phone": phoneController.text.trim(),
          "age": ageController.text.trim(),
          "username": usernameController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully!")),
        );
      } catch (e) {
        print("Error updating profile: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _uploadImage, // Allows user to tap and upload image
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.transparent,
                child: profileImageUrl.isNotEmpty
                    ? Image.network(
                        profileImageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child; // Return the image when it's fully loaded
                          } else {
                            return Center(
                                child:
                                    CircularProgressIndicator()); // Show loading indicator
                          }
                        },
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          // If error, show default image or error message
                          return Image.asset("assets/defaultprofile.png",
                              fit: BoxFit.cover);
                        },
                      )
                    : Image.asset("assets/defaultprofile.png",
                        fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 20),
            ProfileInfo(title: "First Name", value: firstName),
            SizedBox(height: 15),
            ProfileInfo(title: "Last Name", value: lastName),
            SizedBox(height: 15),
            ProfileInfo(title: "Email", value: email),
            SizedBox(height: 15),
            EditableTextField(
                controller: phoneController, label: "Phone Number"),
            SizedBox(height: 15),
            EditableTextField(controller: ageController, label: "Age"),
            SizedBox(height: 15),
            EditableTextField(
                controller: usernameController, label: "Username"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateProfile,
              child: Text("Update Profile"),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfo extends StatelessWidget {
  final String title;
  final String value;

  const ProfileInfo({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}

class EditableTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const EditableTextField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}
