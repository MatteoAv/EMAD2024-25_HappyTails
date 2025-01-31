



// Add this in your providers file
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/screens/ricerca/risultato_card.dart';

final sortProvider = StateProvider<String>((ref) => 'Distanza'); // Default sort




List<Map<String, dynamic>> sortPetSitters(
  List<Map<String, dynamic>> sitters,
  String sortBy,
) {
  switch (sortBy) {
    case 'Alfabetico':
      return List.from(sitters)
        ..sort((a, b) => ('${a['nome']} ${a['cognome']}')
            .compareTo('${b['nome']} ${b['cognome']}'));
    case 'Popolarità':
      // Adjust this based on your actual popularity criteria
      return List.from(sitters)
        ..sort((a, b) => (b['rating'] ?? 0).compareTo(a['rating'] ?? 0));
    case 'Distanza':
    default:
      // Adjust this based on your actual date criteria
      return List.from(sitters)
  ..sort((a, b) => (a['distance'] ?? 0).compareTo(b['distance'] ?? 0));
}
}


Future<void> updatePetSitters(List<dynamic> sortedSitters) async {
  for (var petsitter in sortedSitters) {
    petsitter['rating'] = await fetchPetSitterScore(petsitter['id']);
    petsitter['reviews'] = await fetchPetSitterReview(petsitter['id']);
  }
}
/*
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:happy_tails/screens/ricerca/petsitter_model.dart';
//import 'package:happy_tails/screens/ricerca/petsitter_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Documentazione del repository provider
/// 
/// Crea un'istanza singleton di [CardRepository] usando il Provider di Riverpod.
/// Questo provider agisce come un meccanismo di iniezione delle dipendenze per il repository,
/// assicurando una fonte unica e coerente di recupero dei dati in tutta l'applicazione.
/// 
/// Utilizzo:
/// - Fornisce l'accesso ai metodi di recupero dei dati.
/// - Può essere facilmente preso in giro per i test
/// - Centralizza la logica dell'origine dei dati

final cardRepositoryProvider = Provider<CardRepository>((ref) => CardRepository());

/// FutureProvider per il recupero asincrono dei dati del card
/// 
/// Questo provider gestisce il caricamento asincrono delle schede di PetSitter.
/// Caratteristiche principali:
/// - Controlla il provider del repository per l'origine dei dati.
/// - Gestisce il recupero asincrono dei dati
/// - Fornisce il caricamento, gli errori e gli stati dei dati in modo immediato.
/// 
/// Utilizzo tipico in un widget:
/// ```dart
/// cardListAsyncValue.when(
/// data: (carte) => ListView.builder(...),
/// loading: () => CircularProgressIndicator(),
/// error: (err, stack) => ErrorWidget(err),
/// )
/// ```
/// FutureProvider for fetching the list of cards
final cardListProvider = FutureProvider<List<PetSitter>>((ref) async {
  // Correctly retrieve and await the result from the repository
  final repository = ref.watch(cardRepositoryProvider);
  return repository.fetchCards(); // Ensure this is awaited
});
*/




