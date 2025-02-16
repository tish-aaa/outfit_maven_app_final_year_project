import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'contact_page.dart';
import 'login_page.dart';
import 'liked_inspo_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomAppBar({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue.shade100,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.blueGrey),
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
      ),
      title: Center(
        child: Image.network(
          'https://via.placeholder.com/120x40.png?text=Outfit+Maven',
          height: 40,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle, color: Colors.blueGrey),
          onPressed: () {
            scaffoldKey.currentState?.openEndDrawer();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomDrawer extends StatelessWidget {
  final String userId; // Accept userId

  const CustomDrawer({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue.shade200),
            child: Center(
              child: Image.network(
                'https://via.placeholder.com/150.png?text=Outfit+Maven',
                height: 80,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blueGrey),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HomePage(userId: userId)), // Pass userId
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.blueGrey),
            title: const Text('Liked Inspo'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        LikedInspoPage(userId: userId)), // Pass userId
              );
            },
          ),
        ],
      ),
    );
  }
}

class CustomEndDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue.shade200),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle, size: 80, color: Colors.white),
                  SizedBox(height: 10),
                  Text("User Profile",
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blueGrey),
            title: const Text('View Profile'),
            onTap: () {
              Navigator.pop(context); // Add link for profile page here later
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.blueGrey),
            title: const Text('Logout'),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
