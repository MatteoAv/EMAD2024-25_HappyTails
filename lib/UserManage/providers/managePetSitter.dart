import 'package:flutter_riverpod/flutter_riverpod.dart';



class ManagePetsState {
  final Map<String, bool> selectedPets;

  ManagePetsState({required this.selectedPets});

  ManagePetsState copyWith({Map<String, bool>? selectedPets}) {
    return ManagePetsState(
      selectedPets: selectedPets ?? this.selectedPets,
    );
  }
}

class ManagePetsNotifier extends StateNotifier<ManagePetsState> {
  ManagePetsNotifier() : super(ManagePetsState(selectedPets: {}));

  static const List<String> allPetTypes = [
    'Dog',
    'Cat',
    'Fish',
    'Bird',
    'Other'
  ];

  void togglePet(String petType) {
    final updatedPets = Map<String, bool>.from(state.selectedPets);
    if (updatedPets.containsKey(petType)) {
      updatedPets[petType] = !updatedPets[petType]!;
    } else {
      updatedPets[petType] = true;
    }
    state = state.copyWith(selectedPets: updatedPets);
  }

  void confirmSelection() {
    final updatedPets = Map<String, bool>.from(state.selectedPets);
    for (final petType in allPetTypes) {
      if (!updatedPets.containsKey(petType)) {
        updatedPets[petType] = false;
      }
    }
    state = state.copyWith(selectedPets: updatedPets);
  }

  void reset() {
    state = ManagePetsState(selectedPets: {});
  }
}

final managePetsNotifierProvider =
    StateNotifierProvider<ManagePetsNotifier, ManagePetsState>(
        (ref) => ManagePetsNotifier());