import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tender_model.dart';
import '../models/investor_model.dart';
import '../models/contribution_model.dart';
import '../models/expense_model.dart';
import '../models/app_user.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===== GENERIC =====
  Future<String> addDoc(String collection, Map<String, dynamic> data) async {
    final ref = await _db.collection(collection).add(data);
    return ref.id;
  }

  Future<void> setDoc(String collection, String docId, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(docId).set(data);
  }

  Future<void> updateDoc(String collection, String docId, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(docId).update(data);
  }

  Future<void> deleteDoc(String collection, String docId) async {
    await _db.collection(collection).doc(docId).delete();
  }

  Future<DocumentSnapshot> getDoc(String collection, String docId) async {
    return await _db.collection(collection).doc(docId).get();
  }

  Future<QuerySnapshot> getCollection(String collection, {String? orderBy, bool descending = false}) async {
    Query query = _db.collection(collection);
    if (orderBy != null) query = query.orderBy(orderBy, descending: descending);
    return await query.get();
  }

  Future<QuerySnapshot> getSubcollection(String parent, String parentDoc, String sub) async {
    return await _db.collection(parent).doc(parentDoc).collection(sub).orderBy('date', descending: true).get();
  }

  Future<String> addSubDoc(String parent, String parentDoc, String sub, Map<String, dynamic> data) async {
    final ref = await _db.collection(parent).doc(parentDoc).collection(sub).add(data);
    return ref.id;
  }

  Future<void> deleteSubDoc(String parent, String parentDoc, String sub, String docId) async {
    await _db.collection(parent).doc(parentDoc).collection(sub).doc(docId).delete();
  }

  // ===== TENDERS =====
  Stream<List<TenderModel>> getTendersForEngineer(String engineerUid) {
    return _db
        .collection(FirestoreCollections.tenders)
        .where('createdBy', isEqualTo: engineerUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => TenderModel.fromMap(d.id, d.data())).toList());
  }

  Stream<List<TenderModel>> getTendersForInvestor(String investorUid) {
    return _db
        .collectionGroup(FirestoreCollections.investors)
        .where('investorUserId', isEqualTo: investorUid)
        .snapshots()
        .asyncMap((investorSnap) async {
      final tenderIds = investorSnap.docs.map((doc) => doc.reference.parent.parent!.id).toSet().toList();
      if (tenderIds.isEmpty) return <TenderModel>[];
      final tenders = <TenderModel>[];
      for (final tid in tenderIds) {
        final doc = await _db.collection(FirestoreCollections.tenders).doc(tid).get();
        if (doc.exists) tenders.add(TenderModel.fromMap(doc.id, doc.data()!));
      }
      return tenders;
    });
  }

  // ===== INVESTORS =====
  Stream<List<InvestorModel>> getInvestorsForTender(String tenderId) {
    return _db
        .collection(FirestoreCollections.tenders)
        .doc(tenderId)
        .collection(FirestoreCollections.investors)
        .snapshots()
        .map((snap) => snap.docs.map((d) => InvestorModel.fromMap(d.id, d.data())).toList());
  }

  Future<String> addInvestorToTender(String tenderId, InvestorModel investor) async {
    final docRef = await _db
        .collection(FirestoreCollections.tenders)
        .doc(tenderId)
        .collection(FirestoreCollections.investors)
        .add(investor.toMap());
    return docRef.id;
  }

  Future<void> removeInvestor(String tenderId, String investorId) async {
    await _db
        .collection(FirestoreCollections.tenders)
        .doc(tenderId)
        .collection(FirestoreCollections.investors)
        .doc(investorId)
        .delete();
  }

  // ===== CONTRIBUTIONS =====
  Stream<List<ContributionModel>> getContributionsForTender(String tenderId) {
    return _db
        .collection(FirestoreCollections.tenders)
        .doc(tenderId)
        .collection(FirestoreCollections.contributions)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ContributionModel.fromMap(d.id, d.data())).toList());
  }

  Stream<List<ContributionModel>> getContributionsForInvestor(String tenderId, String investorId) {
    return _db
        .collection(FirestoreCollections.tenders)
        .doc(tenderId)
        .collection(FirestoreCollections.contributions)
        .where('investorId', isEqualTo: investorId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ContributionModel.fromMap(d.id, d.data())).toList());
  }

  Future<String> addContribution(String tenderId, ContributionModel contribution) async {
    final docRef = await _db
        .collection(FirestoreCollections.tenders)
        .doc(tenderId)
        .collection(FirestoreCollections.contributions)
        .add(contribution.toMap());
    return docRef.id;
  }

  // ===== EXPENSES =====
  Stream<List<ExpenseModel>> getExpensesForTender(String tenderId) {
    return _db
        .collection(FirestoreCollections.tenders)
        .doc(tenderId)
        .collection(FirestoreCollections.expenses)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ExpenseModel.fromMap(d.id, d.data())).toList());
  }

  Future<String> addExpense(String tenderId, ExpenseModel expense) async {
    final docRef = await _db
        .collection(FirestoreCollections.tenders)
        .doc(tenderId)
        .collection(FirestoreCollections.expenses)
        .add(expense.toMap());
    return docRef.id;
  }

  // ===== AGGREGATIONS =====
  Future<double> getTotalInvested(String tenderId) async {
    final snapshot = await _db
        .collection(FirestoreCollections.tenders)
        .doc(tenderId)
        .collection(FirestoreCollections.contributions)
        .get();
    double total = 0;
    for (final doc in snapshot.docs) {
      total += (doc.data()['amount'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  Future<double> getTotalSpent(String tenderId) async {
    final snapshot = await _db
        .collection(FirestoreCollections.tenders)
        .doc(tenderId)
        .collection(FirestoreCollections.expenses)
        .get();
    double total = 0;
    for (final doc in snapshot.docs) {
      total += (doc.data()['amount'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  // ===== USER =====
  Future<AppUser?> getUserById(String uid) async {
    final doc = await _db.collection(FirestoreCollections.users).doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(uid, doc.data()!);
  }
}
