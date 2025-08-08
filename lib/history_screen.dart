import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pocket_book/services/database_service.dart'; // Ensure this path is correct

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _dbService = DatabaseService();
  StreamSubscription<DatabaseEvent>? _transactionsSubscription;
  Map<String, dynamic> _transactions = {};
  bool _isLoading = true;
  String? _error;

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

  IconData _getCategoryIcon(String category) {
    return _categoryStyles[category]?.icon ?? Icons.help_outline; // Default icon
  }

  Color _getCategoryColor(String category) {
    return _categoryStyles[category]?.color ?? Colors.grey; // Default color
  }

  @override
  void initState() {
    super.initState();
    _listenToTransactions();
  }

  void _listenToTransactions() {
    _transactionsSubscription =
        _dbService.getTransactionsStream()?.listen((DatabaseEvent event) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (event.snapshot.exists && event.snapshot.value != null) {
            final dynamic data = event.snapshot.value;
            if (data is Map) {
              _transactions = data.map((key, value) {
                if (value is Map) {
                  return MapEntry(key.toString(), Map<String, dynamic>.from(value));
                } else {
                  print('Warning: Transaction data for key $key is not a Map: $value');
                  return MapEntry(key.toString(), <String, dynamic>{});
                }
              });
            } else {
              _transactions = {};
            }
            _error = null;
          } else {
            _transactions = {};
            _error = null;
          }
        });
      }
    }, onError: (Object error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "Error fetching transactions: ${error.toString()}";
          print("Error listening to transactions: $error");
        });
      }
    });

    if (_dbService.getTransactionsStream() == null && mounted && _isLoading) {
        setState(() {
            _isLoading = false;
            _error = "Could not fetch transactions. User may not be logged in.";
        });
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }
  }

  @override
  void dispose() {
    _transactionsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, dynamic>> sortedTransactions = _transactions.entries.toList()
      ..sort((a, b) {
        String dateA = a.value['date'] as String? ?? '';
        String dateB = b.value['date'] as String? ?? '';
        return dateB.compareTo(dateA); // Descending order
      });

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text(
          'Transaction History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sign Out',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: _buildBody(sortedTransactions),
    );
  }

  Widget _buildBody(List<MapEntry<String, dynamic>> transactionsList) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (transactionsList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No transactions found.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 6, 94, 165)),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: transactionsList.length,
      itemBuilder: (context, index) {
        final transactionEntry = transactionsList[index];
        final transaction = transactionEntry.value;

        final String type = transaction['type'] as String? ?? 'N/A';
        final num amount = transaction['amount'] as num? ?? 0;
        final String category = transaction['category'] as String? ?? 'Uncategorized';
        final String dateStr = transaction['date'] as String? ?? 'Unknown Date';
        String note = transaction['note'] as String? ?? '';
        String displayNote = note;
        if (note.length > 20) {
          displayNote = '${note.substring(0, 20)}...';
        }

        String formattedDate = dateStr;
        try {
          final dateTime = DateTime.tryParse(dateStr);
          if (dateTime != null) {
            formattedDate = "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
          }
        } catch (e) {
          // Keep original string if parsing fails
        }
        
        bool isIncome = type.toLowerCase() == 'income';

        return Card(
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          child: ListTile(
            leading: Icon(
              _getCategoryIcon(category),
              color: _getCategoryColor(category),
              size: 30,
            ),
            title: Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(displayNote.isNotEmpty ? displayNote : 'No note', style: TextStyle(color: Colors.grey[600])),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min, // Important for the Row
                  crossAxisAlignment: CrossAxisAlignment.center, // Vertically aligns text and icon in the row
                  children: [
                    // Amount Text
                    Text(
                      '${isIncome ? "+" : "-"}\$${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isIncome ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                    const SizedBox(width: 4), // Space between amount and arrow
                    // Arrow Icon
                    Icon(
                      isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isIncome ? Colors.green[700] : Colors.red[700],
                      size: 15, // Keeping the reduced size
                    ),
                  ],
                ),
                // Date Text - remains below the Row
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            )
            ,
          ),
        );
      },
    );
  }
}
