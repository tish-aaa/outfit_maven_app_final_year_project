import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  String firstName = "";
  String lastName = "";
  String email = "";
  String phone = "";
  String age = "";
  String username = "";
  String profileImageUrl = "";

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
            profileImageUrl = data["profileImageUrl"] ?? "assets/default_profile.jpg";
            
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

  Future<void> resetPassword() async {
    if (user != null) {
      try {
        await _auth.sendPasswordResetEmail(email: user!.email!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password reset link sent to $email")),
        );
      } catch (e) {
        print("Error sending reset password email: $e");
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
            Center(
              child: CircleAvatar(
                backgroundImage: profileImageUrl.startsWith("http")
                    ? NetworkImage(profileImageUrl)
                    : AssetImage(profileImageUrl) as ImageProvider,
                radius: 50,
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
            TextButton(
              onPressed: resetPassword,
              child: Text("Reset Password", style: TextStyle(color: Colors.red)),
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
