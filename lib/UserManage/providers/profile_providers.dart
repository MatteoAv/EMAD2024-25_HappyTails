import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/user.dart';
import '../model/pet.dart';
import '../model/booking.dart';
import '../repositories/local_database.dart';
import 'package:meta/meta.dart';

final userProvider = AsyncNotifierProvider<UserNotifier,User?>((){
  return UserNotifier();
});

final petsProvider = AsyncNotifierProvider<PetNotifier,List<Pet>>(PetNotifier.new);

final bookingsProvider = FutureProvider<List<Booking>>((ref) async {
  return LocalDatabase.instance.getBookings();
});

final addPetProvider = NotifierProvider<AddPetStateNotifier, AddPetState>( () => AddPetStateNotifier());

// State provider for managing tab selection
final tabSelectionProvider = StateProvider<bool>((ref) => true); // true for pets, false for bookings

class UserNotifier extends AsyncNotifier<User?> {
  bool isLoading = false;
  @override
  Future<User?> build() async {
    return LocalDatabase.instance.getUser();
  }

  Future<bool> updateUser(String newNickname, String newCity) async {
    isLoading = true;
    // Esegui l'aggiornamento nel database
    bool res= await LocalDatabase.instance.updateUser(1,newNickname, newCity);
    if(res){
    // Aggiorna lo stato interno
    state = AsyncData(state.value?.copyWith(newNickname, newCity));
    isLoading = false;
    return true;
    }
    isLoading = false;
    return false;
  }
}

class PetNotifier extends AsyncNotifier<List<Pet>>{
  bool isLoading = false;

  @override
  Future<List<Pet>> build() async{
    return LocalDatabase.instance.getPets();
  }

  Future <bool> AddPet(String name, String type, int owner_id)async{
    isLoading = true;
    Pet? res = await LocalDatabase.instance.AddPets(name, type, owner_id);
    if (res != null){
      state = AsyncData([...state.value ?? [], res]);
      return true;
    }
    return false;
  }
}

class AddPetStateNotifier extends Notifier<AddPetState> {
  @override
  AddPetState build() => AddPetState();

  void selectType(String type) {
    state = state.copyWith(selectedType: type);
  }

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void reset() {
    state = AddPetState();
  }
}

@immutable
class AddPetState {
  final String? selectedType;
  final String name;

  const AddPetState({this.selectedType, this.name = ''});

  AddPetState copyWith({String? selectedType, String? name}) {
    return AddPetState(
      selectedType: selectedType ?? this.selectedType,
      name: name ?? this.name,
    );
  }
}


