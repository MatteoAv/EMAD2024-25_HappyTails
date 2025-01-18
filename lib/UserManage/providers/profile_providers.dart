import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/UserManage/model/user.dart' as model;
import 'package:happy_tails/UserManage/model/pet.dart';
import 'package:happy_tails/UserManage/model/booking.dart';
import 'package:happy_tails/UserManage/repositories/local_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meta/meta.dart';



/*
Notifier che si occupa di recuperare l'utente attivo dal database locale
e che si occuperà di aggiornare l'istanza del db tramite notifiche 
*/
final userProvider = AsyncNotifierProvider<UserNotifier,model.User?>((){return UserNotifier();});


/*
Notifier che si occupa di recuperare i pet dell'utente attivo dal database locale
e che si occuperà di gestire inserimento, cancellazione dal db locale tramite notifiche 
*/
final petsProvider = AsyncNotifierProvider<PetNotifier,List<Pet>>(PetNotifier.new);

final bookingsProvider = AsyncNotifierProvider<BookNotifier, List<Booking>>(BookNotifier.new);

final addPetProvider = NotifierProvider<AddPetStateNotifier, AddPetState>( () => AddPetStateNotifier());

// State provider for managing tab selection
final tabSelectionProvider = StateProvider<bool>((ref) => true); // true for pets, false for bookings


//Notifier dell'utente che è un future di User
class UserNotifier extends AsyncNotifier<model.User?> {
  
  User? currentUser = Supabase.instance.client.auth.currentUser;

  @override
  Future<model.User?> build() async {
    _listenToAuthChanges();
    if(currentUser!=null){
    return LocalDatabase.instance.getUser(currentUser!.id);
    }
    return null;
  }

  final SupabaseClient supabase = Supabase.instance.client;

  void _listenToAuthChanges(){
    supabase.auth.onAuthStateChange.listen((data)async{
      final event = data.event;
      currentUser = Supabase.instance.client.auth.currentUser;
      if(event == AuthChangeEvent.signedIn){
        final user = await LocalDatabase.instance.getUser(currentUser!.id);
        state = AsyncData(user);
      }else if(event == AuthChangeEvent.signedOut){
        state = AsyncData(null);
      }
    });
  }

  Future<bool> updateUser(String userId, String newNickname, String newCity, String imageUrl) async {
    
    // Esegui l'aggiornamento nel database
    bool res= await LocalDatabase.instance.updateUser(userId,newNickname, newCity, imageUrl);
    if(res){
    // Aggiorna lo stato interno
    state = AsyncData(state.value?.copyWith(newNickname, newCity, imageUrl));
    
    
    return true;
    }
    
    return false;
  }

}

//Notifier dei Pet che è un Future di una Lista di Pet
class PetNotifier extends AsyncNotifier<List<Pet>>{

  @override
  Future<List<Pet>> build() async{
    final user = ref.watch(userProvider).value;
    if(user != null){
    final petList = await LocalDatabase.instance.getPets(user.id);
    if(petList.isEmpty){
      return [];
    }
    return petList;
    }
    return [];
  }

  Future <bool> AddPet(String name, String type, String owner_id)async{
    state = AsyncLoading();

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


class BookNotifier extends AsyncNotifier<List<Booking>>{
  
  @override
  Future<List<Booking>> build() async{
    final user = ref.watch(userProvider).value;
    if(user != null){
      final bookList = await LocalDatabase.instance.getBookings(user.id);
      if(bookList.isEmpty){
        return [];
      }
      return bookList;
    }
    return [];
  }

  Future<bool> updateBooking() async{
    final user = ref.watch(userProvider).value;
    if(user != null){
      final bookList = await LocalDatabase.instance.getBookings(user.id);
      if(bookList.isEmpty){
        state = AsyncData([]);
        return true;
      }else{
        state = AsyncData(bookList);
        return true;
      }
    }
    return false;
  }
}


