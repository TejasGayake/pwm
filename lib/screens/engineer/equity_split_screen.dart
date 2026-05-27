import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/investor_model.dart';
import '../../models/contribution_model.dart';
import '../../services/tender_service.dart';
import '../../utils/helpers.dart';
import '../../utils/formatters.dart';
import '../../theme/app_theme.dart';

class EquitySplitScreen extends StatefulWidget {
  final String tenderId;
  final double targetAmount;
  const EquitySplitScreen({
    super.key,
    required this.tenderId,
    required this.targetAmount,
  });

  @override
  State<EquitySplitScreen> createState() => _EquitySplitScreenState();
}

class _EquitySplitScreenState extends State<EquitySplitScreen> {
  final TenderService _tenderService = TenderService();
  List<InvestorModel> _investors = [];
  List<ContributionModel> _contributions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final investors = await _tenderService.getInvestors(widget.tenderId);
    final contributions =
        await _tenderService.getContributions(widget.tenderId);
    if (mounted) {
      setState(() {
        _investors = investors;
        _contributions = contributions;
        _loading = false;
      });
    }
  }

  double get _totalInvested =>
      _contributions.fold(0, (s, c) => s + c.amount);

  Map<String, double> get _investorTotals {
    final totals = <String, double>{};
    for (final inv in _investors) {
      totals[inv.id!] = 0;
    }
    for (final c in _contributions) {
      totals[c.investorId] = (totals[c.investorId] ?? 0) + c.amount;
    }
    return totals;
  }

  Map<String, String> get _investorNames =>
      {for (final inv in _investors) inv.id!: inv.name};

  bool get _isOverFunded => _totalInvested > widget.targetAmount;

  static const List<Color> _colors = [
    Color(0xFF1565C0),
    Color(0xFF2E7D32),
    Color(0xFFEF6C00),
    Color(0xFFC62828),
    Color(0xFF6A1B9A),
    Color(0xFF00838F),
    Color(0xFF4E342E),
    Color(0xFF37474F),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equity Split')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _totalInvested <= 0
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pie_chart_outline,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No contributions recorded yet',
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_isOverFunded) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning,
                                  color: Colors.orange),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Over-funded! Invested (${Helpers.formatCurrency(_totalInvested)}) exceeds target (${Helpers.formatCurrency(widget.targetAmount)}) by ${Helpers.formatCurrency(_totalInvested - widget.targetAmount)}',
                                  style: const TextStyle(
                                      color: Colors.orange),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Equity Distribution',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 220,
                                child: _buildPieChart(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Investor Details',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),
                              // Table header
                              const Row(
                                children: [
                                  SizedBox(width: 28),
                                  Expanded(
                                    flex: 3,
                                    child: Text('Investor',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('Amount',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('Equity %',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey)),
                                  ),
                                ],
                              ),
                              const Divider(),
                              ..._buildLegendRows(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPieChart() {
    final totals = _investorTotals;
    final entries = totals.entries.where((e) => e.value > 0).toList();

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: List.generate(
                entries.length,
                (i) => PieChartSectionData(
                  value: entries[i].value,
                  color: _colors[i % _colors.length],
                  title:
                      '${((entries[i].value / _totalInvested) * 100).toStringAsFixed(1)}%',
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  radius: 60,
                ),
              ),
              sectionsSpace: 2,
              centerSpaceRadius: 30,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            entries.length,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    color: _colors[i % _colors.length],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _investorNames[entries[i].key] ?? entries[i].key,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildLegendRows() {
    final totals = _investorTotals;
    final entries = totals.entries.where((e) => e.value > 0).toList();

    return List.generate(entries.length, (i) {
      final name = _investorNames[entries[i].key] ?? entries[i].key;
      final amount = entries[i].value;
      final percent = (amount / _totalInvested) * 100;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _colors[i % _colors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            Expanded(
              flex: 2,
              child: Text(
                Helpers.formatCurrency(amount),
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                formatPercentage(percent),
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    });
  }
}
