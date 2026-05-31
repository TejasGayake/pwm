import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isEngineer => role == 'engineer';
  bool get isInvestor => role == 'investor';
  bool get isBuilder => role == 'builder';

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) => AppUser(
    uid: uid,
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    phone: map['phone'] ?? '',
    role: map['role'] ?? 'investor',
    createdAt: (map['createdAt'] is Timestamp)
        ? (map['createdAt'] as Timestamp).toDate()
        : (map['createdAt'] is String)
            ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
            : DateTime.now(),
  );
}
