import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'navbar.dart';
import 'providers/user_provider.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open link: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    String userId = userProvider.userId;
    String userName = userProvider.username;
    String profileImageUrl = userProvider.profileImageUrl.isNotEmpty
        ? userProvider.profileImageUrl
        : UserProvider.defaultProfileImage; // ✅ Fix: Use static accessor

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
      ),
      drawer: CustomDrawer(),
      endDrawer: CustomEndDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Get in Touch",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: ListTile(
                leading:
                    const Icon(Icons.email, color: Colors.blueAccent, size: 30),
                title: const Text("Email Us",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("contact@outfitmaven.com"),
                onTap: () => _launchURL("mailto:contact@outfitmaven.com"),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: ListTile(
                leading: const Icon(Icons.phone, color: Colors.green, size: 30),
                title: const Text("Call Us",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("+123 456 7890"),
                onTap: () => _launchURL("tel:+1234567890"),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Follow us on Social Media",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.facebook,
                      color: Colors.blue),
                  iconSize: 40,
                  onPressed: () =>
                      _launchURL("https://facebook.com/outfitmaven"),
                ),
                const SizedBox(width: 15),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.instagram,
                      color: Colors.pink),
                  iconSize: 40,
                  onPressed: () =>
                      _launchURL("https://instagram.com/outfitmaven"),
                ),
                const SizedBox(width: 15),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.twitter,
                      color: Colors.lightBlue),
                  iconSize: 40,
                  onPressed: () =>
                      _launchURL("https://twitter.com/outfitmaven"),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'Feedback:',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Write your suggestions...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {}, // Add function to send feedback
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Submit Feedback'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
