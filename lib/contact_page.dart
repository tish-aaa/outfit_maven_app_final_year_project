import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
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
                  color: Color(0xFF1DCFCA),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Lottie.asset(
                'assets/contact_us.json',
                width: 250,
                height: 250,
              ),
            ),
            const SizedBox(height: 20),
            _buildContactCard(Icons.email, "Email Us", "contact@outfitmaven.com", "mailto:contact@outfitmaven.com"),
            const SizedBox(height: 10),
            _buildContactCard(Icons.phone, "Call Us", "+123 456 7890", "tel:+1234567890"),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Follow us on Social Media",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1DCFCA),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildSocialIcons(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String subtitle, String url) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF1DCFCA), size: 30),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: () => _launchURL(url),
      ),
    );
  }

  Widget _buildSocialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIcon(FontAwesomeIcons.facebook, Colors.blue, "https://facebook.com/outfitmaven"),
        const SizedBox(width: 15),
        _buildSocialIcon(FontAwesomeIcons.instagram, Colors.pink, "https://instagram.com/outfitmaven"),
        const SizedBox(width: 15),
        _buildSocialIcon(FontAwesomeIcons.twitter, Colors.lightBlue, "https://twitter.com/outfitmaven"),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color, String url) {
    return IconButton(
      icon: FaIcon(icon, color: color),
      iconSize: 40,
      onPressed: () => _launchURL(url),
    );
  }
}
