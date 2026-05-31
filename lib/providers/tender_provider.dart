import 'package:flutter/material.dart';
import '../models/tender_model.dart';
import '../services/tender_service.dart';

class TenderProvider extends ChangeNotifier {
  final TenderService _service = TenderService();
  List<TenderModel> _tenders = [];
  bool _isLoading = false;
  String? _uid;
  String? _role;

  List<TenderModel> get tenders => _tenders;
  List<TenderModel> get activeTenders => _tenders.where((t) => t.status == 'active').toList();
  List<TenderModel> get completedTenders => _tenders.where((t) => t.status == 'completed').toList();
  List<TenderModel> get onHoldTenders => _tenders.where((t) => t.status == 'on_hold').toList();
  bool get isLoading => _isLoading;

  Future<void> loadTenders({String? uid, String? role}) async {
    _isLoading = true; notifyListeners();
    _tenders = await _service.getTenders(uid: uid, role: role);
    _isLoading = false; notifyListeners();
  }

  void listenToTenders(String uid, String role) {
    _uid = uid;
    _role = role;
    loadTenders(uid: uid, role: role);
  }

  Future<void> createTender(TenderModel t) async { await _service.createTender(t); await loadTenders(uid: _uid, role: _role); }
  Future<void> updateTender(String id, Map<String, dynamic> data) async { await _service.updateTender(id, data); await loadTenders(uid: _uid, role: _role); }
  Future<void> deleteTender(String id) async { await _service.deleteTender(id); await loadTenders(uid: _uid, role: _role); }
}
