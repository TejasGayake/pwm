import 'package:flutter/material.dart';
import '../models/investor_model.dart';
import '../models/contribution_model.dart';
import '../models/expense_model.dart';
import '../services/tender_service.dart';
import '../services/equity_calculator.dart';

export '../services/equity_calculator.dart' show EquitySlice;

class InvestorProvider extends ChangeNotifier {
  final TenderService _service = TenderService();
  List<InvestorModel> _investors = [];
  List<ContributionModel> _contributions = [];
  List<ExpenseModel> _expenses = [];
  Map<String, double> _equities = {};
  double _totalInvested = 0;
  double _totalSpent = 0;
  bool _isLoading = false;

  List<InvestorModel> get investors => _investors;
  List<ContributionModel> get contributions => _contributions;
  List<ExpenseModel> get expenses => _expenses;
  Map<String, double> get equities => _equities;
  List<EquitySlice> get equitySlices {
    if (_investors.isEmpty || _contributions.isEmpty) return [];
    return EquityCalculator.getEquitySlices(investors: _investors, contributions: _contributions);
  }
  double get totalInvested => _totalInvested;
  double get totalSpent => _totalSpent;
  double get remaining => _totalInvested - _totalSpent;
  bool get isLoading => _isLoading;

  Future<void> loadTenderData(String tenderId) async {
    _isLoading = true; notifyListeners();
    _investors = await _service.getInvestors(tenderId);
    _contributions = await _service.getContributions(tenderId);
    _expenses = await _service.getExpenses(tenderId);
    _equities = EquityCalculator.calculateEquity(await _service.getInvestorTotals(tenderId));
    _totalInvested = 0; for (var c in _contributions) { _totalInvested += c.amount; }
    _totalSpent = 0; for (var e in _expenses) { _totalSpent += e.amount; }
    _isLoading = false; notifyListeners();
  }

  Future<void> addInvestor(String tenderId, InvestorModel inv) async { await _service.addInvestor(tenderId, inv); await loadTenderData(tenderId); }
  Future<void> recordContribution(String tenderId, ContributionModel c) async { await _service.recordContribution(tenderId, c); await loadTenderData(tenderId); }
  Future<void> logExpense(String tenderId, ExpenseModel e) async { await _service.logExpense(tenderId, e); await loadTenderData(tenderId); }
  Future<Map<String, double>> getExpensesByCategory(String tenderId) async => await _service.getExpensesByCategory(tenderId);
}
