import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  bool _isRegistering = false;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? remember = prefs.getBool('rememberMe');
    if (remember != null && remember) {
      setState(() {
        _rememberMe = true;
        _emailController.text = prefs.getString('email') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
      });
    }
  }

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    
    try {
      UserCredential userCredential;
      String userId;
      
      if (_isRegistering) {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        userId = userCredential.user!.uid;

        await _firestore.collection('users').doc(userId).set({
          'username': _usernameController.text.trim(),
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'profileImageUrl': 'assets/defaultprofile.png', // Set default profile image
        });
      } else {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      if (!_isRegistering && _rememberMe) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('rememberMe', true);
        await prefs.setString('email', _emailController.text);
        await prefs.setString('password', _passwordController.text);
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('rememberMe');
        await prefs.remove('email');
        await prefs.remove('password');
      }
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication Failed')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _recoverPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your email to recover password")),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset email sent! Check your inbox.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending password reset email")),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
        ),
        validator: (value) {
          if (value!.isEmpty) return 'This field is required';
          if (isPassword && !RegExp(r'^(?=.*\d).{6,}$').hasMatch(value)) {
            return 'Password must have at least 6 characters & 1 digit';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset('assets/login_animation.json', height: 120),
                    SizedBox(height: 16),
                    if (_isRegistering) _buildTextField(_usernameController, 'Username'),
                    if (_isRegistering) _buildTextField(_firstNameController, 'First Name'),
                    if (_isRegistering) _buildTextField(_lastNameController, 'Last Name'),
                    _buildTextField(_emailController, 'Email'),
                    _buildTextField(_passwordController, 'Password', isPassword: true),
                    
                    if (!_isRegistering)
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value!;
                              });
                            },
                          ),
                          Text("Remember Me"),
                        ],
                      ),
                    
                    if (!_isRegistering)
                      TextButton(
                        onPressed: _recoverPassword,
                        child: Text("Forgot Password?", style: TextStyle(color: Colors.white70)),
                      ),
                    
                    SizedBox(height: 16),
                    _loading ? CircularProgressIndicator() : ElevatedButton(
                      onPressed: _authenticate,
                      child: Text(_isRegistering ? 'Register' : 'Login'),
                    ),
                    
                    TextButton(
                      onPressed: () => setState(() => _isRegistering = !_isRegistering),
                      child: Text(_isRegistering ? 'Already have an account? Login' : 'Don’t have an account? Register'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
