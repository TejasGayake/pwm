import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tender_model.dart';
import '../../providers/financial_provider.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/equity_pie_chart.dart';
import '../../utils/formatters.dart';

class TenderDetailInvestorView extends StatelessWidget {
  final TenderModel tender;
  const TenderDetailInvestorView({super.key, required this.tender});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FinancialProvider()..listenToTenderFinancials(
        tender.id!, tender.targetAmount, tender.startDate,
      ),
      child: Scaffold(
        appBar: AppBar(title: Text(tender.name)),
        body: Consumer<FinancialProvider>(
          builder: (context, financial, _) {
            final summary = financial.summary;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tender.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(children: [const Icon(Icons.location_on, size: 16), const SizedBox(width: 4), Text(tender.location)]),
                        const SizedBox(height: 4),
                        Row(children: [const Icon(Icons.calendar_today, size: 16), const SizedBox(width: 4), Text('${formatDate(tender.startDate)} - ${formatDate(tender.endDate)}')]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: SummaryCard(icon: Icons.flag, label: 'Target', value: formatIndianCurrency(tender.targetAmount), color: Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: SummaryCard(icon: Icons.trending_up, label: 'Total Invested', value: formatIndianCurrency(summary?.totalInvested ?? 0), color: Colors.green)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: SummaryCard(icon: Icons.receipt, label: 'Total Spent', value: formatIndianCurrency(summary?.totalSpent ?? 0), color: Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(child: SummaryCard(icon: Icons.account_balance_wallet, label: 'Remaining', value: formatIndianCurrency(summary?.remainingBalance ?? 0), color: (summary?.remainingBalance ?? 0) >= 0 ? Colors.green : Colors.red)),
                ]),
                const SizedBox(height: 24),
                if (financial.equitySlices.isNotEmpty) ...[
                  const Text('Equity Split', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  EquityPieChart(slices: financial.equitySlices),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
