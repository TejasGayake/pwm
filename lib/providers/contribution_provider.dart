import 'dart:async';
import 'package:flutter/material.dart';
import '../models/contribution_model.dart';
import '../services/firestore_service.dart';

class ContributionProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  List<ContributionModel> _contributions = [];
  StreamSubscription<List<ContributionModel>>? _contributionsSubscription;

  List<ContributionModel> get contributions => _contributions;
  double get totalContributed => _contributions.fold(0, (s, c) => s + c.amount);

  void listenToContributions(String tenderId) {
    _contributionsSubscription?.cancel();
    _contributionsSubscription =
        _firestore.getContributionsForTender(tenderId).listen((contributions) {
      _contributions = contributions;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _contributionsSubscription?.cancel();
    super.dispose();
  }

  Map<String, double> getInvestorTotals() {
    final totals = <String, double>{};
    for (final c in _contributions) {
      totals[c.investorId] = (totals[c.investorId] ?? 0) + c.amount;
    }
    return totals;
  }

  Future<String> addContribution(String tenderId, ContributionModel contribution) async {
    return await _firestore.addContribution(tenderId, contribution);
  }
}
