import 'package:flutter/material.dart';
import '../models/contribution_model.dart';
import '../models/expense_model.dart';
import '../services/equity_calculator.dart';
import '../services/firestore_service.dart';

class FinancialProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  List<ContributionModel> _contributions = [];
  List<ExpenseModel> _expenses = [];
  Map<String, double> _categoryTotals = {};

  List<ContributionModel> get contributions => _contributions;
  List<ExpenseModel> get expenses => _expenses;
  Map<String, double> get categoryTotals => _categoryTotals;
  List<EquitySlice> get equitySlices => _equitySlices;
  FinancialSummary? get summary => _summary;
  double get totalInvested => _contributions.fold(0, (s, c) => s + c.amount);
  double get totalSpent => _expenses.fold(0, (s, e) => s + e.amount);

  List<EquitySlice> _equitySlices = [];
  FinancialSummary? _summary;

  void listenToTenderFinancials(String tenderId, double targetAmount, DateTime startDate) {
    _firestore.getContributionsForTender(tenderId).listen((contributions) {
      _contributions = contributions;
      _recalculate(targetAmount, startDate, tenderId);
    });

    _firestore.getExpensesForTender(tenderId).listen((expenses) {
      _expenses = expenses;
      _recalculate(targetAmount, startDate, tenderId);
    });
  }

  Future<void> _recalculate(double targetAmount, DateTime startDate, String tenderId) async {
    _summary = EquityCalculator.computeSummary(
      targetAmount: targetAmount,
      contributions: _contributions,
      expenses: _expenses,
      startDate: startDate,
    );

    _categoryTotals = {};
    for (final e in _expenses) {
      _categoryTotals[e.category] = (_categoryTotals[e.category] ?? 0) + e.amount;
    }

    final investors = await _firestore.getInvestorsForTender(tenderId).first;
    _equitySlices = EquityCalculator.getEquitySlices(
      investors: investors,
      contributions: _contributions,
    );

    notifyListeners();
  }

  Future<String> addContribution(String tenderId, ContributionModel contribution) async {
    return await _firestore.addContribution(tenderId, contribution);
  }

  Future<String> addExpense(String tenderId, ExpenseModel expense) async {
    return await _firestore.addExpense(tenderId, expense);
  }
}
