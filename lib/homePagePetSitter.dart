
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/header.dart';
import 'package:happy_tails/homeProvider/providers.dart';
import 'package:happy_tails/widgetHomePage/BookingCalendar.dart';
import 'package:happy_tails/widgetHomePage/LegendChart.dart';
import 'package:happy_tails/widgetHomePage/LineChart.dart';
import 'package:happy_tails/widgetHomePage/PieChart.dart';

class HomePagePetSitter extends ConsumerWidget {
  HomePagePetSitter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalEarnings = ref.watch(totalEarningsProvider);
    final averageRating = ref.watch(averageRatingProvider);
    final oldEarnings = ref.watch(oldEarningsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100.0,
            flexibleSpace: const FlexibleSpaceBar(
              background: Header(),
            ),
            automaticallyImplyLeading: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  BookingCalendar(),
                  const SizedBox(height: 16,),

                  ElevatedButton(
                  
                  onPressed: () => ref.read(busyDatesProvider.notifier).initialize(),
                  child: const Text('Carica calendario'),
                  ),

                  const SizedBox(height: 16,),

                  _buildStatCard(
                    title: 'Guadagno Medio',
                    value: totalEarnings.when(
                      data: (value) => '€${value.toStringAsFixed(2)}',
                      loading: () => 'Loading...',
                      error: (e, _) => 'Nessun Informazione disponibile',
                    ),
                  ),
                  const SizedBox(height: 16,),
                  _buildStatCard(
                    title: 'Guadagno Mensile Corrente',
                    value: oldEarnings.when(
                      data: (value) {
                        if(value.isNotEmpty){

                        return '€${value[2].toStringAsFixed(2)}';
                        }
                        return '0.0';},
                      loading: () => 'Loading...',
                      error: (e, _) => 'Nessun Informazione disponibile',
                    ),
                  ),
                  const SizedBox(height: 16,),
                  
                  _buildStatCard(
                    title: 'Voto recensioni medio',
                    value: averageRating.when(
                      data: (value) => '${value.toStringAsFixed(2)}',
                      loading: () => 'Loading...',
                      error: (e, _) => 'Nessun Informazione disponibile',
                    ),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                    ref.invalidate(petSitterProvider);
                    ref.invalidate(totalEarningsProvider);
                    ref.invalidate(averageRatingProvider);
                    ref.invalidate(oldEarningsProvider);
                  }, 
                  child: Text("Aggiorna statistiche")
                  ),
                  const Text('Statistiche Dettagliate', 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  oldEarnings.when(
                    data: (earnings) {
                    if (earnings.isEmpty || earnings.every((value) => value == 0.0)) {
                      return Center(child: Text("Nessun dato disponibile"));
                    }
                  final mesi = [
                  'Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic',
                  ];
                  final currentMonth = DateTime.now().month;
                  final mesiDaScrivere = [
                    mesi[(currentMonth - 3) % 12],
                    mesi[(currentMonth - 2) % 12],
                    mesi[(currentMonth - 1) % 12],
                  ];

                  return Column(
                    children: [
                      LegendWidget(mesi: mesiDaScrivere),
                      SizedBox(
                      height: 300,
                      width: 800,
                      child: PageView(
                        children: [
                        PieChartWidget(mesi: mesiDaScrivere, earnings: earnings),
                        LineChartWidget(earnings: earnings, mesiDaMostrare: mesiDaScrivere,),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => const Center(child: Text('Nessun Informazione disponibile',
          style: TextStyle(fontSize: 20),)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  ],
),
);
  }

Widget _buildStatCard({required String title, required String value}) {
    return Material(
      borderRadius: BorderRadius.circular(12), // raggio più grande per un effetto più morbido
      color: Colors.deepOrange.shade100, // tonalità di arancione più chiara
      child: InkWell(
        onTap: () {
          // Aggiungi qui la logica per gestire il click sul widget
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.pets, color: Colors.deepOrange, size: 32), // icona personalizzata
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(value, style: TextStyle(fontSize: 24)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}