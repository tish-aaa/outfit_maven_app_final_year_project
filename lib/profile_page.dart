import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'package:flutter/services.dart';
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

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

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

            firstNameController.text = firstName;
            lastNameController.text = lastName;
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

  Future<void> _uploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        String uniqueFileName =
            "profile_${user!.uid}_${DateTime.now().millisecondsSinceEpoch}";

        CloudinaryResponse response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(image.path,
              resourceType: CloudinaryResourceType.Image,
              publicId: uniqueFileName),
        );

        await _updateProfileImageUrlInFirestore(response.secureUrl);

        Provider.of<UserProvider>(context, listen: false)
            .updateProfileImage(response.secureUrl);
      } catch (e) {
        print("Error uploading image to Cloudinary: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload profile image")),
        );
      }
    }
  }

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
      if (firstNameController.text.trim().isEmpty ||
          lastNameController.text.trim().isEmpty ||
          usernameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("First Name, Last Name, and Username are required")),
        );
        return;
      }

      if (phoneController.text.isNotEmpty &&
          phoneController.text.length != 10) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Phone number must be exactly 10 digits")));
        return;
      }

      if (ageController.text.isNotEmpty &&
          (int.tryParse(ageController.text) == null ||
              int.parse(ageController.text) < 5 ||
              int.parse(ageController.text) > 111)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Please enter a valid age between 5 and 111")));
        return;
      }

      try {
        await _firestore.collection("users").doc(user!.uid).update({
          "firstName": firstNameController.text.trim(),
          "lastName": lastNameController.text.trim(),
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
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF70C2BD),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _uploadImage,
              child: CircleAvatar(
                radius: 111,
                backgroundColor: Colors.transparent,
                backgroundImage: userProvider.profileImageUrl !=
                        UserProvider.defaultProfileImage
                    ? NetworkImage(userProvider.profileImageUrl)
                    : AssetImage(UserProvider.defaultProfileImage)
                        as ImageProvider,
              ),
            ),
            SizedBox(height: 20),
            EditableTextField(
                controller: firstNameController, label: "First Name"),
            SizedBox(height: 15),
            EditableTextField(
                controller: lastNameController, label: "Last Name"),
            SizedBox(height: 15),
            TextField(
              controller: TextEditingController(text: email),
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Email",
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            EditableTextField(
                controller: phoneController,
                label: "Phone Number",
                validator: (value) {
                  if (value!.isNotEmpty && value.length != 10) {
                    return 'Phone number must be 10 digits';
                  }
                  return null;
                }),
            SizedBox(height: 15),
            EditableTextField(
                controller: ageController,
                label: "Age",
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Ensures only digits
                ]),
            SizedBox(height: 15),
            EditableTextField(
                controller: usernameController, label: "Username"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateProfile,
              child: Text("Update Profile"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    Color(0xFF70C2BD)), // Set background color
                foregroundColor:
                    MaterialStateProperty.all(Colors.white), // Set text color
                minimumSize: MaterialStateProperty.all(
                    Size(double.infinity, 50)), // Full width and height
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditableTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const EditableTextField({
    required this.controller,
    required this.label,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType:
          label == "Phone Number" ? TextInputType.phone : TextInputType.text,
      inputFormatters: inputFormatters, // Add the input formatter
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF70C2BD)),
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
