import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:happy_tails/screens/ricerca/risultato_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/screens/ricerca/risultati_provider.dart';




class RisultatiCercaPage extends ConsumerWidget {
  const RisultatiCercaPage({Key? key}) : super(key: key);

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
          // Custom Header Section
          _buildHeader(),

          // Divider for clarity between header and results
          const Divider(height: 1, thickness: 1, color: Colors.black12),

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

  // Header with two levels
  // Header Widget
  Widget _buildHeader() {
    return Container(
      color: Colors.blue.shade50, // Light background for header
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Level 1: Animal and City
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChip('Cane'),
              const SizedBox(width: 8),
              _buildChip('Ancona'),
            ],
          ),
          const SizedBox(height: 16),

          // Level 2: Date Range and Stay Length
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '22-29 Agosto',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                TextSpan(
                  text: '  ·  7 giorni',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Chip Widget for Animal and City
  Widget _buildChip(String label) {
    return Chip(
      label: Text(
        label,
        style: GoogleFonts.lato(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.blueAccent,
        ),
      ),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.blueAccent),
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

}


