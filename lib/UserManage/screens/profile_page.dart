import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/UserManage/widgets/expandable_button.dart';
import 'package:happy_tails/app/routes.dart';
import 'package:happy_tails/UserManage/providers/profile_providers.dart';

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
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepOrange[50],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
            userAsync.when(
              data: (user) => Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(user?.imageUrl ?? ''),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      Text(
                        user?.userName ?? 'Guest',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                      ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'City: ${user?.citta ?? 'Unknown City'}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.settings);
                    },
                    child: const Icon(
                      Icons.settings,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, _) => Text('Error: $err'),
            ),
            const SizedBox(height: 50),
            // Expandable Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ExpandableButton(
                  icon: Icons.pets,
                  label: 'Pets',
                  isExpanded: isPetsTabSelected,
                  onTap: () => ref.read(tabSelectionProvider.notifier).state = true,
                ),
                SizedBox(width: 30),
                ExpandableButton(
                  icon: Icons.calendar_today,
                  label: 'Bookings',
                  isExpanded: !isPetsTabSelected,
                  onTap: () => ref.read(tabSelectionProvider.notifier).state = false,
                ),
               
              ],
            ),
            const SizedBox(height: 20),
             Text(
                  textAlign: TextAlign.left,
                  isPetsTabSelected ? 'Lista di Pet' : 'Lista prenotazioni',
                  style: TextStyle(
                    fontSize: 30,
                  ),
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
                          return InkWell(
                            splashColor: Colors.deepOrange[50],
                            onTap: () {
                              // Placeholder for action when a pet is tapped
                            },
                            child: Container(
                              height:90,
                              child: Card(
                              elevation: 20,
                              color: Colors.deepOrange[50],
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.deepOrangeAccent,
                                  child: const Icon(Icons.pets, color: Colors.white, size:40),
                                ),
                                title: Text(
                                  pet.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    ),
                                ),
                                subtitle: Text(
                                  'Type: ${pet.type}',
                                   style: const TextStyle(
                                    fontSize: 18
                                   ),
                                  ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.medical_services,
                                    color: Colors.deepOrangeAccent,
                                    size: 40,
                                  ),
                                  onPressed: () {
                                    // Placeholder for veterinary record action
                                  },
                                ),
                              ),
                            ),
                            )
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
                          return InkWell(
                            onTap: () {
                              // Placeholder for action when a booking is tapped
                            },
                            child: Container(
                              height: 135,
                              child: Card(
                              elevation: 20,
                              color: Colors.deepOrange[50],
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Booking from ${booking.dateBegin} to ${booking.dateEnd}',
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Price: ${booking.price.toStringAsFixed(2)}€',
                                    style: TextStyle(
                                      fontSize: 18
                                    ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Status: ${booking.state}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: booking.state == 'Confermata' ? Colors.green : Colors.red
                                    ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            )
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