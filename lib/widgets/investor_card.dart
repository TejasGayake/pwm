import 'package:flutter/material.dart';
import '../models/investor_model.dart';
import '../utils/formatters.dart';

class InvestorCard extends StatelessWidget {
  final InvestorModel investor;
  final double totalContributed;
  final double equityPercent;

  const InvestorCard({super.key, required this.investor, this.totalContributed = 0, this.equityPercent = 0});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(investor.name.isNotEmpty ? investor.name[0].toUpperCase() : '?', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
        ),
        title: Text(investor.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (investor.phone.isNotEmpty) Text(investor.phone),
            if (investor.email.isNotEmpty) Text(investor.email, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            if (totalContributed > 0) Text(formatIndianCurrency(totalContributed), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.green[700])),
            if (equityPercent > 0) Text('${equityPercent.toStringAsFixed(1)}% equity', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
