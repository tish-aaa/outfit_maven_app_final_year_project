import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _isRegistering = false;
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _isUsernameTaken(String username) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  void _authenticate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      UserCredential userCredential;
      String userId;
      String userName = "";

      if (_isRegistering) {
        if (await _isUsernameTaken(_usernameController.text.trim())) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Username is already taken. Choose another one.')),
          );
          setState(() => _loading = false);
          return;
        }

        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        userId = userCredential.user!.uid;

        await _firestore.collection('users').doc(userId).set({
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
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
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            userId: userId,
            userName: userName,
          ),
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
              _buildTextField(_emailController, 'Email', keyboardType: TextInputType.emailAddress),
              _buildPasswordField(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: 'Password',
          border: OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Password is required';
          }
          if (value.length < 8) {
            return 'Password must be at least 8 characters long';
          }
          if (!RegExp(r'^(?=.*[0-9])(?=.*[^A-Za-z0-9])').hasMatch(value)) {
            return 'Password must contain at least one digit and one special character';
          }
          return null;
        },
      ),
    );
  }
}
