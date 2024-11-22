import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:happy_tails/UserManage/repositories/local_database.dart';
import 'package:happy_tails/app/bottom_navbar.dart';
//import 'package:happy_tails/screens/ricerca/risultatiRicerca_pagina.dart';
import 'home.dart';           // Importa HomePage
import 'prenotazioni.dart';   // Importa PrenotazioniPage
import 'profilo.dart';        // Importa ProfiloPage
import 'ricerca.dart';        // Importa CercaPage
//import 'bottom_navbar.dart';  // Importa BottomNavBar
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabase.instance.deleteDatabaseFile();
  await LocalDatabase.instance.database;
  await LocalDatabase.instance.initializeDummyData();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      debugShowCheckedModeBanner: false,
      home: const MainScaffold(), // Separate stateful navigation logic
    );
  }
}
