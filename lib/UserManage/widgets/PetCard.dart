import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/UserManage/model/pet.dart';
import 'package:happy_tails/UserManage/providers/profile_providers.dart';
import 'package:happy_tails/app/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String pathIcon = 'assets/IconPets';

class PetCard extends ConsumerWidget {
  final Pet pet;

  static const Map<String, String> petsIcons = {
    'Cane': "$pathIcon/dog.png",
    'Gatto': "$pathIcon/cat.png",
    'Pesce': "$pathIcon/fish.png",
    'Uccello': "$pathIcon/dove.png",
    'Altro': "$pathIcon/hamster.png"
  };

  PetCard({
    Key? key,
    required this.pet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petIcon = petsIcons[pet.type] != null
        ? Image.asset(
            petsIcons[pet.type]!,
            width: 40,
            height: 40,
          )
        : const Icon(
            Icons.pets,
            color: Colors.deepOrangeAccent,
            size: 40,
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(16),
        color: Colors.deepOrange.shade50,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.deepOrange.shade100,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.vetPage, arguments: pet);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icona del pet
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.deepOrangeAccent,
                  ),
                  child: Center(child: petIcon),
                ),
                const SizedBox(width: 16),
                // Nome e tipo del pet
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Tipo: ${pet.type}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                // Icone di modifica e cancellazione
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.deepOrange),
                      onPressed: () {
                        showEditPetDialog(
                          context,
                          pet,
                          (id, newName, newType, ownerId) {
                            ref.read(petsProvider.notifier).UpdatePet(id, newName, newType, ownerId);
                          },
                        );
                      },
                      tooltip: 'Modifica',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        final ownerId = Supabase.instance.client.auth.currentUser?.id;
                        if (ownerId != null) {
                          ref.read(petsProvider.notifier).DeletePet(pet.id, ownerId);
                        }
                      },
                      tooltip: 'Elimina',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Spostiamo la funzione **fuori** dal widget
void showEditPetDialog(BuildContext context, Pet pet, Function(int, String, String, String) onConfirm) {
  TextEditingController nameController = TextEditingController(text: pet.name);
  String selectedType = pet.type;

  final List<String> petTypes = ['Cane', 'Gatto', 'Pesce', 'Uccello', 'Altro'];

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Modifica Animale', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campo per modificare il nome
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            // Dropdown per scegliere il tipo di animale
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: petTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  selectedType = newValue;
                }
              },
            ),
          ],
        ),
        actions: [
          // Pulsante Annulla
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla', style: TextStyle(color: Colors.redAccent)),
          ),
          // Pulsante Conferma
          ElevatedButton(
            onPressed: () async {
              final ownerId = Supabase.instance.client.auth.currentUser?.id;
              if (ownerId != null) {
                onConfirm(pet.id, nameController.text, selectedType, ownerId);
                Navigator.pop(context);
              }
            },
            child: const Text('Conferma'),
          ),
        ],
      );
    },
  );
}