import 'package:flutter/material.dart';
import 'home.dart';           // Importa HomePage
import 'cerca.dart';          // Importa CercaPage
import 'prenotazioni.dart';   // Importa PrenotazioniPage
import 'profilo.dart';        // Importa ProfiloPage
import 'bottom_navbar.dart';  // Importa BottomNavBar

void main() {
  runApp(MyApp());
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
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, //rimuove la scritta debug in alto a destra
      home: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,  // Mostra la pagina selezionata
          children: _pages,  // Le pagine da mostrare
        ),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,  // Passa la funzione di gestione
        ),
      ),
    );
  }
}
