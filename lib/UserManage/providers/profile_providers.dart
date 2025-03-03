import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/UserManage/model/user.dart' as model;
import 'package:happy_tails/UserManage/model/pet.dart';
import 'package:happy_tails/UserManage/model/booking.dart';
import 'package:happy_tails/UserManage/repositories/local_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meta/meta.dart';

// Recupera l'utente dalle SharedPreferences
  Future<model.User?> _getUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) {
      final userMap = jsonDecode(userString) as Map<String, dynamic>;
      return model.User(
        id: userMap['id'],
        userName: userMap['userName'],
        email: userMap['email'],
        citta: userMap['city'],
        imageUrl: userMap['imageUrl'] ?? '',
        isPetSitter: userMap['isPetSitter'] ?? false,
        customerId: userMap['customerId']
      );
    }
    return null; // Nessun dato salvato
  }

  // Salva/aggiorna i dati dell'utente nelle SharedPreferences
  Future<bool> _updateUserInPrefs(model.User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userMap = {
      'id': user.id,
      'userName': user.userName,
      'email': user.email,
      'city': user.citta,
      'imageUrl': user.imageUrl,
      'isPetSitter': user.isPetSitter,
      'customerId' : user.customerId
    };
    await prefs.setString('user', jsonEncode(userMap));
    return true;
  }

  // Cancella i dati dell'utente dalle SharedPreferences
  Future<void> clearUserPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }


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
    if(currentUser!=null){
      // Prova a recuperare i dati dalle SharedPreferences
    final userFromPrefs = await _getUserFromPrefs();
    if (userFromPrefs != null) {
      print(userFromPrefs.customerId);
      state = AsyncData(userFromPrefs);
      return userFromPrefs;
    }
    }
    return null;
  }

  final SupabaseClient supabase = Supabase.instance.client;

  Future<bool> updateUser(String userId, String newNickname, String newCity, String imageUrl, String email, bool isPetSitter, String? customer_id) async {
    model.User newUser = model.User(id: userId, userName: newNickname, citta: newCity, 
    imageUrl: imageUrl, email: email, isPetSitter: isPetSitter, customerId: customer_id);
   
    bool res = await _updateUserInPrefs(newUser);
    if(res){
    // Aggiorna lo stato interno
    state = AsyncData(newUser);
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

  Future <bool> UpdatePet(int id, String name, String type, String owner_id) async{
    state = AsyncLoading();

    bool res = await LocalDatabase.instance.UpdatePet(id, name, type, owner_id);
    if(res){
      state = AsyncData(await LocalDatabase.instance.getPets(owner_id));
      ref.read(bookingsProvider.notifier).updateBooking();
      return true;
    }
    return false;
  }

  Future <bool> DeletePet(int id, String owner_id) async{
    state = AsyncLoading();

    bool res = await LocalDatabase.instance.DeletePet(id);
    if(res){
      state = AsyncData(await LocalDatabase.instance.getPets(owner_id));
      ref.read(bookingsProvider.notifier).updateBooking();
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

  var _subscription; // To store the realtime subscription

  @override
  Future<List<Booking>> build() async{
    final user = ref.watch(userProvider).value;
    if(user != null){
      final bookList = await LocalDatabase.instance.getBookings(user.id);
      _initRealtimeSubscription(user.id); // Initialize real-time subscription here, after getting user and initial data
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

  void _initRealtimeSubscription(String userId) { // Pass userId here
    print('Initializing Realtime Subscription for user ID: $userId');
    _subscription = Supabase.instance.client // Assuming repository has access to Supabase client
        .channel('public:bookings:owner_id=eq.$userId') // Using user_id and eq.$userId
      .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter( // Assuming you want to filter by user_id
            type: PostgresChangeFilterType.eq,
            column: 'owner_id', // Filter by user_id column
            value: userId, // Use the userId obtained in build()
          ),
          callback: (payload) {
            print('----- REALTIME CALLBACK EXECUTED! -----');
            print('Payload: ${payload.toString()}');
            updateBooking(); // Call updateBooking to refresh state
          })
      .subscribe();
  }

  @override
  void dispose() {
    print('Disposing BookNotifier and unsubscribing from realtime');
    _subscription?.unsubscribe(); // Unsubscribe on dispose
  }
}





// Provider for the Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Provider for the BookingRepository
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return BookingRepository(client: client);
});

// StateNotifierProvider for BookingNotifier
final bookingNotifierProvider =
    StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return BookingNotifier(repository: repository);
});


class BookingRepository {
  final SupabaseClient client;

  BookingRepository({required this.client});

  /// Fetch bookings and group them by owner.
  Future<Map<String, List<Booking>>> fetchBookingsGroupedByClient() async {
    final response = await Supabase.instance.client.rpc('get_my_bookings_with_owners')
        .select('booking_id, owner_username, pet_name, pet_type, booking_details');


    final List<dynamic> bookings = response as List<dynamic>;
    final Map<String, List<Booking>> uniqueClients = {};

    for (final booking in bookings) {
      final String clientId = booking['booking_details']['owner_id'];
      final bookingDetails = booking['booking_details'];
      
      

      if (bookingDetails != null) {
        final actualBooking = Booking.fromMapFull(bookingDetails,booking["owner_username"],booking["pet_name"],booking["pet_type"]);

        if (!uniqueClients.containsKey(clientId)) {
          uniqueClients[clientId] = [];
        }
        uniqueClients[clientId]!.add(actualBooking);
      }
      else{
        uniqueClients[clientId] = [];

      }
    }
    print(uniqueClients);

    print("Fetched ${uniqueClients.length} unique clients.");
    return uniqueClients;
  }

  /// Update a booking's state.
  Future<bool> updateBookingState(int bookingId, {required bool accepted}) async {
    final String state = accepted ? "Confermata" : "Rifiutata";
    try{
      final response = await Supabase.instance.client
          .from('bookings')
          .update({'state': state})
          .eq('id', bookingId);
      if(response != null){
        LocalDatabase.instance.updateStateBooking(bookingId, state);
      }

      return true;
    }
    catch(e){
      print('Exception in respondToBooking: $e');
      return false;
    }
  }

}


/// Define a state class to hold our booking data and loading state.
class BookingState {
  final Map<String, List<Booking>> groupedBookings;
  final bool isLoading;
  final String? errorMessage;

  BookingState({
    required this.groupedBookings,
    this.isLoading = false,
    this.errorMessage,
  });

  BookingState copyWith({
    Map<String, List<Booking>>? groupedBookings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BookingState(
      groupedBookings: groupedBookings ?? this.groupedBookings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Create a StateNotifier for managing booking data.
class BookingNotifier extends StateNotifier<BookingState> {
  final BookingRepository repository;
  // Store the subscription object
  var _subscription;


  BookingNotifier({required this.repository})
      : super(BookingState(groupedBookings: {}, isLoading: true)) {
    fetchBookings();
    _initRealtimeSubscription();
  }

  Future<void> fetchBookings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await repository.fetchBookingsGroupedByClient();
      state = state.copyWith(groupedBookings: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

    Future<bool> respondToBooking(int bookingId, {required bool accepted}) async {
      print("sucsssscess is");

      final success = await repository.updateBookingState(bookingId, accepted: accepted);
      print("success is");
      print(success);
      if (success) {
        await fetchBookings();
        return true;
      }
      else {
      // Log the failure
      print('Failed to update booking $bookingId');
      return false;
    }
    }


  void _initRealtimeSubscription() async { // Make this function async
    try {
      final petsitterIdResult = await repository.client
          .rpc('get_current_petsitter_id');

     

      final petsitterId = petsitterIdResult; // Get the petsitter ID from RPC response
      print('RPC get_current_petsitter_id returned ID: $petsitterId'); // Log the ID

      final channelName = 'public:bookings:petsitter_id=eq.$petsitterId'; // Use RPC result in channel name
      print('Subscribing to channel: $channelName'); // Log the channel name

      _subscription = repository.client
          .channel(channelName) // Use dynamically constructed channel name
          .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'bookings',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'petsitter_id',
                value: petsitterId.toString(), // Use the RPC-obtained petsitterId here too, and ensure it's a string
              ),
              callback: (payload) {
                print('----- REALTIME CALLBACK EXECUTED! -----');
                print('Payload: ${payload.toString()}');
                fetchBookings();
              })
          .subscribe();

    } catch (e) {
      print('Error initializing realtime subscription: ${e.toString()}');
      // Handle error during RPC call or subscription setup
    }
  }
      

  @override
  void dispose() {
      // Unsubscribe from the realtime updates using the stored _subscription
      _subscription?.unsubscribe(); // Use the stored subscription and ?. for safety
      super.dispose();
    }

}


