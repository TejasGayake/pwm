import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/tender_model.dart';
import '../../providers/financial_provider.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/equity_pie_chart.dart';
import '../../widgets/burn_rate_chart.dart';
import '../../widgets/expense_category_chart.dart';
import '../../utils/formatters.dart';

class FinancialOverviewScreen extends StatelessWidget {
  final TenderModel tender;
  const FinancialOverviewScreen({super.key, required this.tender});

  @override
  Widget build(BuildContext context) {
    final financial = Provider.of<FinancialProvider>(context);
    final summary = financial.summary;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          Expanded(child: SummaryCard(icon: Icons.flag, label: 'Target', value: formatIndianCurrency(tender.targetAmount), color: Colors.blue)),
          const SizedBox(width: 12),
          Expanded(child: SummaryCard(icon: Icons.trending_up, label: 'Invested', value: formatIndianCurrency(summary?.totalInvested ?? 0), color: Colors.green)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: SummaryCard(icon: Icons.receipt, label: 'Spent', value: formatIndianCurrency(summary?.totalSpent ?? 0), color: Colors.orange)),
          const SizedBox(width: 12),
          Expanded(child: SummaryCard(icon: Icons.speed, label: 'Burn/Day', value: formatIndianCurrency(summary?.burnRate ?? 0), color: Colors.red)),
        ]),
        const SizedBox(height: 24),
        if (summary?.isOverFunded ?? false)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(child: Text('Over-funded by ${formatIndianCurrency((summary!.totalInvested) - tender.targetAmount)}', style: const TextStyle(fontWeight: FontWeight.w600))),
            ]),
          ),
        const SizedBox(height: 24),
        if (financial.equitySlices.isNotEmpty) ...[
          const Text('Equity Split', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          EquityPieChart(slices: financial.equitySlices),
          const SizedBox(height: 24),
        ],
        if (financial.categoryTotals.isNotEmpty) ...[
          const Text('Expense Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ExpenseCategoryChart(categoryTotals: financial.categoryTotals),
          const SizedBox(height: 24),
        ],
        const Text('Daily Burn Rate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const BurnRateChart(),
      ],
    );
  }
}
