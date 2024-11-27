import 'package:flutter/material.dart';
import 'package:happy_tails/screens/ricerca/risultato_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/screens/ricerca/risultati_provider.dart';
import 'package:intl/intl.dart';

class RisultatiCercaPage extends ConsumerWidget {
  const RisultatiCercaPage(this.animale, this.provincia, this.DateStart, this.DateEnd, {super.key});
  final String animale;
  final String provincia;
  final DateTime DateStart;
  final DateTime DateEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardListAsyncValue = ref.watch(cardListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
        title: const Text('Risultati di ricerca'),
      ),
      body: Column(
        children: [
          // Display parameters at the top as static text
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Display parameters (fixed text)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey),
                        ),
                        alignment: Alignment.center, // Centers the text
                        child: Text("Animale: $animale", style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey),
                        ),
                        alignment: Alignment.center, // Centers the text
                        child: Text("Provincia: $provincia", style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    // Date display (non-editable)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey),
                        ),
                        alignment: Alignment.center, // Centers the text
                        child: Text("Inizio: ${DateFormat('dd/MM/yyyy').format(DateStart)}", style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey),
                        ),
                        alignment: Alignment.center, // Centers the text
                        child: Text("Fine: ${DateFormat('dd/MM/yyyy').format(DateEnd)}", style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results List
          Expanded(
            child: cardListAsyncValue.when(
              data: (cards) {
                if (cards.isEmpty) {
                  return const Center(child: Text('No cards available'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    return VerticalCard(item: cards[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
