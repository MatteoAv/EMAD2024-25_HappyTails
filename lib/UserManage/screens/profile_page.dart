import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_providers.dart';

class UserProfilePage extends ConsumerWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final petsAsync = ref.watch(petsProvider);
    final bookingsAsync = ref.watch(bookingsProvider);
    final isPetsTabSelected = ref.watch(tabSelectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User information
            userAsync.when(
              data: (user) => Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user?.imageUrl ?? ''),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome, ${user?.userName ?? 'Guest'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'City: ${user?.citta ?? 'Unknown City'}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, _) => Text('Error: $err'),
            ),
            const SizedBox(height: 24),
            // Expandable buttons for Pets and Bookings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => ref.read(tabSelectionProvider.notifier).state = true,
                  child : Container(
                    height:60,
                    width: 90,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isPetsTabSelected ? Colors.orange[200] : Colors.grey[200],
                      border: Border.all( 
                        color: isPetsTabSelected ? Colors.redAccent : Colors.black,
                        width: 2,),
                        borderRadius: BorderRadius.circular(12)
                    ),
                  
                  child: Column(
                    children: [
                      Icon(
                        Icons.pets,
                        size: 25,
                        color: isPetsTabSelected ? Colors.redAccent[700] : Colors.grey[900],
                      ),
                      Text(
                        'Pets',
                        style: TextStyle(
                          color: isPetsTabSelected ? Colors.redAccent[700] : Colors.grey[900],
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
                GestureDetector(
                  onTap: () => ref.read(tabSelectionProvider.notifier).state = false,
                  child: Container(
                    height:60,
                    width: 90,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: !isPetsTabSelected ? Colors.orange[200] : Colors.grey[200],
                      border: Border.all( 
                        color: !isPetsTabSelected ? Colors.redAccent : Colors.black,
                        width: 2,),
                        borderRadius: BorderRadius.circular(12)
                    ),
                  
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 25,
                        color: !isPetsTabSelected ? Colors.redAccent[700] : Colors.grey[900],
                      ),
                      Text(
                        'Bookings',
                        style: TextStyle(
                          color: !isPetsTabSelected ? Colors.redAccent[700] : Colors.grey[900],
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Tab content
            Expanded(
              child: isPetsTabSelected
                  ? petsAsync.when(
                      data: (pets) => ListView.builder(
                        itemCount: pets.length,
                        itemBuilder: (context, index) {
                          final pet = pets[index];
                          return Card(
                            color: Colors.orange[100],
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepOrange,
                                child: Icon(Icons.pets, color: Colors.white),
                              ),
                              title: Text(
                                pet.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('Type: ${pet.type}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.medical_services, color: Colors.deepOrange),
                                onPressed: () {
                                  // Placeholder for future veterinary record action
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (err, _) => Text('Error: $err'),
                    )
                  : bookingsAsync.when(
                      data: (bookings) => ListView.builder(
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index];
                          return Card(
                            color: Colors.orange[200],
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Booking from ${booking.dateBegin} to ${booking.dateEnd}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Price: \$${booking.price.toStringAsFixed(2)}'),
                                  const SizedBox(height: 4),
                                  Text('Pet: ${booking.price ?? 'Unknown'}'),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Status: ${booking.state}',
                                    style: TextStyle(
                                      color: booking.state == 'Confermata'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (err, _) => Text('Error: $err'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
