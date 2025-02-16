import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'navbar.dart';

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
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: CustomDrawer(userId: userId, userName: userName),
      endDrawer: CustomEndDrawer(
        userName: "User's Name", // Replace with actual user data
        profileImageUrl:
            "URL of the profile image", // Replace with actual image URL
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
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
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: ListTile(
                leading: Icon(Icons.email, color: Colors.blueAccent, size: 30),
                title: Text("Email Us",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("contact@outfitmaven.com"),
                onTap: () => _launchURL("mailto:contact@outfitmaven.com"),
              ),
            ),
            SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: ListTile(
                leading: Icon(Icons.phone, color: Colors.green, size: 30),
                title: Text("Call Us",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("+123 456 7890"),
                onTap: () => _launchURL("tel:+1234567890"),
              ),
            ),
            SizedBox(height: 20),
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
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
                  iconSize: 40,
                  onPressed: () =>
                      _launchURL("https://facebook.com/outfitmaven"),
                ),
                SizedBox(width: 15),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.instagram, color: Colors.pink),
                  iconSize: 40,
                  onPressed: () =>
                      _launchURL("https://instagram.com/outfitmaven"),
                ),
                SizedBox(width: 15),
                IconButton(
                  icon:
                      FaIcon(FontAwesomeIcons.twitter, color: Colors.lightBlue),
                  iconSize: 40,
                  onPressed: () =>
                      _launchURL("https://twitter.com/outfitmaven"),
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              'Feedback:',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Write your suggestions...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {}, // Add function to send feedback
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                child: Text('Submit Feedback'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
