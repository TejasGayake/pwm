import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String? id;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String? receiptPhotoUrl;
  final double? gpsLat;
  final double? gpsLng;
  final String recordedBy;
  final DateTime createdAt;

  ExpenseModel({
    this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.receiptPhotoUrl,
    this.gpsLat,
    this.gpsLng,
    required this.recordedBy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'amount': amount,
    'category': category,
    'description': description,
    'date': Timestamp.fromDate(date),
    'receiptPhotoUrl': receiptPhotoUrl,
    'gpsLat': gpsLat,
    'gpsLng': gpsLng,
    'recordedBy': recordedBy,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory ExpenseModel.fromMap(String id, Map<String, dynamic> map) => ExpenseModel(
    id: id,
    amount: (map['amount'] as num?)?.toDouble() ?? 0,
    category: map['category'] ?? 'misc',
    description: map['description'] ?? '',
    date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    receiptPhotoUrl: map['receiptPhotoUrl'],
    gpsLat: (map['gpsLat'] as num?)?.toDouble(),
    gpsLng: (map['gpsLng'] as num?)?.toDouble(),
    recordedBy: map['recordedBy'] ?? '',
    createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
  );

  bool get hasPhoto => receiptPhotoUrl != null && receiptPhotoUrl!.isNotEmpty;
  bool get hasLocation => gpsLat != null && gpsLng != null;
}
