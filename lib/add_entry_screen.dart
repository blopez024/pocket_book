import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_book/services/database_service.dart'; // Added import

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final DatabaseService _dbService = DatabaseService();
  final _formKey = GlobalKey<FormState>(); // For form validation

  // TODO: Add TextEditingControllers for amount, note
  // TODO: Add state variables for type (income/expense), category, date

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }
  }

  void _submitEntry() async {
    // Basic validation, expand this
    // if (_formKey.currentState!.validate()) {
      // _formKey.currentState!.save(); // Save form fields if using onSaved
      
      // TODO: Get actual data from form fields
      Map<String, dynamic> newTransaction = {
        "type": "expense", // Placeholder
        "amount": 50.0,    // Placeholder
        "category": "Groceries", // Placeholder
        "date": DateTime.now().toIso8601String(), // Placeholder
        "note": "Test entry" // Placeholder
      };

      try {
        await _dbService.addTransaction(newTransaction);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entry added successfully!')),
          );
          // TODO: Clear form fields
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add entry: ${e.toString()}')),
          );
        }
      }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text(
          'Add New Entry',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // TODO: Build your form here using Form widget and _formKey
        // Example:
        // Form(
        //   key: _formKey,
        //   child: Column(
        //     children: <Widget>[
        //       TextFormField(decoration: InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number, validator: (value) => value!.isEmpty ? 'Required' : null),
        //       ElevatedButton(onPressed: _submitEntry, child: Text('Add Entry'))
        //     ],
        //   ),
        // )
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Form for income/expense here!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 6, 94, 165)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitEntry, // Connect to placeholder submit logic
                child: const Text('Add Sample Entry'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
