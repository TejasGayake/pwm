import 'package:flutter/material.dart';
import '../models/tender_model.dart';
import '../services/tender_service.dart';

class TenderProvider extends ChangeNotifier {
  final TenderService _service = TenderService();
  List<TenderModel> _tenders = [];
  bool _isLoading = false;

  List<TenderModel> get tenders => _tenders;
  List<TenderModel> get activeTenders => _tenders.where((t) => t.status == 'active').toList();
  List<TenderModel> get completedTenders => _tenders.where((t) => t.status == 'completed').toList();
  List<TenderModel> get onHoldTenders => _tenders.where((t) => t.status == 'on_hold').toList();
  bool get isLoading => _isLoading;

  Future<void> loadTenders() async {
    _isLoading = true; notifyListeners();
    _tenders = await _service.getTenders();
    _isLoading = false; notifyListeners();
  }

  void listenToTenders(String uid, String role) {
    loadTenders();
  }

  Future<void> createTender(TenderModel t) async { await _service.createTender(t); await loadTenders(); }
  Future<void> updateTender(String id, Map<String, dynamic> data) async { await _service.updateTender(id, data); await loadTenders(); }
  Future<void> deleteTender(String id) async { await _service.deleteTender(id); await loadTenders(); }
}
