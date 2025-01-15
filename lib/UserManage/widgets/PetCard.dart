import 'package:flutter/material.dart';


const String pathIcon = 'assets/IconPets';



class PetCard extends StatelessWidget {
  final String petName;
  final String petType;

  static const Map<String, String> petsIcons = {
    'Cane' : "$pathIcon/dog.png",
    'Gatto' : "$pathIcon/cat.png",
    'Pesce' : "$pathIcon/fish.png",
    'Uccello' : "$pathIcon/dove.png",
    'Altro' : "$pathIcon/hamster.png"
  };

  const PetCard({
    Key? key,
    required this.petName,
    required this.petType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final petIcon = petsIcons[petType] != null
        ? Image.asset(
            petsIcons[petType]!,
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
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        color: Colors.deepOrange.shade50,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.deepOrange.shade100,
          onTap: () {
            // Unified tap action for the whole card
            print("Card tapped: $petName, $petType");
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        petName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Tipo: $petType',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.medical_services,
                  color: Colors.deepOrangeAccent,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}