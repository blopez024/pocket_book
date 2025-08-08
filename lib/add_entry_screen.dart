import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for TextInputFormatter
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_book/services/database_service.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _CategoryUIData {
  final IconData icon;
  final Color color;

  _CategoryUIData({required this.icon, required this.color});
}


enum TransactionType { expense, income }

class _AddEntryScreenState extends State<AddEntryScreen> {
  final DatabaseService _dbService = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  // TextEditingControllers for amount, note
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // State variables for type (income/expense), category
  TransactionType _selectedType = TransactionType.expense;
  String? _selectedCategory;
  // Define the list of categories
  final List<String> _categories = [
    'Salary',
    'Rent',
    'Groceries',
    'Phone',
    'Utilities',
    'Transportation',
    'Entertainment',
    'Savings',
    'Dining Out',
    'Health',
    'Freelance',
    'Gym Membership',
    'Pet Supplies',
    'Childcare',
    'Coffee',
    'Other'
  ];

  // Define styles for categories (icon and color)
  final Map<String, ({IconData icon, Color color})> _categoryStyles = {
    'Salary': (icon: Icons.attach_money, color: Colors.green.shade300),
    'Rent': (icon: Icons.home, color: Colors.orange.shade900),
    'Groceries': (icon: Icons.shopping_cart, color: Colors.blue.shade900),
    'Phone': (icon: Icons.phone, color: Colors.purple.shade300),
    'Utilities': (icon: Icons.lightbulb, color: Colors.yellow.shade900),
    'Transportation': (icon: Icons.directions_car, color: Colors.teal.shade900),
    'Entertainment': (icon: Icons.movie, color: Colors.pink.shade300),
    'Savings': (icon: Icons.savings, color: Colors.lightGreen.shade400),
    'Dining Out': (icon: Icons.restaurant, color: Colors.red.shade300),
    'Health': (icon: Icons.healing, color: Colors.indigo.shade300),
    'Freelance': (icon: Icons.work, color: Colors.cyan.shade300),
    'Gym Membership': (icon: Icons.fitness_center, color: Colors.lime.shade400),
    'Pet Supplies': (icon: Icons.pets, color: Colors.brown.shade300),
    'Childcare': (icon: Icons.child_friendly, color: Colors.amber.shade400),
    'Coffee': (icon: Icons.local_cafe, color: Colors.brown.shade400),
    'Other': (icon: Icons.category, color: Colors.grey.shade400),
  };


  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }
  }

  void _clearForm() {
    _amountController.clear();
    _noteController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedType = TransactionType.expense;
    });
  }

  void _submitEntry() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final amount = double.tryParse(_amountController.text);
      if (amount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid amount entered.')),
        );
        return;
      }

      Map<String, dynamic> newTransaction = {
        "type": _selectedType.name,
        "amount": amount,
        "category": _selectedCategory!,
        "date": DateTime.now().toIso8601String(),
        "note": _noteController.text,
        "userId": FirebaseAuth.instance.currentUser?.uid, // Added userId
      };

      try {
        await _dbService.addTransaction(newTransaction);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entry added successfully!')),
          );
          _clearForm(); // Clear form fields
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add entry: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
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
        child: Form(
          key: _formKey,
          child: ListView( // Changed to ListView to prevent overflow
            children: <Widget>[
              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount (e.g., 25.50)',
                  icon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                  filled: true, // Make field white
                  fillColor: Colors.white, // Make field white
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  icon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: _selectedCategory,
                hint: const Text('Select a category'),
                isExpanded: true,
                items: _categories.map((String category) {
                  final style = _categoryStyles[category] ?? _categoryStyles['Other']!; // Fallback to 'Other' style
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Row(
                      children: <Widget>[
                        Icon(style.icon, color: style.color, size: 24), // Icon with color
                        const SizedBox(width: 10),
                        Text(category, style: const TextStyle(fontSize: 16.0)), // Larger text
                      ],
                    ),
                  );
                }).toList(),
                selectedItemBuilder: (BuildContext context) {
                  return _categories.map<Widget>((String category) {
                    final style = _categoryStyles[category] ?? _categoryStyles['Other']!; // Fallback for safety
                    return Center( // Center the selected item
                      child: Row(
                        children: <Widget>[
                          Icon(style.icon, color: style.color, size: 20), // Slightly smaller icon for the button face
                          const SizedBox(width: 8),
                          Text(category, style: const TextStyle(fontSize: 16.0, color: Colors.black87)), // Larger text
                        ],
                      ),
                    );
                  }).toList();
                },
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 20),

              // Note Field
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  hintText: 'Enter a short note',
                  icon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                  filled: true, // Make field white
                  fillColor: Colors.white, // Make field white
                ),
                maxLength: 30,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(30),
                ],
              ),
              const SizedBox(height: 20),

              // Type Selection (Expense/Income)
              const Text('Type:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<TransactionType>(
                segments: const <ButtonSegment<TransactionType>>[
                  ButtonSegment<TransactionType>(
                      value: TransactionType.expense,
                      label: Text('Expense'),
                      icon: Icon(Icons.arrow_downward)),
                  ButtonSegment<TransactionType>(
                      value: TransactionType.income,
                      label: Text('Income'),
                      icon: Icon(Icons.arrow_upward)),
                ],
                selected: <TransactionType>{_selectedType},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
                style: SegmentedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[700],
                  selectedForegroundColor: Colors.white,
                  selectedBackgroundColor: Colors.blue[600],
                ),
              ),
              const SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: _submitEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                child: const Text('Add Entry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
