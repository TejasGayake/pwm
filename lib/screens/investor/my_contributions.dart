import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/investor_provider.dart';
import '../../utils/helpers.dart';
import '../../utils/formatters.dart';
import '../../theme/app_theme.dart';

class MyContributions extends StatelessWidget {
  final String tenderId;
  const MyContributions({super.key, required this.tenderId});

  @override
  Widget build(BuildContext context) {
    final inv = context.watch<InvestorProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('My Contributions')),
      body: inv.contributions.isEmpty
          ? const Center(child: Text('No contributions yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: inv.contributions.length,
              itemBuilder: (ctx, i) {
                final c = inv.contributions[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: AppTheme.successGreen, child: Icon(Icons.payments, color: Colors.white)),
                    title: Text(Helpers.formatCurrency(c.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${Helpers.formatDate(c.date)} • Ref: ${c.bankReference}'),
                    trailing: c.receiptPhotoUrl != null ? const Icon(Icons.photo, color: AppTheme.primaryBlue) : null,
                  ),
                );
              },
            ),
    );
  }
}
