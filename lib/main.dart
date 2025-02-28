import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'login_page.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..fetchUserData()), // ✅ Fetch user data on startup
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade100,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.blueGrey),
          titleTextStyle: const TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;

          if (user == null) {
            return LoginPage();
          } else {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return LoginPage();
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;

                final userProvider = Provider.of<UserProvider>(context, listen: false);
                userProvider.updateUser(
                  id: user.uid,
                  name: userData['username'] ?? 'Unknown User',
                  imageUrl: userData['profileImageUrl'] ?? '',
                );

                return HomePage();
              },
            );
          }
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
