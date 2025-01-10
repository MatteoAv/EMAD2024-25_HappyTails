import 'package:flutter/material.dart';


const String pathIcon = 'assets/IconPets';

class PetCard extends StatelessWidget{
  final Widget petIcon;
  final String petName;
  final String petType;


  static const Map<String, String> petsIcons = {
    'Cane' : "$pathIcon/dog.png",
    'Gatto' : "$pathIcon/cat.png",
    'Pesce' : "$pathIcon/fish.png",
    'Uccello' : "$pathIcon/dove.png",
    'Altro' : "$pathIcon/hamster.png"
  };

  PetCard({
    Key? key,
    required this.petName,
    required this.petType
  }) : petIcon = petsIcons[petType] != null
                ? Image.asset(petsIcons[petType]!, width: 30, height: 30,)
                : const Icon(Icons.help, color: Colors.white, size : 50),
       super(key : key);
      


  @override
  Widget build(BuildContext context){
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 30),
        child: Material(
              elevation: 20,
              borderRadius: BorderRadius.circular(20),
              color: Colors.deepOrange[50],
                  child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      splashColor: Colors.deepOrange[100],
                      onTap: () {
                          // Placeholder for pet click action
                      },
                      child: ListTile(
                          leading: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.deepOrangeAccent,
                          child: petIcon
                          ),
                          title: Text(
                            petName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          subtitle: Text(
                            'Tipo ${petType}',
                            style: const TextStyle(fontSize: 18),
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
      ),
    );
  }
}