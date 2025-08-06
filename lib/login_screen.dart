import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

// Changed _LoginScreenState to LoginScreenState
class LoginScreenState extends State<LoginScreen>  {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  Future<void> _signIn() async {
    // Trim input to remove leading/trailing whitespace
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your email.";
      });
      return;
    }

    // Basic email validation using a simple regex
    final bool isValidEmail = RegExp(
        r"^[a-zA-Z0-9_.±]+@[a-zA-Z0-9-]+.[a-zA-Z0-9-.]+$")
        .hasMatch(email);

    if (!isValidEmail) {
      setState(() {
        _errorMessage = "Please enter a valid email address.";
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your password.";
      });
      return;
    }

    // If all validations pass, clear any previous field-specific error messages
    // and attempt to sign in.
    try {
      setState(() {
        _errorMessage = null; // Clear previous error messages
      });
      await _auth.signInWithEmailAndPassword(
        email: email, // Use the trimmed email
        password: password, // Use the trimmed password
      );
      // Navigate to home screen or handle successful login
      // Navigator.pushReplacementNamed(context, '/home'); // Example navigation
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });

      // print('Failed to sign in: ${e.message}');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Login')), // Optional: Remove or style AppBar
      body: Container( // Added Container for background color
        color: Colors.lightBlue[50], // Example background color
        padding: const EdgeInsets.all(24.0), // Increased padding
        child: Center( // Center the content
          child: SingleChildScrollView( // Added for smaller screens
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, // Make children take full width
              children: <Widget>[
                // Placeholder for Logo - Add your logo in assets folder
                // and update pubspec.yaml
                // Image.asset('assets/logo.png', height: 150),
                // SizedBox(height: 48),

                Text(
                  'Pocket Book',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                SizedBox(height: 48),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.redAccent, fontSize: 14),
                    ),
                  ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16), // Increased spacing
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 24), // Increased spacing
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700], // Button color
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onPressed: _signIn,
                  child: Text('Login', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text(
                    'Don\'t have an account? Register',
                    style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
