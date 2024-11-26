import 'package:flutter/material.dart';
import 'package:happy_tails/UserManage/screens/profile_page.dart';
import 'package:happy_tails/home.dart';
import 'package:happy_tails/prenotazioni.dart';
import 'package:happy_tails/ricerca.dart';




class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // Pages to display in the navigation
  final List<Widget> _pages = const [
    HomePage(),
    CercaPage(),
    PrenotazioniPage(),
    UserProfilePage(),
  ];

  // Handle navigation bar selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          height: 60,
          destinations: [
            _buildNavDestination(Icons.home, 'Home', 0),
            _buildNavDestination(Icons.search, 'Cerca', 1),
            _buildNavDestination(Icons.book, 'Prenotazioni', 2),
            _buildNavDestination(Icons.person, 'Profilo', 3),
          ],
        ),
      ),
    );
  }

  // Helper function for building NavigationDestination
  NavigationDestination _buildNavDestination(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;

    return NavigationDestination(
      icon: Icon(
        icon,
        color: isSelected ? Colors.orange : Colors.black,
      ),
      label: label,
    );
  }
}
