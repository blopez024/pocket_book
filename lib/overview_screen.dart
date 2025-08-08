import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_book/services/database_service.dart'; // Added import

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<String> _defaultCategories = [];
  // TODO: Add state for transaction summaries, etc.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    try {
      List<String> categories = await _dbService.getDefaultCategories();
      // TODO: Fetch transaction data and calculate summaries
      if (mounted) {
        setState(() {
          _defaultCategories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        print("Error fetching initial data for overview: $e");
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading overview: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text(
          'Budget Overview',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sign Out',
            onPressed: _signOut,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchInitialData, // Allow pull to refresh
              child: ListView( // Changed to ListView to allow for multiple sections
                padding: const EdgeInsets.all(16.0),
                children: [
                  const Text(
                    'Overview Screen - Pie chart and budget summary here!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 6, 94, 165)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Default Categories Loaded: ${_defaultCategories.isNotEmpty ? _defaultCategories.length : 'None'}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  // TODO: Display default categories if needed, or transaction summaries
                  // if (_defaultCategories.isNotEmpty) ...[
                  //   const SizedBox(height: 10),
                  //   Wrap(
                  //     spacing: 8.0,
                  //     runSpacing: 4.0,
                  //     children: _defaultCategories.map((category) => Chip(label: Text(category))).toList(),
                  //   ),
                  // ]
                ],
              ),
            ),
    );
  }
}
