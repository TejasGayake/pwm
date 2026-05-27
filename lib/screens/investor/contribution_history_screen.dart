import 'package:flutter/material.dart';
import '../../models/contribution_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/formatters.dart';

class ContributionHistoryScreen extends StatelessWidget {
  final String tenderId;
  final String investorId;
  const ContributionHistoryScreen({super.key, required this.tenderId, required this.investorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Contributions')),
      body: StreamBuilder<List<ContributionModel>>(
        stream: FirestoreService().getContributionsForInvestor(tenderId, investorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final contributions = snapshot.data ?? [];
          if (contributions.isEmpty) {
            return Center(child: Text('No contributions found', style: TextStyle(color: Colors.grey[600])));
          }
          final total = contributions.fold(0.0, (s, c) => s + c.amount);
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Contributed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(formatIndianCurrency(total), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: contributions.length,
                  itemBuilder: (context, index) {
                    final c = contributions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(formatIndianCurrency(c.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(formatDate(c.date)),
                        trailing: c.bankReference.isNotEmpty ? Chip(label: Text(c.bankReference, style: const TextStyle(fontSize: 10))) : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
