import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(String path, File file) async {
    final ref = _storage.ref(path);
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  Future<String> uploadReceipt(String tenderId, File file, String filename) async => await uploadFile('receipts/$tenderId/$filename', file);
  Future<String> uploadContributionProof(String tenderId, File file, String filename) async => await uploadFile('contributions/$tenderId/$filename', file);
  Future<String> uploadProgressPhoto(String tenderId, File file, String filename) async => await uploadFile('progress/$tenderId/$filename', file);

  Future<String> uploadReceiptPhoto({required String tenderId, required File imageFile}) async {
    final filename = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return await uploadReceipt(tenderId, imageFile, filename);
  }

  Future<String> uploadContributionPhoto({required String tenderId, required File imageFile}) async {
    final filename = 'contrib_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return await uploadContributionProof(tenderId, imageFile, filename);
  }

  Future<void> deleteFile(String url) async {
    try { await _storage.refFromURL(url).delete(); } catch (_) {}
  }
}
