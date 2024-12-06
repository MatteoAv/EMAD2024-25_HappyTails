import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:happy_tails/UserManage/screens/profile_page.dart';
import 'package:happy_tails/home.dart';
import 'package:happy_tails/prenotazioni.dart';
import 'package:happy_tails/profilo.dart';
import 'package:happy_tails/ricerca.dart';
import 'package:happy_tails/Auth/auth_repository.dart';
import 'package:happy_tails/Auth/registration.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  bool isLogged = LoginPage().logged;
  final SupabaseClient supabase = Supabase.instance.client;
  late List<Widget> _pages;


   @override
  void initState() {
    super.initState();
    _updatePages();
  }

  // Metodo per aggiornare la lista delle pagine
  void _updatePages() {
    final session = supabase.auth.currentSession;
    setState(() {
      _pages = [
        const HomePage(),
        const CercaPage(),
        const PrenotazioniPage(),
        // Aggiungi LoginPage o ProfilePage in base alla sessione
        if (session == null)  LoginPage(),
        if (session != null) const UserProfilePage(),
      ];
    });
  }


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
