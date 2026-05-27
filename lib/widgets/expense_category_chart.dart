import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class ExpenseCategoryChart extends StatelessWidget {
  final Map<String, double> categoryTotals;
  const ExpenseCategoryChart({super.key, required this.categoryTotals});

  static const Map<String, Color> _colors = {
    'materials': Color(0xFF1565C0),
    'labor': Color(0xFF2E7D32),
    'machinery': Color(0xFFEF6C00),
    'diesel': Color(0xFF6A1B9A),
    'fuel': Color(0xFF795548),
    'misc': Color(0xFF546E7A),
  };

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) return const SizedBox(height: 200, child: Center(child: Text('No expense data')));
    final total = categoryTotals.values.fold(0.0, (s, v) => s + v);
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: categoryTotals.entries.map((e) => PieChartSectionData(
            value: e.value,
            color: _colors[e.key] ?? Colors.grey,
            title: formatPercentage((e.value / total) * 100),
            titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
            radius: 80,
          )).toList(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }
}
