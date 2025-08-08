// lib/services/database_service.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For getting current user UID

class DatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // --- Profile Management ---
  Future<void> createUserProfile(String email, String name) async {
    if (_userId == null) throw Exception("User not logged in");
    DatabaseReference userProfileRef = _database.ref("users/$_userId/profile");
    try {
      await userProfileRef.set({
        "email": email,
        "name": name,
        "createdAt": DateTime.now().toIso8601String(),
      });
      print("User profile created successfully!");
    } catch (e) {
      print("Error creating user profile: $e");
      rethrow; // Or handle error appropriately
    }
  }

  Future<void> updateUserName(String newName) async {
    if (_userId == null) throw Exception("User not logged in");
    DatabaseReference userProfileRef = _database.ref("users/$_userId/profile");
    try {
      await userProfileRef.update({"name": newName});
      print("User name updated!");
    } catch (e) {
      print("Error updating user name: $e");
      rethrow;
    }
  }

  // --- Category Management ---
  Future<List<String>> getDefaultCategories() async {
    DatabaseReference defaultCategoriesRef = _database.ref("categories/default");
    try {
      final DataSnapshot snapshot = await defaultCategoriesRef.get();
      if (snapshot.exists && snapshot.value != null) {
        // Ensure the value is treated as a List.
        // Firebase might return it as List<Object?> or similar.
        final listValue = snapshot.value;
        if (listValue is List) {
           return List<String>.from(listValue.map((item) => item.toString()));
        }
        return [];
      }
      return [];
    } catch (e) {
      print('Error fetching default categories: $e');
      return [];
    }
  }

  // Add methods for customCategories if needed (e.g., addCustomCategory, getCustomCategories)

  // --- Transaction Management ---
  Future<void> addTransaction(Map<String, dynamic> transactionData) async {
    if (_userId == null) throw Exception("User not logged in");
    DatabaseReference userTransactionsRef = _database.ref("users/$_userId/transactions");
    try {
      DatabaseReference newTransactionRef = userTransactionsRef.push();
      await newTransactionRef.set(transactionData);
      print("Transaction added successfully with key: ${newTransactionRef.key}");
    } catch (e) {
      print("Error adding transaction: $e");
      rethrow;
    }
  }

  // To read transactions once
  Future<Map<String, dynamic>> getUserTransactions() async {
    if (_userId == null) return {};
    DatabaseReference userTransactionsRef = _database.ref("users/$_userId/transactions");
    try {
      final DataSnapshot snapshot = await userTransactionsRef.get();
      if (snapshot.exists && snapshot.value != null) {
         final value = snapshot.value;
         if (value is Map) {
            return Map<String, dynamic>.from(value.cast<String, dynamic>());
         }
         return {};
      }
      return {};
    } catch (e) {
      print('Error fetching transactions: $e');
      return {};
    }
  }

  // To listen for realtime transaction updates (returns a Stream)
  Stream<DatabaseEvent>? getTransactionsStream() {
    if (_userId == null) return null;
    DatabaseReference userTransactionsRef = _database.ref("users/$_userId/transactions");
    return userTransactionsRef.onValue;
  }

  // Add this method inside your DatabaseService class in lib/services/database_service.dart

  Future<DataSnapshot> getUserTransactionsSnapshot() async {
    if (_userId == null) throw Exception("User not logged in");
    DatabaseReference userTransactionsRef = _database.ref("users/$_userId/transactions");
    return userTransactionsRef.get();
  }
}
