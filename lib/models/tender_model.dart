import 'package:cloud_firestore/cloud_firestore.dart';

class TenderModel {
  final String? id;
  final String name;
  final String location;
  final double targetAmount;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'active' | 'completed' | 'on_hold'
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  TenderModel({
    this.id,
    required this.name,
    required this.location,
    required this.targetAmount,
    required this.startDate,
    required this.endDate,
    this.status = 'active',
    required this.createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'name': name,
    'location': location,
    'targetAmount': targetAmount,
    'startDate': Timestamp.fromDate(startDate),
    'endDate': Timestamp.fromDate(endDate),
    'status': status,
    'createdBy': createdBy,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(DateTime.now()),
  };

  factory TenderModel.fromMap(String id, Map<String, dynamic> map) => TenderModel(
    id: id,
    name: map['name'] ?? '',
    location: map['location'] ?? '',
    targetAmount: (map['targetAmount'] as num?)?.toDouble() ?? 0,
    startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    status: map['status'] ?? 'active',
    createdBy: map['createdBy'] ?? '',
    createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
  );

  TenderModel copyWith({
    String? name,
    String? location,
    double? targetAmount,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) => TenderModel(
    id: id,
    name: name ?? this.name,
    location: location ?? this.location,
    targetAmount: targetAmount ?? this.targetAmount,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    status: status ?? this.status,
    createdBy: createdBy,
    createdAt: createdAt,
  );

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isOnHold => status == 'on_hold';
}
