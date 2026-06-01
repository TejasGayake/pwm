import 'package:cloud_firestore/cloud_firestore.dart';

class ContributionModel {
  final String? id;
  final String investorId;
  final String investorName; // denormalized
  final double amount;
  final DateTime date;
  final String bankReference;
  final String? receiptPhotoUrl;
  final String paymentMode; // cash, phonepe, bank_transfer, upi
  final DateTime createdAt;

  ContributionModel({
    this.id,
    required this.investorId,
    required this.investorName,
    required this.amount,
    required this.date,
    this.bankReference = '',
    this.receiptPhotoUrl,
    this.paymentMode = 'cash',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'investorId': investorId,
    'investorName': investorName,
    'amount': amount,
    'date': Timestamp.fromDate(date),
    'bankReference': bankReference,
    'receiptPhotoUrl': receiptPhotoUrl,
    'paymentMode': paymentMode,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory ContributionModel.fromMap(String id, Map<String, dynamic> map) => ContributionModel(
    id: id,
    investorId: map['investorId'] ?? '',
    investorName: map['investorName'] ?? '',
    amount: (map['amount'] as num?)?.toDouble() ?? 0,
    date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    bankReference: map['bankReference'] ?? '',
    receiptPhotoUrl: map['receiptPhotoUrl'],
    paymentMode: map['paymentMode'] ?? 'cash',
    createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
  );
}
