import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
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
              // Navigator.pushReplacementNamed(context, '/login'); // Navigate back to login
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
