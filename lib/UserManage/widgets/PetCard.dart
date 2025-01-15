import 'package:flutter/material.dart';
import 'package:happy_tails/UserManage/model/pet.dart';
import 'package:happy_tails/UserManage/repositories/local_database.dart';
import 'package:happy_tails/app/routes.dart';


const String pathIcon = 'assets/IconPets';

class PetCard extends StatelessWidget{
  final Widget petIcon;
  final Pet pet;

  static const Map<String, String> petsIcons = {
    'Cane' : "$pathIcon/dog.png",
    'Gatto' : "$pathIcon/cat.png",
    'Pesce' : "$pathIcon/fish.png",
    'Uccello' : "$pathIcon/dove.png",
    'Altro' : "$pathIcon/hamster.png"
  };

  PetCard({
    Key? key,
    required this.pet
  }) : petIcon = petsIcons[pet.type] != null
                ? Image.asset(petsIcons[pet.type]!, width: 30, height: 30,)
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
                            pet.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          subtitle: Text(
                            'Tipo ${pet.type}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.medical_services,
                              color: Colors.deepOrangeAccent,
                              size: 40,
                            ),
                            onPressed: () {
                              
                              Navigator.pushNamed(context, AppRoutes.vetPage, arguments: pet);
                              // Placeholder for veterinary record action
                            },
            ),
          ),
        ),
      ),
    );
  }
}