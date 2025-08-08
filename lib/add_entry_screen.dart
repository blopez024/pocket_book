import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Required for sign out

class AddEntryScreen extends StatelessWidget {
  const AddEntryScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Navigate to login screen and remove all previous routes
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50], // Consistent background color
      appBar: AppBar(
        title: const Text(
          'Add New Entry',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700], // Consistent AppBar color
        elevation: 0, // Optional: for a flatter look
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sign Out',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Add Entry Screen - Form for income/expense here!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 6, 94, 165)),
          ),
        ),
      ),
    );
  }
}
