import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget {
  final List<String> mesi;
  final List<double> earnings;

  const PieChartWidget({
    Key? key,
    required this.mesi,
    required this.earnings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = [
      {'month': mesi[0], 'earnings': earnings[2], 'color': Colors.red.shade400},
      {'month': mesi[1], 'earnings': earnings[1], 'color': Colors.orange.shade400},
      {'month': mesi[2], 'earnings': earnings[0], 'color': Colors.red.shade300},
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: PieChart(
        PieChartData(
          sections: _buildPieChartSections(data),
          centerSpaceRadius: 40,
          sectionsSpace: 4,
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(List<Map<String, dynamic>> data) {
    return data.map((entry) {
      final value = entry['earnings'] as double;
      final color = entry['color'] as Color;
      return PieChartSectionData(
        color: color,
        value: value,
        title: '€${value.toStringAsFixed(2)}',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}