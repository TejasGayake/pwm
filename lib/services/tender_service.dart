import '../models/tender_model.dart';
import '../models/investor_model.dart';
import '../models/contribution_model.dart';
import '../models/expense_model.dart';
import 'firestore_service.dart';

class TenderService {
  final FirestoreService _fs = FirestoreService();

  Future<String> createTender(TenderModel t) async => await _fs.addDoc('tenders', t.toMap());
  Future<void> updateTender(String id, Map<String, dynamic> data) async => await _fs.updateDoc('tenders', id, data);
  Future<void> deleteTender(String id) async => await _fs.deleteDoc('tenders', id);

  Future<List<TenderModel>> getTenders() async {
    final snap = await _fs.getCollection('tenders', orderBy: 'createdAt', descending: true);
    return snap.docs.map((d) => TenderModel.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
  }

  Future<void> addInvestor(String tenderId, InvestorModel inv) async => await _fs.addSubDoc('tenders', tenderId, 'investors', inv.toMap());
  Future<List<InvestorModel>> getInvestors(String tenderId) async {
    final snap = await _fs.getSubcollection('tenders', tenderId, 'investors');
    return snap.docs.map((d) => InvestorModel.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
  }

  Future<void> recordContribution(String tenderId, ContributionModel c) async => await _fs.addSubDoc('tenders', tenderId, 'contributions', c.toMap());
  Future<List<ContributionModel>> getContributions(String tenderId) async {
    final snap = await _fs.getSubcollection('tenders', tenderId, 'contributions');
    return snap.docs.map((d) => ContributionModel.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
  }

  Future<void> logExpense(String tenderId, ExpenseModel e) async => await _fs.addSubDoc('tenders', tenderId, 'expenses', e.toMap());
  Future<List<ExpenseModel>> getExpenses(String tenderId) async {
    final snap = await _fs.getSubcollection('tenders', tenderId, 'expenses');
    return snap.docs.map((d) => ExpenseModel.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
  }

  Future<double> getTotalInvested(String tenderId) async {
    final c = await getContributions(tenderId);
    double t = 0; for (var x in c) { t += x.amount; } return t;
  }

  Future<double> getTotalSpent(String tenderId) async {
    final e = await getExpenses(tenderId);
    double t = 0; for (var x in e) { t += x.amount; } return t;
  }

  Future<Map<String, double>> getExpensesByCategory(String tenderId) async {
    final expenses = await getExpenses(tenderId);
    final Map<String, double> byCat = {};
    for (var e in expenses) { byCat[e.category] = (byCat[e.category] ?? 0) + e.amount; }
    return byCat;
  }

  Future<Map<String, double>> getInvestorTotals(String tenderId) async {
    final contributions = await getContributions(tenderId);
    final Map<String, double> totals = {};
    for (var c in contributions) { totals[c.investorId] = (totals[c.investorId] ?? 0) + c.amount; }
    return totals;
  }
}
