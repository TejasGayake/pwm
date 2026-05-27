import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BurnRateChart extends StatelessWidget {
  const BurnRateChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text('Burn rate chart', style: TextStyle(color: Colors.grey[600])),
            Text('Data will appear as expenses are logged', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}
