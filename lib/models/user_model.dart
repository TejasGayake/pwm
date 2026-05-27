import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String role;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'email': email,
    'role': role,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) => AppUser(
    uid: uid,
    name: map['name'] ?? '',
    phone: map['phone'] ?? '',
    email: map['email'] ?? '',
    role: map['role'] ?? 'investor',
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  bool get isEngineer => role == 'engineer';
  bool get isInvestor => role == 'investor';
  bool get isBuilder => role == 'builder';
}
