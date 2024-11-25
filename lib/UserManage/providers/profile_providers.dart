import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/user.dart';
import '../model/pet.dart';
import '../model/booking.dart';
import '../repositories/local_database.dart';

final userProvider = AsyncNotifierProvider<UserNotifier,User?>((){
  return UserNotifier();
});

final petsProvider = FutureProvider<List<Pet>>((ref) async {
  return LocalDatabase.instance.getPets();
});

final bookingsProvider = FutureProvider<List<Booking>>((ref) async {
  return LocalDatabase.instance.getBookings();
});

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

