import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tender_provider.dart';
import '../../widgets/tender_card.dart';
import '../auth/login_screen.dart';

class InvestorDashboard extends StatelessWidget {
  const InvestorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final tenderProvider = Provider.of<TenderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Investments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
              }
            },
          ),
        ],
      ),
      body: tenderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : tenderProvider.tenders.isEmpty
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('No investments yet', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Text('You will see tenders here once an engineer adds you as an investor', style: TextStyle(color: Colors.grey[500]), textAlign: TextAlign.center),
                  ],
                ))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tenderProvider.tenders.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TenderCard(tender: tenderProvider.tenders[index], showInvestorInfo: true),
                  ),
                ),
    );
  }
}
