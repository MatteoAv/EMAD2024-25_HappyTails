/* Pagina del profilo dell'utente loggato
UserAsync usa l'user provider per aggiornare le informazioni riguardanti l'utente,
se il provider si aggiorna esso notificherà automaticamente l'UserAsync

PetsAsync usa il pet provider per aggiornare la lista dei pet posseduti dall'utente,
se un utente aggiunge un pet con il Floating Action Button, il provider notificherà le modifiche e
petAsync si aggiorna di conseguenza

bookingAsync usa il book provider per aggiornare le liste delle prenotazioni in corso ed effettuate
dall'utente, se l'utente effettua o cancella una prenotazione, il book provider notificherà le modifiche
e di conseguenza bookAsync si aggiornerà

Il widget è suddiviso in tre parti 
1) Informazioni relative all'utente dove si effettua una chiamata a UserAsync che ritornerà le informazioni
relative organizzate in righe e colonne: immagine di profilo, username dell'utente e città di residenza.

2)Pulsanti a scorrimento per le liste di pet dell'utente e delle prenotazioni, organizzati in righe, i pulsanti
fanno uso del widget Expandable Button organizzati in colonna che aggiorneranno il booleano IsPetsTabSelected.
Se è true allora l'utente ha selezionato il pulsante dei pet, falso altrimenti.

3) Lista delle prenotazioni e dei pet: in base a quale pulsante è selezionato il widget tramite ListBuilder
costruirà una lista contenente delle Card interattive create con InkWell dei pet e delle prenotazioni,
ogni Card rappresenta un risultato ritornato tramite petsAsync e bookAsync. Le informazioni relative ai pet
sono : icona del pet in base al tipo, nome, tipo del pet e pulsante che riporta al libretto sanitario.
Le informazioni relative alle prenotazioni sono: data inizio e data fine, stato, prezzo ed animale coinvolto.

In fondo alla pagina è presente anche un bottone di tipo FloatingActionButton che permette di aggiungere un 
nuovo pet. Tramite la funzione OnTap() aprirà un menù a pop up gestito dalla classe AddPetDialog che attraverso
il notifier addPetProvider aggiungerà un pet al db locale ed esterno per poi notificare alla lista dei pet di 
aggiornarsi. 
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/UserManage/widgets/bookingCard.dart';
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
        automaticallyImplyLeading: false,
        title: const Text(
          'Profilo',
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
            key: ValueKey(user?.imageUrl),
            backgroundImage: user != null && user.imageUrl != null ? FileImage(File(user.imageUrl!)) : null,
            child: user?.imageUrl == null ? const Icon(Icons.person, size: 50) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Benvenuto/a',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                Text(
                  user?.userName ?? 'Ospite',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Città: ${user?.citta ?? 'Città mancante'}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
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
                const SizedBox(width: 15,),
                ExpandableButton(
                  icon: Icons.pets,
                  label: 'Animali',
                  isExpanded: isPetsTabSelected,
                  onTap: () =>
                      ref.read(tabSelectionProvider.notifier).state = true,
                ),
                const SizedBox(width: 30),
                ExpandableButton(
                  icon: Icons.calendar_month,
                  label: 'Prenotazioni',
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
              data: (pets) {
               if(pets.isNotEmpty){
               return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 16.0),
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  final pet = pets[index];
                  
                  return PetCard(pet : pet);
                },
              );
              }else{
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/IconPets/sadcat.png",
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                      "Nessun animale registrato, aggiungine uno",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
              
            },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            )
          : bookingsAsync.when(
              data: (bookings) { 
                if(bookings.isNotEmpty){
                return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 16.0),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return bookingCard(id: booking.id, bookingBegin: booking.dateBegin, bookingEnd: booking.dateEnd, 
                  bookPrice: booking.price, bookState: booking.state);
                },
              );
              }else{
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/IconPets/petsitter.png",
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                      "Nessun prenotazione effettuata, trova qualche PetSitter",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
              }
                
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
          Center(child: Text('Errore: $error, $stackTrace')),
        ),
      ),
    ],
  ),
      floatingActionButton: Visibility(
        visible: isPetsTabSelected,
        child: FloatingActionButton(
        onPressed: () {
          showDialog(
          context : context, 
          builder : (context) => const AddPetDialog());
          },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    ),
    );
  }
}
class AddPetDialog extends ConsumerWidget {
  const AddPetDialog({Key? key}) : super(key: key);
  final String iconPath = 'assets/IconPets';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addPetState = ref.watch(addPetProvider);
    final addPetNotifier = ref.read(addPetProvider.notifier);

    final animalTypes = {
      'Cane': "$iconPath/dog.png",
      'Gatto': "$iconPath/cat.png",
      'Pesce': "$iconPath/fish.png",
      'Uccello': "$iconPath/dove.png",
      'Altro': "$iconPath/hamster.png",
    };

    return AlertDialog(
      title: const Text('Aggiungi un animale'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nome animale',
                prefixIcon: Icon(Icons.edit),
              ),
              onChanged: addPetNotifier.setName,
            ),
            const SizedBox(height: 16),
            const Text('Tipo animale:'),
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
                      child: Image.asset(icon.toString(), width: 30, height: 30),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: addPetState.selectedType != null && addPetState.name.isNotEmpty
              ? () async{
                  final petName = addPetState.name;
                  final petType = addPetState.selectedType!;
                  final user_id = ref.watch(userProvider).value?.id;
                  if (user_id != null) {
                    bool res = await ref.read(petsProvider.notifier).AddPet(petName, petType, user_id);
                    if(res){
                    addPetNotifier.reset();
                    Navigator.pop(context);
                    }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                          "Animale già presente, riprova l'inserimento",
                          style: TextStyle(color: Colors.white),
                        ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                    );
                    }
                  }
                }
              : null,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
