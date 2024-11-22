import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/UserManage/repositories/local_database.dart';
import 'package:happy_tails/app/routes.dart';
import '../providers/profile_providers.dart';
import '../widgets/expandable_button.dart';

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
        title: const Text('Profile', style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold
          )
        ),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User information
            userAsync.when(
              data: (user) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.deepOrange, width: 2),
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                //Rotella delle impostazioni in alto a destra
                Positioned(
                      top: MediaQuery.of(context).size.height * 0,
                      right: MediaQuery.of(context).size.width * 0,
                      child: GestureDetector(
                        onTap: (){
                            Navigator.pushNamed(context, AppRoutes.settings);
                        },
                        child: Icon(Icons.settings, color: Colors.black, size: 30)
                      )
                )
                ],
              ),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, _) => Text('Error: $err'),
              ),
            
            
            const SizedBox(height: 24),
            // Expandable buttons for Pets and Bookings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ExpandableButton(
                  icon: Icons.pets,
                  label: 'Pets',
                  isExpanded: isPetsTabSelected,
                  onTap: () => ref.read(tabSelectionProvider.notifier).state = true,
                ),
                ExpandableButton(
                  icon: Icons.calendar_today,
                  label: 'Bookings',
                  isExpanded: !isPetsTabSelected,
                  onTap: () => ref.read(tabSelectionProvider.notifier).state = false,
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
                                  Text('Price: ${booking.price.toStringAsFixed(2)}€'),
                                  const SizedBox(height: 4),
                                  Text('Pet: ${petsAsync.value?[index].name ?? 'Unknown'}'),
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
