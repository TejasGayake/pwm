import 'package:flutter/material.dart';
import '../models/contribution_model.dart';
import '../utils/formatters.dart';

class ContributionTile extends StatelessWidget {
  final ContributionModel contribution;
  const ContributionTile({super.key, required this.contribution});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.1),
          child: const Icon(Icons.arrow_upward, color: Colors.green),
        ),
        title: Text(formatIndianCurrency(contribution.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contribution.investorName),
            Text(formatDate(contribution.date), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
        trailing: contribution.bankReference.isNotEmpty
            ? Chip(label: Text(contribution.bankReference, style: const TextStyle(fontSize: 10)))
            : null,
      ),
    );
  }
}
