import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:happy_tails/app/navbarProvider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';


final supabase = Supabase.instance.client;
final pageProvider = StateNotifierProvider<PageManager, List<Widget>>((ref) => PageManager());

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  _MainScaffoldState createState() => _MainScaffoldState();

}

  class _MainScaffoldState extends ConsumerState<MainScaffold>{
  int _selectedIndex = 0;
  List<Widget> _pages = [];

  @override
  void initState(){
    super.initState();

    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.signedOut) {
        setState(() {
          _selectedIndex = 0;
        });
      }
    });
  }

  void _onItemTapped(int index) {
      setState(() {
          _selectedIndex = index;
      });
  }

  @override
  Widget build(BuildContext context) {
    _pages = ref.watch(pageProvider);
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages.isNotEmpty ? _pages : [CircularProgressIndicator()], // Placeholder
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
          destinations: _buildDestinations(),
        ),
      ),
    );
  }

  List<NavigationDestination> _buildDestinations() {
    final session = supabase.auth.currentUser;

    if (session == null) {
      return [
        _buildNavDestination(Icons.home, 'Login', 0),
        _buildNavDestination(Icons.search, 'Cerca', 1),
      ];
    }

    return [
      _buildNavDestination(Icons.home, 'Home', 0),
      _buildNavDestination(Icons.search, 'Cerca', 1),
      _buildNavDestination(Icons.message, 'Chat', 2),
      _buildNavDestination(Icons.person, 'Profilo', 3),
    ];
  }

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