import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tender_provider.dart';
import '../../services/tender_service.dart';
import '../../models/tender_model.dart';
import '../../utils/helpers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/stat_card.dart';
import 'add_edit_tender_screen.dart';
import 'tender_list_screen.dart';
import 'tender_detail_screen.dart';
import '../auth/login_screen.dart';

class EngineerDashboard extends StatefulWidget {
  const EngineerDashboard({super.key});

  @override
  State<EngineerDashboard> createState() => _EngineerDashboardState();
}

class _EngineerDashboardState extends State<EngineerDashboard> {
  final TenderService _tenderService = TenderService();
  int _activeTenderCount = 0;
  double _totalInvested = 0;
  double _totalSpent = 0;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<TenderProvider>().listenToTenders(
              auth.user!.uid,
              'engineer',
            );
      }
    });
  }

  Future<void> _loadAggregateStats(List<TenderModel> tenders) async {
    double invested = 0;
    double spent = 0;
    int active = 0;
    for (final t in tenders) {
      if (t.status == 'active') active++;
      invested += await _tenderService.getTotalInvested(t.id!);
      spent += await _tenderService.getTotalSpent(t.id!);
    }
    if (mounted) {
      setState(() {
        _activeTenderCount = active;
        _totalInvested = invested;
        _totalSpent = spent;
        _loadingStats = false;
      });
    }
  }

  Future<void> _refresh() async {
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      context.read<TenderProvider>().listenToTenders(
            auth.user!.uid,
            'engineer',
          );
    }
  }

  void _logout() async {
    await context.read<AuthProvider>().signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenderProvider = context.watch<TenderProvider>();
    final tenders = tenderProvider.tenders;
    final activeTenders = tenderProvider.activeTenders;

    // Trigger aggregate stats loading when tenders change
    if (tenders.isNotEmpty && _loadingStats) {
      _loadAggregateStats(tenders);
    }
    if (tenders.isEmpty && !_loadingStats) {
      _loadingStats = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('PWD Tender Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppTheme.primaryBlue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.engineering, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'PWD Tender Manager',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('All Tenders'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TenderListScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
      body: tenderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'Active Tenders',
                            value: '$_activeTenderCount',
                            icon: Icons.work,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            label: 'Total Invested',
                            value: _loadingStats
                                ? '...'
                                : Helpers.formatCurrency(_totalInvested),
                            icon: Icons.trending_up,
                            color: AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: StatCard(
                        label: 'Total Spent',
                        value: _loadingStats
                            ? '...'
                            : Helpers.formatCurrency(_totalSpent),
                        icon: Icons.receipt_long,
                        color: AppTheme.warningOrange,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Active Tenders',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        if (activeTenders.length > 5)
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TenderListScreen(),
                              ),
                            ),
                            child: const Text('View All'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (activeTenders.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.work_off,
                                  size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No active tenders yet',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to create a new tender',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...activeTenders.take(5).map(
                            (t) => Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _statusColor(t.status),
                                  child: const Icon(Icons.account_balance,
                                      color: Colors.white),
                                ),
                                title: Text(
                                  t.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  '${t.location}  •  ${Helpers.formatCurrency(t.targetAmount)}',
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TenderDetailScreen(tender: t as dynamic),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditTenderScreen()),
        ),
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
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
}
