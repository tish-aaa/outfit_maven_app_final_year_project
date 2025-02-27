import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  bool _isRegistering = false;
  bool _loading = false;
  bool _obscurePassword = true;
  File? _selectedImage;
  String _defaultProfileImagePath = 'assets/defaultprofile.png';

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadProfileImage(String userId) async {
    if (_selectedImage == null) return _defaultProfileImagePath;

    try {
      Reference storageRef = _storage.ref().child('profile_pictures/$userId.jpg');
      await storageRef.putFile(_selectedImage!);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return _defaultProfileImagePath;
    }
  }

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      UserCredential userCredential;
      String userId;
      String userName = "";
      String profileImageUrl = _defaultProfileImagePath;

      if (_isRegistering) {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        userId = userCredential.user!.uid;
        profileImageUrl = await _uploadProfileImage(userId);

        await _firestore.collection('users').doc(userId).set({
          'username': _usernameController.text.trim(),
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'profileImageUrl': profileImageUrl,
        });

        userName = _usernameController.text.trim();
      } else {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        userId = userCredential.user!.uid;

        DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>?;
          userName = data?['username'] ?? '';
          profileImageUrl = data?['profileImageUrl'] ?? _defaultProfileImagePath;
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication Failed')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _toggleRegister() {
    setState(() {
      _isRegistering = !_isRegistering;
      _formKey.currentState?.reset();
      _emailController.clear();
      _passwordController.clear();
      _usernameController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegistering ? 'Register' : 'Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_isRegistering) _buildTextField(_usernameController, 'Username'),
              if (_isRegistering) _buildTextField(_firstNameController, 'First Name'),
              if (_isRegistering) _buildTextField(_lastNameController, 'Last Name'),
              _buildTextField(_emailController, 'Email', keyboardType: TextInputType.emailAddress),
              _buildPasswordField(),
              if (_isRegistering) _buildImagePicker(),
              SizedBox(height: 16),
              _loading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _authenticate,
                      child: Text(_isRegistering ? 'Register' : 'Login'),
                    ),
              TextButton(
                onPressed: _toggleRegister,
                child: Text(
                  _isRegistering ? 'Already have an account? Login' : 'Don’t have an account? Register',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) => value!.isEmpty ? 'This field is required' : null,
      ),
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(_passwordController, 'Password', keyboardType: TextInputType.visiblePassword);
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        _selectedImage != null
            ? Image.file(_selectedImage!, height: 100, width: 100, fit: BoxFit.cover)
            : Image.asset(_defaultProfileImagePath, height: 100, width: 100, fit: BoxFit.cover),
        TextButton(
          onPressed: _pickImage,
          child: Text('Choose Profile Picture'),
        ),
      ],
    );
  }
}
