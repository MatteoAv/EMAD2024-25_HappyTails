import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;  // Aggiungi il parametro onItemTapped

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,  // Aggiungi il parametro nel costruttore
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cerca'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Prenotazioni'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profilo'),
      ],
      currentIndex: selectedIndex,
      onTap: onItemTapped,  // Usa onItemTapped per gestire il cambio di pagina
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.black,
    );
  }
}
