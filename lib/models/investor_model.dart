import 'package:cloud_firestore/cloud_firestore.dart';

class InvestorModel {
  final String? id;
  final String? investorUserId; // Firebase Auth UID (null if not registered yet)
  final String name;
  final String phone;
  final String email;
  final DateTime addedAt;

  InvestorModel({
    this.id,
    this.investorUserId,
    required this.name,
    required this.phone,
    required this.email,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'investorUserId': investorUserId,
    'name': name,
    'phone': phone,
    'email': email,
    'addedAt': Timestamp.fromDate(addedAt),
  };

  factory InvestorModel.fromMap(String id, Map<String, dynamic> map) => InvestorModel(
    id: id,
    investorUserId: map['investorUserId'],
    name: map['name'] ?? '',
    phone: map['phone'] ?? '',
    email: map['email'] ?? '',
    addedAt: (map['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}
