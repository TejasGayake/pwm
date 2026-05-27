import 'package:flutter/material.dart';
import '../models/contribution_model.dart';
import '../models/investor_model.dart';
import '../models/expense_model.dart';

class EquityCalculator {
  static Map<String, double> calculateEquity(Map<String, double> investorTotals) {
    double total = 0;
    for (var v in investorTotals.values) { total += v; }
    if (total <= 0) return {};
    return investorTotals.map((id, amount) => MapEntry(id, (amount / total) * 100));
  }

  static Map<String, double> calculateEquitySplits({
    required Map<String, double> investorContributions,
  }) {
    final total = investorContributions.values.fold(0.0, (a, b) => a + b);
    if (total <= 0) return {};
    return investorContributions.map(
      (id, amount) => MapEntry(id, (amount / total) * 100),
    );
  }

  static double calculateBurnRate(double totalSpent, int daysElapsed) {
    if (daysElapsed <= 0) return 0;
    return totalSpent / daysElapsed;
  }

  static int calculateRunwayDays(double remaining, double burnRate) {
    if (burnRate <= 0) return -1;
    return (remaining / burnRate).floor();
  }

  static double calculateExcessFunding(double totalInvested, double targetAmount) {
    if (totalInvested <= targetAmount) return 0;
    return totalInvested - targetAmount;
  }

  static List<EquitySlice> getEquitySlices({
    required List<InvestorModel> investors,
    required List<ContributionModel> contributions,
  }) {
    final investorTotals = <String, double>{};
    final investorNames = <String, String>{};
    for (final inv in investors) {
      investorTotals[inv.id!] = 0;
      investorNames[inv.id!] = inv.name;
    }
    for (final c in contributions) {
      investorTotals[c.investorId] = (investorTotals[c.investorId] ?? 0) + c.amount;
    }
    final total = investorTotals.values.fold(0.0, (a, b) => a + b);
    if (total <= 0) return [];
    final colors = [
      0xFF1565C0, 0xFF2E7D32, 0xFFEF6C00, 0xFF6A1B9A,
      0xFFC62828, 0xFF00838F, 0xFF4E342E, 0xFF37474F,
    ];
    final slices = <EquitySlice>[];
    int colorIdx = 0;
    investorTotals.forEach((id, amount) {
      if (amount > 0) {
        slices.add(EquitySlice(
          investorId: id,
          investorName: investorNames[id] ?? 'Unknown',
          totalContributed: amount,
          equityPercent: (amount / total) * 100,
          colorHex: colors[colorIdx % colors.length],
        ));
        colorIdx++;
      }
    });
    return slices;
  }

  static FinancialSummary computeSummary({
    required double targetAmount,
    required List<ContributionModel> contributions,
    required List<ExpenseModel> expenses,
    required DateTime startDate,
  }) {
    final totalInvested = contributions.fold(0.0, (s, c) => s + c.amount);
    final totalSpent = expenses.fold(0.0, (s, e) => s + e.amount);
    final remaining = totalInvested - totalSpent;
    final daysElapsed = DateTime.now().difference(startDate).inDays.clamp(1, 999999);
    final burnRate = totalSpent / daysElapsed;
    final fundingRatio = targetAmount > 0 ? totalInvested / targetAmount : 0.0;
    final isOverFunded = totalInvested > targetAmount;
    return FinancialSummary(
      targetAmount: targetAmount,
      totalInvested: totalInvested,
      totalSpent: totalSpent,
      remainingBalance: remaining,
      burnRate: burnRate,
      fundingRatio: fundingRatio,
      isOverFunded: isOverFunded,
    );
  }
}

class EquitySlice {
  final String investorId;
  final String investorName;
  final double totalContributed;
  final double equityPercent;
  final int colorHex;

  EquitySlice({
    required this.investorId,
    required this.investorName,
    required this.totalContributed,
    required this.equityPercent,
    required this.colorHex,
  });
}

class FinancialSummary {
  final double targetAmount;
  final double totalInvested;
  final double totalSpent;
  final double remainingBalance;
  final double burnRate;
  final double fundingRatio;
  final bool isOverFunded;

  FinancialSummary({
    required this.targetAmount,
    required this.totalInvested,
    required this.totalSpent,
    required this.remainingBalance,
    required this.burnRate,
    required this.fundingRatio,
    required this.isOverFunded,
  });
}
