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
            // Firebase Realtime Database often returns Map<Object?, Object?>
            // So we need to carefully cast it.
            final dynamic data = event.snapshot.value;
            if (data is Map) {
              _transactions = data.map((key, value) =>
                  MapEntry(key.toString(), value as Map<String, dynamic>));
            } else {
              _transactions = {}; // Or handle unexpected data type
            }
            _error = null;
          } else {
            _transactions = {};
            _error = null; // Or set a specific "no data" message if preferred
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

    // Handle case where stream is null (e.g., user not logged in in DatabaseService)
    if (_dbService.getTransactionsStream() == null && mounted) {
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
    // Convert map to list and sort by date (descending)
    // This assumes 'date' is a String in ISO8601 format.
    // For more robust sorting, consider storing dates as timestamps or using DateTime objects.
    List<MapEntry<String, dynamic>> sortedTransactions = _transactions.entries.toList()
      ..sort((a, b) {
        String dateA = a.value['date'] as String? ?? '';
        String dateB = b.value['date'] as String? ?? '';
        return dateB.compareTo(dateA); // Descending order
      });

    return Scaffold(
      backgroundColor: Colors.lightBlue[50], // Consistent background color
      appBar: AppBar(
        title: const Text(
          'Transaction History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700], // Consistent AppBar color
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
        // final transactionId = transactionEntry.key; // If you need the ID
        final transaction = transactionEntry.value;

        final String type = transaction['type'] as String? ?? 'N/A';
        final num amount = transaction['amount'] as num? ?? 0;
        final String category = transaction['category'] as String? ?? 'Uncategorized';
        final String dateStr = transaction['date'] as String? ?? 'Unknown Date';
        final String note = transaction['note'] as String? ?? '';

        // Basic date formatting (consider intl package for better formatting)
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
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green[700] : Colors.red[700],
              size: 30,
            ),
            title: Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(note.isNotEmpty ? note : 'No note', style: TextStyle(color: Colors.grey[600])),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? "+" : "-"}\$${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isIncome ? Colors.green[700] : Colors.red[700],
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}