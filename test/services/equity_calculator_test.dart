import 'package:flutter_test/flutter_test.dart';
import 'package:pwm/services/equity_calculator.dart';
import 'package:pwm/models/contribution_model.dart';
import 'package:pwm/models/expense_model.dart';
import 'package:pwm/models/investor_model.dart';

void main() {
  group('EquityCalculator', () {
    test('calculateEquitySplits - equal split', () {
      final splits = EquityCalculator.calculateEquitySplits(
        investorContributions: {'inv1': 50000, 'inv2': 50000},
      );
      expect(splits['inv1'], 50.0);
      expect(splits['inv2'], 50.0);
    });

    test('calculateEquitySplits - unequal split', () {
      final splits = EquityCalculator.calculateEquitySplits(
        investorContributions: {'inv1': 75000, 'inv2': 25000},
      );
      expect(splits['inv1'], 75.0);
      expect(splits['inv2'], 25.0);
    });

    test('calculateEquitySplits - single investor', () {
      final splits = EquityCalculator.calculateEquitySplits(
        investorContributions: {'inv1': 100000},
      );
      expect(splits['inv1'], 100.0);
    });

    test('calculateEquitySplits - zero contributions', () {
      final splits = EquityCalculator.calculateEquitySplits(
        investorContributions: {},
      );
      expect(splits, isEmpty);
    });

    test('calculateEquitySplits - three investors', () {
      final splits = EquityCalculator.calculateEquitySplits(
        investorContributions: {'inv1': 50000, 'inv2': 30000, 'inv3': 20000},
      );
      expect(splits['inv1'], 50.0);
      expect(splits['inv2'], 30.0);
      expect(splits['inv3'], 20.0);
    });

    test('computeSummary - basic calculation', () {
      final contributions = [
        ContributionModel(investorId: 'inv1', investorName: 'A', amount: 100000, date: DateTime.now().subtract(const Duration(days: 30))),
      ];
      final expenses = [
        ExpenseModel(amount: 40000, category: 'materials', description: 'Cement', date: DateTime.now().subtract(const Duration(days: 10)), recordedBy: 'user1'),
      ];
      final summary = EquityCalculator.computeSummary(
        targetAmount: 200000,
        contributions: contributions,
        expenses: expenses,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      );
      expect(summary.totalInvested, 100000);
      expect(summary.totalSpent, 40000);
      expect(summary.remainingBalance, 60000);
      expect(summary.fundingRatio, 0.5);
      expect(summary.isOverFunded, false);
    });

    test('computeSummary - over-funded scenario', () {
      final contributions = [
        ContributionModel(investorId: 'inv1', investorName: 'A', amount: 250000, date: DateTime.now().subtract(const Duration(days: 30))),
      ];
      final summary = EquityCalculator.computeSummary(
        targetAmount: 200000,
        contributions: contributions,
        expenses: [],
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      );
      expect(summary.isOverFunded, true);
      expect(summary.fundingRatio, 1.25);
    });

    test('getEquitySlices - returns correct slices', () {
      final investors = [
        InvestorModel(id: 'inv1', name: 'Alice', phone: '123', email: 'a@test.com'),
        InvestorModel(id: 'inv2', name: 'Bob', phone: '456', email: 'b@test.com'),
      ];
      final contributions = [
        ContributionModel(investorId: 'inv1', investorName: 'Alice', amount: 60000, date: DateTime.now()),
        ContributionModel(investorId: 'inv2', investorName: 'Bob', amount: 40000, date: DateTime.now()),
      ];
      final slices = EquityCalculator.getEquitySlices(investors: investors, contributions: contributions);
      expect(slices.length, 2);
      final alice = slices.firstWhere((s) => s.investorId == 'inv1');
      expect(alice.equityPercent, 60.0);
      final bob = slices.firstWhere((s) => s.investorId == 'inv2');
      expect(bob.equityPercent, 40.0);
    });
  });
}
