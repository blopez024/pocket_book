import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_book/services/database_service.dart';
import 'package:fl_chart/fl_chart.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  final DatabaseService _dbService = DatabaseService();
  StreamSubscription<DatabaseEvent>? _transactionsSubscription;

  bool _isLoading = true;
  String? _error;
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  Map<String, double> _expenseCategorySummaries = {};

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
    return _categoryStyles[category]?.icon ?? Icons.label; // Default icon
  }

  Color _getCategoryColor(String category) {
    return _categoryStyles[category]?.color ?? Colors.grey; // Default color
  }

  @override
  void initState() {
    super.initState();
    _listenToTransactions();
  }

  Future<void> _listenToTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _transactionsSubscription = _dbService.getTransactionsStream()?.listen(
            (DatabaseEvent event) {
          if (mounted) {
            _processTransactions(event.snapshot);
            setState(() {
              _isLoading = false;
              _error = null;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _error = "Error loading transactions: ${error.toString()}";
              print("Error listening to transactions: $error");
            });
          }
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
    );
    // Initial fetch in case stream is slow or no initial data event
    try {
      final snapshot = await _dbService.getUserTransactionsSnapshot(); // Need this method in DatabaseService
      if (mounted) {
        _processTransactions(snapshot);
        setStateIfMounted(() { _isLoading = false; });
      }
    } catch (e) {
      if (mounted) {
        setStateIfMounted(() {
          _isLoading = false;
          _error = "Error fetching initial transactions: ${e.toString()}";
        });
      }
    }
  }
  void setStateIfMounted(VoidCallback f) {
    if (mounted) {
      setState(f);
    }
  }


  void _processTransactions(DataSnapshot snapshot) {
    double currentMonthIncome = 0;
    double currentMonthExpenses = 0;
    Map<String, double> categoryExpenses = {};
    final now = DateTime.now();

    if (snapshot.exists && snapshot.value != null) {
      final Map<String, dynamic> allTransactions =
      Map<String, dynamic>.from(snapshot.value as Map);

      allTransactions.forEach((key, value) {
        final transaction = Map<String, dynamic>.from(value as Map);
        DateTime transactionDate;
        try {
          transactionDate = DateTime.parse(transaction['date'] as String);
        } catch (e) {
          print("Error parsing date for transaction $key: ${transaction['date']}");
          return; // Skip this transaction if date is invalid
        }

        if (transactionDate.year == now.year && transactionDate.month == now.month) {
          final amount = (transaction['amount'] as num).toDouble();
          final type = transaction['type'] as String?;
          final category = transaction['category'] as String?;

          if (type == 'income') {
            currentMonthIncome += amount;
          } else if (type == 'expense' && category != null) {
            currentMonthExpenses += amount;
            categoryExpenses.update(category, (value) => value + amount,
                ifAbsent: () => amount);
          }
        }
      });
    }
    _totalIncome = currentMonthIncome;
    _totalExpenses = currentMonthExpenses;
    _expenseCategorySummaries = categoryExpenses;
  }


  Future<void> _signOut() async {
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
      body: RefreshIndicator(
        onRefresh: _listenToTransactions,
        child: _buildBody(),
      ),
    );
  }

 Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16)),
        ),
      );
    }
    if (_totalIncome == 0 && _totalExpenses == 0 && _expenseCategorySummaries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'No transactions found for the current month. Pull down to refresh or add some entries!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
        ),
      );
    }

    List<PieChartSectionData> pieChartSections = [];
    if (_totalIncome > 0) {
      pieChartSections.add(PieChartSectionData(
        color: Colors.green.shade400,
        value: _totalIncome,
        title: 'Income\n\$${_totalIncome.toStringAsFixed(0)}',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    }
    if (_totalExpenses > 0) {
      pieChartSections.add(PieChartSectionData(
        color: Colors.red.shade400,
        value: _totalExpenses,
        title: 'Expenses\n\$${_totalExpenses.toStringAsFixed(0)}',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    }
    if (pieChartSections.isEmpty) {
      pieChartSections.add(PieChartSectionData(
        color: Colors.grey.shade300,
        value: 1,
        title: 'No Data',
        radius: 80,
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
      ));
    }

    double leftover = _totalIncome - _totalExpenses;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              Text(
                'Current Month Summary',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[800]),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: pieChartSections,
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        // Handle touch events if needed
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_totalIncome > 0) Indicator(color: Colors.green.shade400, text: 'Income', isSquare: false),
                  if (_totalIncome > 0 && _totalExpenses > 0) const SizedBox(width: 10),
                  if (_totalExpenses > 0) Indicator(color: Colors.red.shade400, text: 'Expenses', isSquare: false),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Leftover:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[700])),
                      Text(
                        '\$${leftover.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: leftover >= 0 ? Colors.green.shade600 : Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_expenseCategorySummaries.isNotEmpty)
                Text(
                  'Expense Categories',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                ),
              if (_expenseCategorySummaries.isNotEmpty)
                const SizedBox(height: 10),
            ]),
          ),
        ),
        if (_expenseCategorySummaries.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Keep horizontal padding for the grid
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.5, // Adjust for better card layout
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final category = _expenseCategorySummaries.keys.elementAt(index);
                  final amount = _expenseCategorySummaries[category]!;
                  final icon = _getCategoryIcon(category);
                  final color = _getCategoryColor(category);

                  return Card(
                    color: color.withOpacity(0.15),
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(icon, size: 30, color: color),
                          const SizedBox(height: 8),
                          Text(
                            category,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${amount.toStringAsFixed(2)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: color, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _expenseCategorySummaries.length,
              ),
            ),
          ),
         // Add a final padding at the bottom if needed for spacing
         SliverPadding(
            padding: const EdgeInsets.only(bottom: 16.0),
         ),
      ],
    );
  }
}

// Helper widget for Pie Chart Legend
class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor = const Color(0xff505050),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor))
      ],
    );
  }
}
