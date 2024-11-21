import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/screens/ricerca/petsitter_model.dart';
import 'package:happy_tails/screens/ricerca/petsitter_repository.dart';

/// Provider for the CardRepository
final cardRepositoryProvider = Provider<CardRepository>((ref) => CardRepository());

/// FutureProvider for fetching the list of cards
final cardListProvider = FutureProvider<List<PetSitter>>((ref) async {
  // Correctly retrieve and await the result from the repository
  final repository = ref.watch(cardRepositoryProvider);
  return repository.fetchCards(); // Ensure this is awaited
  


});



