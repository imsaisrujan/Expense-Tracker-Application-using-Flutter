import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const ExpenseTracker(),
    );
  }
}

class Expense {
  final String id;
  final String name;
  final double amount;
  final DateTime date;
  final String? category;

  Expense({
    String? id,
    required this.name,
    required this.amount,
    required this.date,
    this.category,
  }) : id = id ?? DateTime.now().toString();
}

class BudgetDisplay extends StatelessWidget {
  final double budget;
  final double totalExpenses;

  const BudgetDisplay({
    Key? key,
    required this.budget,
    required this.totalExpenses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double remainingBudget = budget - totalExpenses;
    double percentage = budget > 0 ? (totalExpenses / budget * 100).clamp(0, 100) : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget Overview',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '₹$budget',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                remainingBudget >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: ₹$totalExpenses',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'Remaining: ₹$remainingBudget',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: remainingBudget >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController amountController;
  final DateTime selectedDate;
  final Function() onDateSelect;
  final Function() onSubmit;

  const ExpenseForm({
    Key? key,
    required this.nameController,
    required this.amountController,
    required this.selectedDate,
    required this.onDateSelect,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Expense Name',
                prefixIcon: const Icon(Icons.shopping_cart),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onDateSelect,
              icon: const Icon(Icons.calendar_today),
              label: Text(DateFormat.yMMMd().format(selectedDate)),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseTracker extends StatefulWidget {
  const ExpenseTracker({Key? key}) : super(key: key);

  @override
  _ExpenseTrackerState createState() => _ExpenseTrackerState();
}

class _ExpenseTrackerState extends State<ExpenseTracker> {
  final List<Expense> _expenses = [];
  final _expenseNameController = TextEditingController();
  final _expenseAmountController = TextEditingController();
  final _budgetController = TextEditingController();
  double _totalExpenses = 0;
  double _budget = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _expenseNameController.dispose();
    _expenseAmountController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _addExpense() {
    if (!_validateExpenseInput()) return;

    final expenseAmount = double.parse(_expenseAmountController.text);
    final newExpense = Expense(
      name: _expenseNameController.text,
      amount: expenseAmount,
      date: _selectedDate,
    );

    setState(() {
      _expenses.add(newExpense);
      _calculateTotalExpenses();
      _clearExpenseForm();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense added successfully')),
    );
  }

  bool _validateExpenseInput() {
    if (_budget == 0) {
      _showAlert('No Budget Set', 'Please set a budget before adding expenses.');
      return false;
    }

    if (_expenseNameController.text.isEmpty || _expenseAmountController.text.isEmpty) {
      _showAlert('Invalid Input', 'Please enter both the expense name and amount.');
      return false;
    }

    final expenseAmount = double.tryParse(_expenseAmountController.text);
    if (expenseAmount == null || expenseAmount <= 0) {
      _showAlert('Invalid Amount', 'Please enter a valid numeric amount.');
      return false;
    }

    return true;
  }

  void _removeExpense(String id) {
    setState(() {
      _expenses.removeWhere((expense) => expense.id == id);
      _calculateTotalExpenses();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense removed'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _setBudget() {
    if (!_validateBudgetInput()) return;

    setState(() {
      _budget = double.parse(_budgetController.text);
      _budgetController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Budget updated successfully')),
    );
  }

  bool _validateBudgetInput() {
    if (_budgetController.text.isEmpty) {
      _showAlert('Invalid Input', 'Please enter a budget amount.');
      return false;
    }

    final budgetAmount = double.tryParse(_budgetController.text);
    if (budgetAmount == null || budgetAmount <= 0) {
      _showAlert('Invalid Budget', 'Please enter a valid amount greater than zero.');
      return false;
    }

    return true;
  }

  void _calculateTotalExpenses() {
    _totalExpenses = _expenses.fold(0, (prev, exp) => prev + exp.amount);
  }

  void _clearExpenseForm() {
    _expenseNameController.clear();
    _expenseAmountController.clear();
    _selectedDate = DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showAlert(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  void _showBudgetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Budget'),
        content: TextField(
          controller: _budgetController,
          decoration: const InputDecoration(
            labelText: 'Budget Amount (₹)',
            prefixIcon: Icon(Icons.currency_rupee),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('SET'),
            onPressed: () {
              _setBudget();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.currency_rupee),
            label: const Text(
              'Add Budget',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: _showBudgetDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          BudgetDisplay(
            budget: _budget,
            totalExpenses: _totalExpenses,
          ),
          const SizedBox(height: 16),
          ExpenseForm(
            nameController: _expenseNameController,
            amountController: _expenseAmountController,
            selectedDate: _selectedDate,
            onDateSelect: () => _selectDate(context),
            onSubmit: _addExpense,
          ),
          const SizedBox(height: 16),
          if (_expenses.isEmpty)
            const Center(
              child: Text('No expenses yet. Add your first expense!'),
            )
          else
            ..._expenses.map((expense) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.receipt),
                ),
                title: Text(expense.name),
                subtitle: Text(
                  '₹${expense.amount} - ${DateFormat.yMMMd().format(expense.date)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeExpense(expense.id),
                ),
              ),
            )).toList(),
        ],
      ),
    );
  }
}