import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartWidget extends StatelessWidget {
  final List<double> earnings; // Lista dei guadagni
  final List<String> mesiDaMostrare; // Lista dei mesi da mostrare sull'asse x

  const LineChartWidget({
    Key? key,
    required this.earnings,
    required this.mesiDaMostrare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (earnings.isEmpty) {
      return const Center(child: Text("Dati insufficienti per il grafico"));
    }
    // Genera i punti FlSpot per il grafico
    final data = List<FlSpot>.generate(
      earnings.length,
      (index) => FlSpot(index.toDouble(), earnings[index]),
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LineChart(
        LineChartData(
          // Griglia del grafico
          gridData: FlGridData(show: true), // Mostra la griglia per aiutare la leggibilità
          // Imposta i titoli degli assi
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1, // Intervallo per mostrare un'etichetta per ogni punto
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < mesiDaMostrare.length) {
                    return SideTitleWidget(
                      meta: meta,
                      space: 4, // Spazio tra l'etichetta e l'asse
                      child: Text(
                        mesiDaMostrare[value.toInt()],
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }
                  return const SizedBox.shrink(); // Etichetta vuota se fuori range
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                interval: _calculateYAxisInterval(), // Intervallo personalizzato per gli assi
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta : meta,
                    space: 4, // Spazio tra l'etichetta e l'asse
                    child: Text(
                      '€${value.toInt()}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false
              )
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false
              )
            ),
          ),
          // Bordo del grafico
          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(color: Colors.black),
              bottom: BorderSide(color: Colors.black),
            ),
          ),
          // Dati del grafico
          lineBarsData: [
            LineChartBarData(
              spots: data,
              isCurved: false, // Curvatura della linea
              color: Colors.redAccent, // Colore della linea
              barWidth: 4, // Spessore della linea
              isStrokeCapRound: true,
              belowBarData: BarAreaData(show: false), // Nessuna area colorata sotto la linea
              dotData: FlDotData(show: true), // Mostra i punti dei dati
            ),
          ],
          // Range degli assi
          minX: 0,
          maxX: (mesiDaMostrare.length - 1).toDouble(),
          minY: 0,
          maxY: _calculateYAxisMax(), // Calcola il valore massimo sull'asse y
        ),
      ),
    );
  }

  // Calcola il valore massimo per l'asse Y (guadagni)
  double _calculateYAxisMax() {
    if (earnings.isEmpty) return 0;
    return (earnings.reduce((a, b) => a > b ? a : b) * 1.2).ceilToDouble(); // Aggiunge un margine del 20%
  }

  // Calcola l'intervallo per l'asse Y in base al valore massimo
  double _calculateYAxisInterval() {
    final max = _calculateYAxisMax();
    return (max / 5).ceilToDouble(); // Divide l'asse Y in 5 intervalli
  }
}