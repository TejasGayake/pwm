import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/equity_calculator.dart';
import '../utils/formatters.dart';

class EquityPieChart extends StatelessWidget {
  final List<EquitySlice> slices;
  const EquityPieChart({super.key, required this.slices});

  @override
  Widget build(BuildContext context) {
    if (slices.isEmpty) return const SizedBox(height: 200, child: Center(child: Text('No data')));
    final total = slices.fold(0.0, (s, e) => s + e.totalContributed);
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: slices.map((s) => PieChartSectionData(
                  value: s.totalContributed,
                  color: Color(s.colorHex),
                  title: formatPercentage(s.equityPercent),
                  titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  radius: 80,
                )).toList(),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(formatIndianCurrency(total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ...slices.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: Color(s.colorHex), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(s.investorName, style: const TextStyle(fontSize: 12)),
                ]),
              )),
            ],
          ),
        ],
      ),
    );
  }
}
