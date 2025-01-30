import 'package:flutter/material.dart';
import 'package:happy_tails/Auth/auth_repository.dart';
import 'package:happy_tails/UserManage/screens/profile_page.dart';
import 'package:happy_tails/UserManage/screens/settings_page.dart';
import 'package:happy_tails/chat/clientList.dart';
import 'package:happy_tails/chat/petSitterList.dart';
import 'package:happy_tails/screens/ricerca/risultatiricerca_pagina.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:happy_tails/homePagePetSitter.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  final SupabaseClient supabase = Supabase.instance.client;
  List<Widget> _pages = []; // Inizializzata con una lista vuota
  bool isPetSitter = false;

  @override
  void initState() {
    super.initState();
    updatePages();

    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.signedOut) {
        updatePages();
      }
    });
  }

  void updatePages() {
    var session = supabase.auth.currentUser;
    if (session != null) {
      // Check if the user is a PetSitter
      _checkIfPetSitter().then((result) {
        setState(() {
          isPetSitter = result;
          _pages = isPetSitter
              ? [HomePagePetSitter(), RisultatiCercaPage(), ClientListPage(), UserProfilePage()]
              : [UserProfilePage(), RisultatiCercaPage(), UserListPage(), SettingsPage()];
              if (_selectedIndex >= _pages.length) {
          _selectedIndex = 0;
        }
        });
      });
    } else {
      setState(() {
        
        _pages = [LoginPage(), RisultatiCercaPage()];
        _selectedIndex = 0;
      });
    }
  }

  Future<bool> _checkIfPetSitter() async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id',supabase.auth.currentUser!.id);
      print(response.first['isPetSitter']);  
    return response.first['isPetSitter'];
  }

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
      _buildNavDestination(Icons.home, isPetSitter ? 'Home' : 'Home', 0),
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