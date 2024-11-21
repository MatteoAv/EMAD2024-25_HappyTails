import 'package:flutter/material.dart';
import 'package:happy_tails/screens/ricerca/risultato_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/screens/ricerca/risultati_provider.dart';

class RisultatiCercaPage extends ConsumerWidget {
  const RisultatiCercaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardListAsyncValue = ref.watch(cardListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Risultati di ricerca')),
      body: cardListAsyncValue.when(
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
    );
  }
}
