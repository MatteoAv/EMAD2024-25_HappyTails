import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/user.dart';
import '../model/pet.dart';
import '../model/booking.dart';
import '../repositories/local_database.dart';

final userProvider = FutureProvider<User?>((ref) async {
  return LocalDatabase.instance.getUser();
});

final petsProvider = FutureProvider<List<Pet>>((ref) async {
  return LocalDatabase.instance.getPets();
});

final bookingsProvider = FutureProvider<List<Booking>>((ref) async {
  return LocalDatabase.instance.getBookings();
});

// State provider for managing tab selection
final tabSelectionProvider = StateProvider<bool>((ref) => true); // true for pets, false for bookings
