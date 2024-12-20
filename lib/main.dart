import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:happy_tails/UserManage/repositories/local_database.dart';
import 'package:happy_tails/app/bottom_navbar.dart';
import 'package:happy_tails/app/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



Future<void> main() async{

  WidgetsFlutterBinding.ensureInitialized();
 
  await Supabase.initialize(
    url: 'https://nopqmogzpjhqntzristy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5vcHFtb2d6cGpocW50enJpc3R5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI4MDY4MzAsImV4cCI6MjA0ODM4MjgzMH0.tgm20B3Xgq26fgGBdK0Xy-Yz5_qVy0yW83fHcuqucb8',
  );
  //await LocalDatabase.instance.deleteDatabaseFile();
  await LocalDatabase.instance.database;
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MainScaffold(), // Separate stateful navigation logic
      initialRoute: AppRoutes.homePage,
      onGenerateRoute: AppRoutes.generateRoute, // Usa il routing centralizzato
    );
  }
}







