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
    'dzj8zymjz', // Replace with your Cloudinary cloud name
    'profile_pics', // Replace with your upload preset
    cache: true,
  );

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
            profileImageUrl = data["profileImageUrl"] ?? "assets/defaultprofile.png";

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

  // Upload profile picture to Cloudinary and update Firestore
  Future<void> _uploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        // Generate a unique filename for the profile picture
        String uniqueFileName = "profile_${user!.uid}_${DateTime.now().millisecondsSinceEpoch}";

        // Upload the image to Cloudinary
        CloudinaryResponse response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(image.path, resourceType: CloudinaryResourceType.Image, publicId: uniqueFileName),
        );

        // Update Firestore with the new profile image URL
        await _updateProfileImageUrlInFirestore(response.secureUrl);

        setState(() {
          profileImageUrl = response.secureUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile image updated successfully!")),
        );
      } catch (e) {
        print("Error uploading image to Cloudinary: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload profile image")),
        );
      }
    }
  }

  // Update Firestore with the new profile image URL
  Future<void> _updateProfileImageUrlInFirestore(String imageUrl) async {
    if (user != null) {
      try {
        await _firestore.collection("users").doc(user!.uid).update({
          "profileImageUrl": imageUrl,
        });
      } catch (e) {
        print("Error updating profile image in Firestore: $e");
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
                backgroundImage: profileImageUrl.startsWith("http")
                    ? NetworkImage(profileImageUrl)
                    : AssetImage("assets/defaultprofile.png") as ImageProvider,
              ),
            ),
            SizedBox(height: 20),
            ProfileInfo(title: "First Name", value: firstName),
            SizedBox(height: 15),
            ProfileInfo(title: "Last Name", value: lastName),
            SizedBox(height: 15),
            ProfileInfo(title: "Email", value: email),
            SizedBox(height: 15),
            EditableTextField(controller: phoneController, label: "Phone Number"),
            SizedBox(height: 15),
            EditableTextField(controller: ageController, label: "Age"),
            SizedBox(height: 15),
            EditableTextField(controller: usernameController, label: "Username"),
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
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
