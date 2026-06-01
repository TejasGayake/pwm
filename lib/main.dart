import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/tender_provider.dart';
import 'providers/contribution_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/financial_provider.dart';
import 'providers/investor_provider.dart';
import 'screens/splash_screen.dart';

/// Global: holds the path of a shared image waiting to be consumed
/// by AddContributionScreen. Set by the share intent listener, cleared
/// once AddContributionScreen picks it up.
String? pendingSharedImagePath;

final _sharingIntent = ReceiveSharingIntent.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Cold start: check if the app was launched via a share intent
  try {
    final initialFiles = await _sharingIntent.getInitialMedia();
    if (initialFiles.isNotEmpty) {
      pendingSharedImagePath = initialFiles.first.path;
    }
  } catch (_) {
    // Plugin may throw if no intent; ignore
  }

  runApp(const PwmApp());
}

class PwmApp extends StatefulWidget {
  const PwmApp({super.key});

  @override
  State<PwmApp> createState() => _PwmAppState();
}

class _PwmAppState extends State<PwmApp> {
  StreamSubscription? _intentSub;

  @override
  void initState() {
    super.initState();
    // Warm start: listen for shared files while the app is already running
    _intentSub = _sharingIntent.getMediaStream().listen(
      (files) {
        if (files.isNotEmpty) {
          setState(() {
            pendingSharedImagePath = files.first.path;
          });
        }
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _intentSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TenderProvider()),
        ChangeNotifierProvider(create: (_) => ContributionProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => FinancialProvider()),
        ChangeNotifierProvider(create: (_) => InvestorProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'PWD Tender Manager',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
