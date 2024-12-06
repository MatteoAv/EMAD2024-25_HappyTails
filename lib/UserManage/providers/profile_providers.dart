import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/UserManage/model/user.dart';
import 'package:happy_tails/UserManage/model/pet.dart';
import 'package:happy_tails/UserManage/model/booking.dart';
import 'package:happy_tails/UserManage/repositories/local_database.dart';
import 'package:meta/meta.dart';

/*
Notifier che si occupa di recuperare l'utente attivo dal database locale
e che si occuperà di aggiornare l'istanza del db tramite notifiche 
*/
final userProvider = AsyncNotifierProvider<UserNotifier,User?>((){
  return UserNotifier();
});


/*
Notifier che si occupa di recuperare i pet dell'utente attivo dal database locale
e che si occuperà di gestire inserimento, cancellazione dal db locale tramite notifiche 
*/
final petsProvider = AsyncNotifierProvider<PetNotifier,List<Pet>>(PetNotifier.new);

final bookingsProvider = FutureProvider<List<Booking>>((ref) async {
  return LocalDatabase.instance.getBookings();
});

final addPetProvider = NotifierProvider<AddPetStateNotifier, AddPetState>( () => AddPetStateNotifier());

// State provider for managing tab selection
final tabSelectionProvider = StateProvider<bool>((ref) => true); // true for pets, false for bookings


//Notifier dell'utente che è un future di User
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

//Notifier dei Pet che è un Future di una Lista di Pet
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


