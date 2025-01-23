import 'package:flutter/material.dart';

class LegendWidget extends StatelessWidget {
  final List<String> mesi;

  const LegendWidget({
    Key? key,
    required this.mesi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = [
      {'month': mesi[0], 'color': Colors.red.shade400},
      {'month': mesi[1], 'color': Colors.orange.shade400},
      {'month': mesi[2], 'color': Colors.red.shade300},
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: data.map((entry) {
          final month = entry['month'] as String;
          final color = entry['color'] as Color;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(month, style: const TextStyle(fontSize: 16)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}