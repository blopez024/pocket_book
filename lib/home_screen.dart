import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key}); // Removed 'const'

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              // Consider how to handle navigation after logout.
              // For example, to go back to the login screen and prevent going back to home:
              // Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: Text(user != null ? 'Welcome ${user.email}!' : 'Welcome!'),
      ),
    );
  }
}