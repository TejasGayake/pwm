import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import '../screens/engineer/dashboard_screen.dart';
import '../screens/investor/investor_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryAutoLogin();
    });
  }

  Future<void> _tryAutoLogin() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (auth.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.engineering, size: 80, color: Theme.of(context).primaryColor),
              const SizedBox(height: 24),
              const Text('PWD Tender Manager', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    // Skip login for development - go directly to EngineerDashboard
    return const EngineerDashboard();

    // Original flow (uncomment to restore):
    // if (!auth.isLoggedIn) return const LoginScreen();
    // if (auth.isEngineer) return const EngineerDashboard();
    // if (auth.isInvestor) return const InvestorDashboard();
    // return const LoginScreen();
  }
}
