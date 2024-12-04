/* Pagina del profilo dell'utente loggato
UserAsync usa l'user provider per aggiornare le informazioni riguardanti l'utente,
se il provider si aggiorna esso notificherà automaticamente l'UserAsync

PetsAsync usa il pet provider per aggiornare la lista dei pet posseduti dall'utente,
se un utente aggiunge un pet con il Floating Action Button, il provider notificherà le modifiche e
petAsync si aggiorna di conseguenza

bookingAsync usa il book provider per aggiornare le liste delle prenotazioni in corso ed effettuate
dall'utente, se l'utente effettua o cancella una prenotazione, il book provider notificherà le modifiche
e di conseguenza bookAsync si aggiornerà


 */













import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/UserManage/widgets/expandable_button.dart';
import 'package:happy_tails/app/routes.dart';
import 'package:happy_tails/UserManage/providers/profile_providers.dart';
import 'package:happy_tails/UserManage/widgets/PetCard.dart';

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
      body: CustomScrollView(
  slivers: [
    // Sliver: Intestazione (Informazioni sull'utente)
    SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userAsync.when(
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
                  const Text(
                    'Welcome',
                    style: TextStyle(
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text('Error: $err'),
        ),
      ),
    ),
    // Sliver: Pulsanti di navigazione (Pets e Book)
    SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ExpandableButton(
                  icon: Icons.pets,
                  label: 'Pets',
                  isExpanded: isPetsTabSelected,
                  onTap: () =>
                      ref.read(tabSelectionProvider.notifier).state = true,
                ),
                const SizedBox(width: 30),
                ExpandableButton(
                  icon: Icons.calendar_month,
                  label: 'Book',
                  isExpanded: !isPetsTabSelected,
                  onTap: () =>
                      ref.read(tabSelectionProvider.notifier).state = false,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              isPetsTabSelected ? 'Lista di Pet' : 'Lista prenotazioni',
              style: const TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    ),
    // Sliver: Contenuto Tab (Lista di Pets o Lista Prenotazioni)
    SliverFillRemaining(
      child: isPetsTabSelected
          ? petsAsync.when(
              data: (pets) => ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 16.0),
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  final pet = pets[index];
                  return PetCard(petName: pet.name, petType: pet.type);
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            )
          : bookingsAsync.when(
              data: (bookings) => ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 16.0),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return Container(
                    height: 135,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Card(
                      elevation: 20,
                      color: Colors.deepOrange[50],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Book from ${booking.dateBegin} to ${booking.dateEnd}',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Price: ${booking.price.toStringAsFixed(2)}€',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Status: ${booking.state}',
                              style: TextStyle(
                                fontSize: 20,
                                color: booking.state == 'Confermata'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
    ),
  ],
),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
          context : context, 
          builder : (context) => const AddPetDialog());
          },
        child: const Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
class AddPetDialog extends ConsumerWidget {
  const AddPetDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addPetState = ref.watch(addPetProvider);
    final addPetNotifier = ref.read(addPetProvider.notifier);

    final animalTypes = {
      'Dog': Icons.pets,
      'Cat': Icons.emoji_nature,
      'Fish': Icons.water,
      'Bird': Icons.airline_seat_flat,
      'Giraffe': Icons.sailing,
    };

    return AlertDialog(
      title: const Text('Add a Pet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Pet Name',
              prefixIcon: Icon(Icons.edit),
            ),
            onChanged: addPetNotifier.setName,
          ),
          const SizedBox(height: 16),
          const Text('Select Animal Type:'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: animalTypes.entries.map((entry) {
              final type = entry.key;
              final icon = entry.value;

              return GestureDetector(
                onTap: () => addPetNotifier.selectType(type),
                child: AnimatedScale(
                  scale: addPetState.selectedType == type ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: CircleAvatar(
                    backgroundColor: addPetState.selectedType == type
                        ? Colors.deepOrange
                        : Colors.grey[300],
                    radius: 30,
                    child: Icon(icon, 
                    color: Colors.white, 
                    size: 30,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: addPetState.selectedType != null &&
                  addPetState.name.isNotEmpty
              ? () {
                  final petName = addPetState.name;
                  final petType = addPetState.selectedType!;
                  final user_id = ref.watch(userProvider).value?.id;
                  if(user_id!=null){
                  ref.read(petsProvider.notifier).AddPet(petName, petType,user_id);
                  addPetNotifier.reset();
                  Navigator.pop(context);
                  }
                }
              : null,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
