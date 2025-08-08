import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import your screen widgets (you'll create these next)
import 'login_screen.dart';
import 'registration_screen.dart';
import 'home_screen.dart'; // A screen to show after successful login
import 'package:pocket_book/app_scaffold.dart';
import 'package:pocket_book/login_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Book',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // You can define other theme properties here
      ),
      // If you are using named routes, ensure '/register' is defined
      // and update the initial route logic.
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return const AppScaffold(); // <-- Go to AppScaffold if logged in
          }
          return const LoginScreen();   // <-- Go to LoginScreen if not
        },
      ),
      routes: {
        // Ensure your /register route is defined if you use Navigator.pushNamed(context, '/register')
        '/register': (context) => RegistrationScreen(), // Make sure RegistrationScreen is imported
        '/login': (context) => const LoginScreen(),
        '/app': (context) => const AppScaffold(), // Optional: if you want a named route for it
      },
    );
  }
}