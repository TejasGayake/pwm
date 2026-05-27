import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pwm/models/app_user.dart';
import 'package:pwm/models/tender_model.dart';
import 'package:pwm/models/investor_model.dart';
import 'package:pwm/models/contribution_model.dart';
import 'package:pwm/models/expense_model.dart';

void main() {
  group('AppUser', () {
    test('fromMap creates correct model', () {
      final now = DateTime.now();
      final map = {
        'name': 'Tejas',
        'phone': '9876543210',
        'email': 'tejas@test.com',
        'role': 'engineer',
        'createdAt': Timestamp.fromDate(now),
      };
      final user = AppUser.fromMap('uid123', map);
      expect(user.uid, 'uid123');
      expect(user.name, 'Tejas');
      expect(user.role, 'engineer');
      expect(user.isEngineer, true);
      expect(user.isInvestor, false);
    });

    test('fromMap handles missing fields', () {
      final user = AppUser.fromMap('uid123', {});
      expect(user.name, '');
      expect(user.role, 'investor');
    });
  });

  group('TenderModel', () {
    test('fromMap creates correct model', () {
      final now = DateTime.now();
      final map = {
        'name': 'Pune Road Project',
        'location': 'Pune',
        'targetAmount': 5000000,
        'startDate': Timestamp.fromDate(now),
        'endDate': Timestamp.fromDate(now.add(const Duration(days: 365))),
        'status': 'active',
        'createdBy': 'engineer1',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };
      final tender = TenderModel.fromMap('t1', map);
      expect(tender.id, 't1');
      expect(tender.name, 'Pune Road Project');
      expect(tender.targetAmount, 5000000);
      expect(tender.isActive, true);
      expect(tender.isCompleted, false);
    });
  });

  group('InvestorModel', () {
    test('fromMap creates correct model', () {
      final now = DateTime.now();
      final map = {
        'investorUserId': 'user1',
        'name': 'Raj',
        'phone': '9876543210',
        'email': 'raj@test.com',
        'addedAt': Timestamp.fromDate(now),
      };
      final investor = InvestorModel.fromMap('inv1', map);
      expect(investor.id, 'inv1');
      expect(investor.name, 'Raj');
      expect(investor.investorUserId, 'user1');
    });
  });

  group('ContributionModel', () {
    test('fromMap creates correct model', () {
      final now = DateTime.now();
      final map = {
        'investorId': 'inv1',
        'investorName': 'Raj',
        'amount': 100000,
        'date': Timestamp.fromDate(now),
        'bankReference': 'UTR123',
        'receiptPhotoUrl': null,
        'createdAt': Timestamp.fromDate(now),
      };
      final c = ContributionModel.fromMap('c1', map);
      expect(c.id, 'c1');
      expect(c.amount, 100000);
      expect(c.bankReference, 'UTR123');
    });
  });

  group('ExpenseModel', () {
    test('fromMap creates correct model', () {
      final now = DateTime.now();
      final map = {
        'amount': 50000,
        'category': 'materials',
        'description': 'Cement bags',
        'date': Timestamp.fromDate(now),
        'receiptPhotoUrl': 'https://example.com/photo.jpg',
        'gpsLat': 18.5204,
        'gpsLng': 73.8567,
        'recordedBy': 'engineer1',
        'createdAt': Timestamp.fromDate(now),
      };
      final e = ExpenseModel.fromMap('e1', map);
      expect(e.id, 'e1');
      expect(e.amount, 50000);
      expect(e.category, 'materials');
      expect(e.hasPhoto, true);
      expect(e.hasLocation, true);
    });

    test('hasPhoto returns false for null url', () {
      final e = ExpenseModel(amount: 100, category: 'misc', description: 'test', date: DateTime.now(), recordedBy: 'user1');
      expect(e.hasPhoto, false);
      expect(e.hasLocation, false);
    });
  });
}
