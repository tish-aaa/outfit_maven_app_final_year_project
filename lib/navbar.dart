import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'contact_page.dart';
import 'login_page.dart';
import 'liked_inspo_page.dart';
import 'profile_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomAppBar({required this.scaffoldKey, super.key});

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
        child: Image.asset(
          'assets/logo.jpg',
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
  final String userId;
  final String userName;
  final String profileImageUrl;

  const CustomDrawer({
    super.key,
    required this.userId,
    required this.userName,
    required this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue.shade200),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(profileImageUrl),
                  radius: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildDrawerItem(
                    Icons.home,
                    () => HomePage(
                        userId: userId,
                        userName: userName,
                        profileImageUrl: profileImageUrl),
                    context),
                _buildDrawerItem(Icons.info, () {}, context),
                _buildDrawerItem(
                    Icons.favorite,
                    () => LikedInspoPage(
                        userId: userId,
                        userName: userName,
                        profileImageUrl: profileImageUrl),
                    context),
                _buildDrawerItem(Icons.checkroom, () {}, context),
                _buildDrawerItem(Icons.quiz, () {}, context),
                _buildDrawerItem(
                    Icons.contact_mail, () => ContactPage(), context),  // Removed `const`
              ],
            ),
          ),
          const SizedBox(height: 20),
          Image.asset('assets/logo.jpg', height: 50),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, Function page, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      onTap: () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => page()));
      },
    );
  }
}

class CustomEndDrawer extends StatelessWidget {
  final String userName;
  final String profileImageUrl;

  const CustomEndDrawer({
    super.key,
    required this.userName,
    required this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue.shade200),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(profileImageUrl),
                  radius: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blueGrey),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfilePage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.blueGrey),
            title: const Text('Logout'),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            },
          ),
        ],
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF8EC5FC),
            Color(0xFFE0C3FC)
          ], // Blue to Light Lavender Gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent, // Let the gradient be visible
        elevation: 0,
        items: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.checkroom, 1),
          _buildNavItem(Icons.favorite, 2),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, int index) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: currentIndex == index
              ? Colors.blue.shade100.withOpacity(0.6)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            color: currentIndex == index ? Colors.blueAccent : Colors.blueGrey),
      ),
      label: "", // No labels, only icons
    );
  }
}
