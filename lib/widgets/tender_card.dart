import 'package:flutter/material.dart';
import '../models/tender_model.dart';
import '../utils/formatters.dart';
import '../screens/engineer/tender_detail_screen.dart';
import '../screens/investor/tender_detail_investor_view.dart';

class TenderCard extends StatelessWidget {
  final TenderModel tender;
  final bool showInvestorInfo;

  const TenderCard({super.key, required this.tender, this.showInvestorInfo = false});

  Color _statusColor() {
    switch (tender.status) {
      case 'active': return Colors.green;
      case 'completed': return Colors.blue;
      case 'on_hold': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => showInvestorInfo
                ? TenderDetailInvestorView(tender: tender)
                : TenderDetailScreen(tender: tender),
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(tender.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: _statusColor().withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(tender.status.toUpperCase(), style: TextStyle(color: _statusColor(), fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(tender.location, style: TextStyle(color: Colors.grey[600])),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.flag, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Target: ${formatIndianCurrency(tender.targetAmount)}', style: TextStyle(color: Colors.grey[600])),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${formatDateShort(tender.startDate)} - ${formatDateShort(tender.endDate)}', style: TextStyle(color: Colors.grey[600])),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
