import 'dart:async';
import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  List<ExpenseModel> _expenses = [];
  String _categoryFilter = 'all';
  StreamSubscription<List<ExpenseModel>>? _expensesSubscription;

  List<ExpenseModel> get expenses {
    if (_categoryFilter == 'all') return _expenses;
    return _expenses.where((e) => e.category == _categoryFilter).toList();
  }

  List<ExpenseModel> get allExpenses => _expenses;
  double get totalSpent => _expenses.fold(0, (s, e) => s + e.amount);
  String get categoryFilter => _categoryFilter;

  void listenToExpenses(String tenderId) {
    _expensesSubscription?.cancel();
    _expensesSubscription =
        _firestore.getExpensesForTender(tenderId).listen((expenses) {
      _expenses = expenses;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _expensesSubscription?.cancel();
    super.dispose();
  }

  void setCategoryFilter(String category) {
    _categoryFilter = category;
    notifyListeners();
  }

  Map<String, double> getCategoryTotals() {
    final totals = <String, double>{};
    for (final e in _expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  Future<String> addExpense(String tenderId, ExpenseModel expense) async {
    return await _firestore.addExpense(tenderId, expense);
  }
}
