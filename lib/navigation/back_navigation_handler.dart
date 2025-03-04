import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For exiting the app
import '../home_page.dart';

class BackNavigationHandler extends StatelessWidget {
  final Widget child;

  BackNavigationHandler({required this.child});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
          return false; // Prevents app from closing
        } else {
          // If already on HomePage, exit the app instead of navigating
          bool isHomePage = ModalRoute.of(context)?.settings.name == '/home';

          if (isHomePage) {
            SystemNavigator.pop(); // Exits the app cleanly
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
          return false; // Prevent default back action
        }
      },
      child: child,
    );
  }
}
