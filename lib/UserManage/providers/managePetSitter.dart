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

  void togglePet(String petType) {
    final updatedPets = Map<String, bool>.from(state.selectedPets);
    if (updatedPets.containsKey(petType)) {
      updatedPets.remove(petType);
    } else {
      updatedPets[petType] = true;
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