import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:happy_tails/screens/ricerca/risultatiRicerca_pagina.dart';
import 'home.dart';           // Importa HomePage
import 'prenotazioni.dart';   // Importa PrenotazioniPage
import 'profilo.dart';        // Importa ProfiloPage
//import 'bottom_navbar.dart';  // Importa BottomNavBar

void main() {
  runApp(ProviderScope(child: MyApp()));
}

//Commento di prova
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  // Liste delle pagine
  final List<Widget> _pages = [
    HomePage(),
    CercaPage(),
    PrenotazioniPage(),
    ProfiloPage(),
  ];

  // Gestione del cambio di pagina
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HappyTails',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),

      debugShowCheckedModeBanner: false, //rimuove la scritta debug in alto a destra
      home: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,  // Mostra la pagina selezionata
          children: _pages,  // Le pagine da mostrare
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home,
                color: _selectedIndex == 0 ? Colors.orange : Colors.black,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.search,
                color: _selectedIndex == 1 ? Colors.orange : Colors.black,
              ),
              label: 'Cerca',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.book,
                color: _selectedIndex == 2 ? Colors.orange : Colors.black,
              ),
              label: 'Prenotazioni',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person,
                color: _selectedIndex == 3 ? Colors.orange : Colors.black,
              ),
              label: 'Profilo',
            ),
          ],
        ),
      ),
    );
  }
}
