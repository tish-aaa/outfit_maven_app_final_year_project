import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'home_page.dart';
import 'contact_page.dart';
import 'login_page.dart';
import 'liked_inspo_page.dart';
import 'profile_page.dart';
import 'outfit_quiz.dart';
import 'my_outfits_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomAppBar({required this.scaffoldKey, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        String profileImageUrl = userProvider.profileImageUrl;
        
        return AppBar(
          backgroundColor: Colors.blue.shade100,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.blueGrey),
            onPressed: () {
              scaffoldKey.currentState?.openDrawer();
            },
          ),
          title: Center(
            child: Image.asset(
              'assets/logo.png',
              height: 40,
            ),
          ),
          actions: [
            IconButton(
              icon: CircleAvatar(
                radius: 24,
                backgroundImage: profileImageUrl != UserProvider.defaultProfileImage
                    ? NetworkImage(profileImageUrl)
                    : AssetImage(UserProvider.defaultProfileImage) as ImageProvider,
              ),
              onPressed: () {
                scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Drawer(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: Colors.blue.shade200,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: userProvider.profileImageUrl != UserProvider.defaultProfileImage
                          ? NetworkImage(userProvider.profileImageUrl)
                          : AssetImage(UserProvider.defaultProfileImage) as ImageProvider,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userProvider.username,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.blueGrey),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => HomePage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.blueGrey),
                title: const Text('Liked Inspo'),
                onTap: () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => LikedInspoPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.style, color: Colors.blueGrey),
                title: const Text('Outfit Quiz'),
                onTap: () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => OutfitQuizPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_bag, color: Colors.blueGrey),
                title: const Text('My Outfits'),
                onTap: () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => MyOutfitsPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.contact_mail, color: Colors.blueGrey),
                title: const Text('Contact'),
                onTap: () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => ContactPage()));
                },
              ),
              const Spacer(),
              Image.asset(
                'assets/logo.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ],
          ),
        );
      },
    );
  }
}

class CustomEndDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Drawer(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: Colors.blue.shade200,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: userProvider.profileImageUrl != UserProvider.defaultProfileImage
                          ? NetworkImage(userProvider.profileImageUrl)
                          : AssetImage(UserProvider.defaultProfileImage) as ImageProvider,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userProvider.username,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.blueGrey),
                title: const Text('My Profile'),
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => ProfilePage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.blueGrey),
                title: const Text('Logout'),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => LoginPage()));
                },
              ),
              const Spacer(),
              Image.asset(
                'assets/logo.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ],
          ),
        );
      },
    );
  }
}
