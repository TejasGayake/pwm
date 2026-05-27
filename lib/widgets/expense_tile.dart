import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  const ExpenseTile({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withOpacity(0.1),
          child: Text(ExpenseCategories.icon(expense.category), style: const TextStyle(fontSize: 20)),
        ),
        title: Text(formatIndianCurrency(expense.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(expense.description),
            Row(children: [
              Text(ExpenseCategories.displayName(expense.category), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              const SizedBox(width: 8),
              Text(formatDate(expense.date), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ]),
          ],
        ),
        trailing: expense.hasPhoto ? const Icon(Icons.photo, color: Colors.blue) : null,
      ),
    );
  }
}
