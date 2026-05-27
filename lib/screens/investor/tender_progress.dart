import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/tender_model.dart';
import '../../providers/investor_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';
import '../../utils/formatters.dart';
import '../../theme/app_theme.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/equity_pie_chart.dart';

class TenderProgress extends StatefulWidget {
  final TenderModel tender;
  const TenderProgress({super.key, required this.tender});
  @override
  State<TenderProgress> createState() => _TenderProgressState();
}

class _TenderProgressState extends State<TenderProgress> {
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => context.read<InvestorProvider>().loadTenderData(widget.tender.id!)); }

  @override
  Widget build(BuildContext context) {
    final inv = context.watch<InvestorProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(widget.tender.name)),
      body: inv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: StatCard(label: 'Target', value: formatIndianCurrency(widget.tender.targetAmount), icon: Icons.flag, color: AppTheme.primaryBlue)),
                    const SizedBox(width: 12),
                    Expanded(child: StatCard(label: 'Invested', value: formatIndianCurrency(inv.totalInvested), icon: Icons.trending_up, color: AppTheme.successGreen)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: StatCard(label: 'Spent', value: formatIndianCurrency(inv.totalSpent), icon: Icons.receipt_long, color: AppTheme.warningOrange)),
                    const SizedBox(width: 12),
                    Expanded(child: StatCard(label: 'Remaining', value: formatIndianCurrency(inv.remaining), icon: Icons.account_balance_wallet, color: inv.remaining < 0 ? AppTheme.dangerRed : AppTheme.primaryBlue)),
                  ]),
                  const SizedBox(height: 24),
                  const Text('Expense Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (inv.expenses.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No expenses recorded yet')))
                  else
                    SizedBox(height: 200, child: EquityPieChart(slices: inv.equitySlices)),
                  const SizedBox(height: 24),
                  const Text('Contributions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...inv.contributions.map((c) => ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.payments)),
                    title: Text(c.investorName),
                    subtitle: Text(Helpers.formatDate(c.date)),
                    trailing: Text(Helpers.formatCurrency(c.amount), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successGreen)),
                  )),
                ],
              ),
            ),
    );
  }
}
