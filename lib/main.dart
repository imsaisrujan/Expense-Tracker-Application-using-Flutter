import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final String category;

  Expense({
    String? id,
    required this.name,
    required this.amount,
    required this.date,
    required this.category,
  }) : id = id ?? DateTime.now().toString();
}

class ExpenseCategories {
  static const List<String> categories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Travel',
    'Groceries',
    'Other',
  ];

  static const Map<String, IconData> categoryIcons = {
    'Food & Dining': Icons.restaurant,
    'Transportation': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Entertainment': Icons.movie,
    'Bills & Utilities': Icons.receipt_long,
    'Healthcare': Icons.local_hospital,
    'Education': Icons.school,
    'Travel': Icons.flight,
    'Groceries': Icons.local_grocery_store,
    'Other': Icons.category,
  };

  static const Map<String, Color> categoryColors = {
    'Food & Dining': Colors.orange,
    'Transportation': Colors.blue,
    'Shopping': Colors.purple,
    'Entertainment': Colors.red,
    'Bills & Utilities': Colors.green,
    'Healthcare': Colors.pink,
    'Education': Colors.indigo,
    'Travel': Colors.teal,
    'Groceries': Colors.brown,
    'Other': Colors.grey,
  };
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
                  '₹${budget.toStringAsFixed(0)}',
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
                  'Spent: ₹${totalExpenses.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'Remaining: ₹${remainingBudget.toStringAsFixed(0)}',
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
  final String selectedCategory;
  final Function() onDateSelect;
  final Function(String?) onCategoryChanged;
  final Function() onSubmit;

  const ExpenseForm({
    Key? key,
    required this.nameController,
    required this.amountController,
    required this.selectedDate,
    required this.selectedCategory,
    required this.onDateSelect,
    required this.onCategoryChanged,
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
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(ExpenseCategories.categoryIcons[selectedCategory]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: ExpenseCategories.categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Row(
                    children: [
                      Icon(
                        ExpenseCategories.categoryIcons[category],
                        color: ExpenseCategories.categoryColors[category],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(category),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onCategoryChanged,
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

class FilterSortBar extends StatelessWidget {
  final String selectedCategory;
  final String sortBy;
  final DateTimeRange? dateRange;
  final Function(String?) onCategoryFilter;
  final Function(String) onSortChanged;
  final Function() onDateRangeSelect;
  final Function() onClearFilters;

  const FilterSortBar({
    Key? key,
    required this.selectedCategory,
    required this.sortBy,
    required this.dateRange,
    required this.onCategoryFilter,
    required this.onSortChanged,
    required this.onDateRangeSelect,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Category',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: 'All',
                        child: Text('All Categories'),
                      ),
                      ...ExpenseCategories.categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                    ],
                    onChanged: onCategoryFilter,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: sortBy,
                    decoration: const InputDecoration(
                      labelText: 'Sort by',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'date_desc', child: Text('Date (Newest)')),
                      DropdownMenuItem(value: 'date_asc', child: Text('Date (Oldest)')),
                      DropdownMenuItem(value: 'amount_desc', child: Text('Amount (High)')),
                      DropdownMenuItem(value: 'amount_asc', child: Text('Amount (Low)')),
                      DropdownMenuItem(value: 'name', child: Text('Name (A-Z)')),
                    ],
                    onChanged: (String? value) => onSortChanged(value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDateRangeSelect,
                    icon: const Icon(Icons.date_range, size: 18),
                    label: Text(
                      dateRange != null 
                        ? '${DateFormat.MMMd().format(dateRange!.start)} - ${DateFormat.MMMd().format(dateRange!.end)}'
                        : 'Select Date Range',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Clear', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatisticsPage extends StatelessWidget {
  final List<Expense> expenses;

  const StatisticsPage({Key? key, required this.expenses}) : super(key: key);

  Map<String, double> getCategoryTotals() {
    Map<String, double> categoryTotals = {};
    for (var expense in expenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }

  Map<String, double> getMonthlyTotals() {
    Map<String, double> monthlyTotals = {};
    for (var expense in expenses) {
      String monthKey = DateFormat.yMMM().format(expense.date);
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + expense.amount;
    }
    return monthlyTotals;
  }

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Statistics')),
        body: const Center(child: Text('No expenses to analyze')),
      );
    }

    final categoryTotals = getCategoryTotals();
    final monthlyTotals = getMonthlyTotals();
    final totalAmount = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final avgExpense = totalAmount / expenses.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Summary', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Expenses: ₹${totalAmount.toStringAsFixed(0)}'),
                      Text('Count: ${expenses.length}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Average: ₹${avgExpense.toStringAsFixed(0)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Category Breakdown
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category Breakdown', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...categoryTotals.entries.map((entry) {
                    double percentage = (entry.value / totalAmount) * 100;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            ExpenseCategories.categoryIcons[entry.key],
                            color: ExpenseCategories.categoryColors[entry.key],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(entry.key),
                                    Text('₹${entry.value.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)'),
                                  ],
                                ),
                                LinearProgressIndicator(
                                  value: percentage / 100,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ExpenseCategories.categoryColors[entry.key] ?? Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Monthly Breakdown
          if (monthlyTotals.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monthly Breakdown', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    ...monthlyTotals.entries.map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key),
                          Text('₹${entry.value.toStringAsFixed(0)}'),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ),
        ],
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
  String _selectedCategory = ExpenseCategories.categories.first;
  
  // Filter and Sort variables
  String _filterCategory = 'All';
  String _sortBy = 'date_desc';
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _expenseNameController.dispose();
    _expenseAmountController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  List<Expense> get _filteredAndSortedExpenses {
    List<Expense> filtered = _expenses.where((expense) {
      bool categoryMatch = _filterCategory == 'All' || expense.category == _filterCategory;
      bool dateMatch = _dateRange == null || 
          (expense.date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
           expense.date.isBefore(_dateRange!.end.add(const Duration(days: 1))));
      return categoryMatch && dateMatch;
    }).toList();

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'date_desc':
          return b.date.compareTo(a.date);
        case 'date_asc':
          return a.date.compareTo(b.date);
        case 'amount_desc':
          return b.amount.compareTo(a.amount);
        case 'amount_asc':
          return a.amount.compareTo(b.amount);
        case 'name':
          return a.name.compareTo(b.name);
        default:
          return b.date.compareTo(a.date);
      }
    });

    return filtered;
  }

  void _addExpense() {
    if (!_validateExpenseInput()) return;

    final expenseAmount = double.parse(_expenseAmountController.text);
    final newExpense = Expense(
      name: _expenseNameController.text,
      amount: expenseAmount,
      date: _selectedDate,
      category: _selectedCategory,
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
    _selectedCategory = ExpenseCategories.categories.first;
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

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  void _clearFilters() {
    setState(() {
      _filterCategory = 'All';
      _sortBy = 'date_desc';
      _dateRange = null;
    });
  }

  Future<void> _exportToCSV() async {
    if (_expenses.isEmpty) {
      _showAlert('No Data', 'No expenses to export.');
      return;
    }

    try {
      String csv = 'Date,Name,Category,Amount\n';
      for (var expense in _expenses) {
        csv += '${DateFormat('yyyy-MM-dd').format(expense.date)},${expense.name},${expense.category},${expense.amount}\n';
      }

      // Copy CSV data to clipboard since we can't write files without external packages
      await Clipboard.setData(ClipboardData(text: csv));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CSV data copied to clipboard! You can paste it into a spreadsheet app.'),
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      _showAlert('Export Error', 'Failed to export expenses: $e');
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
    final filteredExpenses = _filteredAndSortedExpenses;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StatisticsPage(expenses: _expenses),
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'budget':
                  _showBudgetDialog();
                  break;
                case 'export':
                  _exportToCSV();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'budget',
                child: Row(
                  children: [
                    Icon(Icons.currency_rupee),
                    SizedBox(width: 8),
                    Text('Set Budget'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Copy CSV'),
                  ],
                ),
              ),
            ],
          ),
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
            selectedCategory: _selectedCategory,
            onDateSelect: () => _selectDate(context),
            onCategoryChanged: (value) => setState(() => _selectedCategory = value!),
            onSubmit: _addExpense,
          ),
          const SizedBox(height: 16),
          FilterSortBar(
            selectedCategory: _filterCategory,
            sortBy: _sortBy,
            dateRange: _dateRange,
            onCategoryFilter: (value) => setState(() => _filterCategory = value!),
            onSortChanged: (value) => setState(() => _sortBy = value),
            onDateRangeSelect: _selectDateRange,
            onClearFilters: _clearFilters,
          ),
          const SizedBox(height: 16),
          if (filteredExpenses.isEmpty)
            Center(
              child: Text(
                _expenses.isEmpty 
                  ? 'No expenses yet. Add your first expense!'
                  : 'No expenses match your filters.',
              ),
            )
          else
            ...filteredExpenses.map((expense) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: ExpenseCategories.categoryColors[expense.category]?.withOpacity(0.2),
                  child: Icon(
                    ExpenseCategories.categoryIcons[expense.category],
                    color: ExpenseCategories.categoryColors[expense.category],
                  ),
                ),
                title: Text(expense.name),
                subtitle: Text(
                  '${expense.category} • ${DateFormat.yMMMd().format(expense.date)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹${expense.amount.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeExpense(expense.id),
                    ),
                  ],
                ),
              ),
            )).toList(),
        ],
      ),
    );
  }
}
