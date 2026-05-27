import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/tender_model.dart';
import '../../models/investor_model.dart';
import '../../models/contribution_model.dart';
import '../../models/expense_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tender_provider.dart';
import '../../services/tender_service.dart';
import '../../services/equity_calculator.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/formatters.dart';
import '../../theme/app_theme.dart';
import '../../widgets/investor_card.dart';
import '../../widgets/expense_tile.dart';
import 'add_edit_tender_screen.dart';
import 'investor_list_screen.dart';
import 'expense_list_screen.dart';
import 'add_expense_screen.dart';
import 'equity_split_screen.dart';
import 'financial_overview_screen.dart';

class TenderDetailScreen extends StatefulWidget {
  final TenderModel tender;
  const TenderDetailScreen({super.key, required this.tender});

  @override
  State<TenderDetailScreen> createState() => _TenderDetailScreenState();
}

class _TenderDetailScreenState extends State<TenderDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TenderService _tenderService = TenderService();

  List<InvestorModel> _investors = [];
  List<ContributionModel> _contributions = [];
  List<ExpenseModel> _expenses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final investors = await _tenderService.getInvestors(widget.tender.id!);
    final contributions =
        await _tenderService.getContributions(widget.tender.id!);
    final expenses = await _tenderService.getExpenses(widget.tender.id!);
    if (mounted) {
      setState(() {
        _investors = investors;
        _contributions = contributions;
        _expenses = expenses;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double get _totalInvested =>
      _contributions.fold(0, (s, c) => s + c.amount);
  double get _totalSpent => _expenses.fold(0, (s, e) => s + e.amount);
  double get _remaining => _totalInvested - _totalSpent;

  Map<String, double> get _equityMap {
    final totals = <String, double>{};
    for (final c in _contributions) {
      totals[c.investorId] = (totals[c.investorId] ?? 0) + c.amount;
    }
    return totals;
  }

  Map<String, String> get _investorNames {
    return {for (final inv in _investors) inv.id!: inv.name};
  }

  Map<String, double> get _investorEquityPercentages {
    final map = <String, double>{};
    if (_totalInvested <= 0) return map;
    for (final entry in _equityMap.entries) {
      map[entry.key] = (entry.value / _totalInvested) * 100;
    }
    return map;
  }

  Map<String, double> get _categoryTotals {
    final totals = <String, double>{};
    for (final e in _expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  Future<void> _deleteTender() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Tender'),
        content:
            const Text('Are you sure you want to delete this tender? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await context.read<TenderProvider>().deleteTender(widget.tender.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tender.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddEditTenderScreen(tender: widget.tender),
                  ),
                ).then((_) => _loadData());
              } else if (value == 'delete') {
                _deleteTender();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Investors'),
            Tab(text: 'Expenses'),
            Tab(text: 'Financials'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildInvestorsTab(),
                _buildExpensesTab(),
                _buildFinancialsTab(),
              ],
            ),
    );
  }

  // ==================== OVERVIEW TAB ====================
  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tender.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _infoRow(Icons.location_on, widget.tender.location),
                  const SizedBox(height: 4),
                  _infoRow(Icons.flag,
                      'Target: ${Helpers.formatCurrency(widget.tender.targetAmount)}'),
                  const SizedBox(height: 4),
                  _infoRow(
                    Icons.calendar_today,
                    '${Helpers.formatDate(widget.tender.startDate)} - ${Helpers.formatDate(widget.tender.endDate)}',
                  ),
                  const SizedBox(height: 12),
                  Chip(
                    label: Text(
                      widget.tender.status.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        color: _statusTextColor(widget.tender.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: _statusBgColor(widget.tender.status),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statBox(
                  'Total Invested',
                  Helpers.formatCurrency(_totalInvested),
                  AppTheme.successGreen,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statBox(
                  'Total Spent',
                  Helpers.formatCurrency(_totalSpent),
                  AppTheme.warningOrange,
                  Icons.receipt_long,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _statBox(
            'Remaining',
            Helpers.formatCurrency(_remaining),
            _remaining < 0 ? AppTheme.dangerRed : AppTheme.primaryBlue,
            Icons.account_balance_wallet,
          ),
          if (_totalInvested > widget.tender.targetAmount) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Over-funded! Invested amount exceeds target by ${Helpers.formatCurrency(_totalInvested - widget.tender.targetAmount)}',
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== INVESTORS TAB ====================
  Widget _buildInvestorsTab() {
    return Scaffold(
      body: _investors.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No investors added',
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _investors.length,
              itemBuilder: (context, index) {
                final inv = _investors[index];
                final totalContributed = _equityMap[inv.id!] ?? 0;
                final equityPercent =
                    _investorEquityPercentages[inv.id!] ?? 0;
                return InvestorCard(
                  investor: inv,
                  totalContributed: totalContributed,
                  equityPercent: equityPercent,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InvestorListScreen(tenderId: widget.tender.id!),
          ),
        ).then((_) => _loadData()),
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  // ==================== EXPENSES TAB ====================
  String _expenseFilter = 'all';

  Widget _buildExpensesTab() {
    final filtered = _expenseFilter == 'all'
        ? _expenses
        : _expenses.where((e) => e.category == _expenseFilter).toList();

    return Column(
      children: [
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _expenseFilterChip('All', 'all'),
              ...AppConstants.expenseCategories.map(
                (cat) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _expenseFilterChip(cat, cat),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No expenses recorded',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey[600])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      ExpenseTile(expense: filtered[index]),
                ),
        ),
      ],
    );
  }

  Widget _expenseFilterChip(String label, String value) {
    final isSelected = _expenseFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _expenseFilter = value),
      selectedColor: AppTheme.primaryBlue.withOpacity(0.15),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryBlue : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  // ==================== FINANCIALS TAB ====================
  Widget _buildFinancialsTab() {
    final equityMap = _equityMap;
    final investorNames = _investorNames;
    final daysElapsed =
        DateTime.now().difference(widget.tender.startDate).inDays.clamp(1, 999999);
    final burnRate = _totalSpent / daysElapsed;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Equity Split',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (equityMap.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No contributions recorded yet'),
            ),
          )
        else
          _buildEquityPieChart(equityMap, investorNames),
        const SizedBox(height: 24),
        const Text('Expense Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (_categoryTotals.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No expenses recorded yet'),
            ),
          )
        else
          _buildCategoryPieChart(),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Burn Rate',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.speed, color: AppTheme.warningOrange),
                    const SizedBox(width: 8),
                    Text(
                      '${Helpers.formatCurrency(burnRate)} / day',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${daysElapsed} days since start',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEquityPieChart(
      Map<String, double> equityMap, Map<String, String> investorNames) {
    final entries = equityMap.entries.toList();
    const colors = [
      Color(0xFF1565C0),
      Color(0xFF2E7D32),
      Color(0xFFEF6C00),
      Color(0xFFC62828),
      Color(0xFF6A1B9A),
      Color(0xFF00838F),
      Color(0xFF4E342E),
      Color(0xFF37474F),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: List.generate(
                      entries.length,
                      (i) => PieChartSectionData(
                        value: entries[i].value,
                        color: colors[i % colors.length],
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
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          color: colors[i % colors.length],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          investorNames[entries[i].key] ?? entries[i].key,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart() {
    final entries = _categoryTotals.entries.toList();
    const colors = [
      Color(0xFF1565C0),
      Color(0xFF2E7D32),
      Color(0xFFEF6C00),
      Color(0xFFC62828),
      Color(0xFF6A1B9A),
      Color(0xFF00838F),
      Color(0xFF4E342E),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: List.generate(
                      entries.length,
                      (i) => PieChartSectionData(
                        value: entries[i].value,
                        color: colors[i % colors.length],
                        title:
                            '${((entries[i].value / _totalSpent) * 100).toStringAsFixed(1)}%',
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
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          color: colors[i % colors.length],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${AppConstants.expenseCategoryIcons[entries[i].key] ?? ''} ${entries[i].key}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== HELPERS ====================
  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }

  Widget _statBox(String label, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(label,
                    style:
                        TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'on_hold':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green.shade100;
      case 'completed':
        return Colors.blue.shade100;
      case 'on_hold':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green.shade800;
      case 'completed':
        return Colors.blue.shade800;
      case 'on_hold':
        return Colors.orange.shade800;
      default:
        return Colors.grey.shade800;
    }
  }
}
