import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/expense_tile.dart';

class ExpenseListScreen extends StatelessWidget {
  final String tenderId;
  const ExpenseListScreen({super.key, required this.tenderId});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: expenseProvider.categoryFilter == 'all',
                onSelected: (_) => expenseProvider.setCategoryFilter('all'),
              ),
              const SizedBox(width: 8),
              ...ExpenseCategories.all.map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(ExpenseCategories.displayName(c)),
                  selected: expenseProvider.categoryFilter == c,
                  onSelected: (_) => expenseProvider.setCategoryFilter(c),
                ),
              )),
            ],
          ),
        ),
        Expanded(
          child: expenseProvider.expenses.isEmpty
              ? Center(child: Text('No expenses found', style: TextStyle(color: Colors.grey[600])))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: expenseProvider.expenses.length,
                  itemBuilder: (context, index) => ExpenseTile(expense: expenseProvider.expenses[index]),
                ),
        ),
      ],
    );
  }
}
